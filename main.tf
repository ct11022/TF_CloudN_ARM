
#create a Controller with new build VNET in Azure
module "aviatrix_controller_build" {
  source = "./aviatrix_controller_build_arm"
  // please do not use special characters such as `\/"[]:|<>+=;,?*@&~!#$%^()_{}'` in the controller_name
  controller_name                 = var.testbed_name
  location                        = var.location
  controller_vnet_cidr            = var.controller_vnet_cidr
  controller_subnet_cidr          = var.controller_subnet_cidr
  controller_virtual_machine_size = var.controller_virtual_machine_size
  incoming_ssl_cidr               = concat(var.incoming_ssl_cidr, [var.controller_vnet_cidr])
  public_key_path                 = var.public_key_path

}

module "aviatrix_controller_initialize" {
  source                        = "git@github.com:AviatrixSystems/terraform-aviatrix-azure-controller.git//modules/aviatrix_controller_initialize?ref=master"
  avx_controller_public_ip      = module.aviatrix_controller_build.aviatrix_controller_public_ip_address
  avx_controller_private_ip     = module.aviatrix_controller_build.aviatrix_controller_private_ip_address
  avx_controller_admin_email    = var.avx_controller_admin_email
  avx_controller_admin_password = var.avx_controller_admin_password
  arm_subscription_id           = var.ARM_SUBSCRIPTION_ID
  arm_application_id            = var.ARM_CLIENT_ID
  arm_application_key           = var.ARM_CLIENT_SECRET
  directory_id                  = var.ARM_TENANT_ID
  account_email                 = var.avx_controller_admin_email
  access_account_name           = var.access_account_name
  aviatrix_customer_id          = var.aviatrix_customer_id
  controller_version            = var.upgrade_target_version

  depends_on = [
    module.aviatrix_controller_build
  ]
}

# Create spoke VNET and end VM.
module "arm-spoke-vnet" {
  source              = "git@github.com:AviatrixDev/automation_test_scripts.git//Regression_Testbed_TF_Module/modules/testbed-vnet-arm?ref=master"
  // please do not use special characters such as `\/"[]:|<>+=;,?*@&~!#$%^()_{}'` in the controller_name
  resource_name_label = "${var.testbed_name}-spoke"
  region              = var.location
  vnet_count          = var.spoke_count
  vnet_cidr           = var.vnet_cidr
  pub_subnet1_cidr    = var.pub_subnet1_cidr
  pub_subnet2_cidr    = var.pub_subnet2_cidr
  pri_subnet1_cidr    = var.pri_subnet1_cidr
  pri_subnet2_cidr    = var.pri_subnet2_cidr
  pri_hostnum         = var.pri_hostnum
  pub_hostnum         = var.pub_hostnum
  public_key          = file(var.public_key_path)
}

#Create Transit VNET
resource "aviatrix_vpc" "transit_vnet" {
  provider             = aviatrix.new_controller
  count                = (var.transit_vnet_id != "" ? 0 : 1)
  cloud_type           = 8
  account_name         = var.access_account_name
  region               = var.transit_vnet_reg
  name                 = "${var.testbed_name}-Tr-VNET"
  cidr                 = "172.16.0.0/16"
  aviatrix_firenet_vpc = false
  depends_on = [
  module.aviatrix_controller_initialize]
}

# Create an Aviatrix Transit Gateway
resource "aviatrix_transit_gateway" "transit" {
  provider     = aviatrix.new_controller
  cloud_type   = 8
  account_name = var.access_account_name
  gw_name      = "${var.testbed_name}-Transit-GW"
  vpc_id       = (var.transit_vnet_id != "" ? var.transit_vnet_id : aviatrix_vpc.transit_vnet[0].vpc_id)
  vpc_reg      = (var.transit_vnet_id != "" ? var.transit_vnet_reg : aviatrix_vpc.transit_vnet[0].region)
  gw_size      = var.transit_size
  subnet       = (var.transit_vnet_cidr != "" ? var.transit_subnet_cidr : cidrsubnet(aviatrix_vpc.transit_vnet[0].cidr, 10, 320))
  insane_mode = true
  ha_subnet   = (var.transit_vnet_cidr != "" ? var.transit_ha_subnet_cidr : cidrsubnet(aviatrix_vpc.transit_vnet[0].cidr, 10, 325))
  ha_gw_size        = var.transit_size
  single_ip_snat    = false
  connected_transit = true
  depends_on = [
  module.aviatrix_controller_initialize]
}

# Create an Aviatrix Spoke Gateway
resource "aviatrix_spoke_gateway" "spoke" {
  provider                   = aviatrix.new_controller
  count                      = var.spoke_count
  cloud_type                 = 8
  account_name               = var.access_account_name
  gw_name                    = "${var.testbed_name}-Spoke-GW-${count.index}"
  vpc_id                     = "${module.arm-spoke-vnet.vnet_name[count.index]}:${module.arm-spoke-vnet.rg_name[count.index]}:${module.arm-spoke-vnet.resource_guid[count.index]}"
  vpc_reg                    = var.location
  gw_size                    = var.spoke_size
  subnet                     = module.arm-spoke-vnet.subnet_cidr[count.index]
  ha_subnet                  = module.arm-spoke-vnet.subnet_cidr[count.index]
  ha_gw_size                 = var.spoke_size
  manage_transit_gateway_attachment = false
  depends_on                 = [
    module.arm-spoke-vnet,
    module.aviatrix_controller_initialize
  ]
}

# Create Spoke-Transit Attachment
resource "aviatrix_spoke_transit_attachment" "spoke" {
  provider        = aviatrix.new_controller
  count           = var.spoke_count
  spoke_gw_name   = aviatrix_spoke_gateway.spoke[count.index].gw_name
  transit_gw_name = aviatrix_transit_gateway.transit.gw_name
}
