data "aws_caller_identity" "current" {}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

locals {
  # Proper boolean usage
  new_key                     = (var.keypair_name == "" ? true : false)
  new_incoming_ssl_cidrs      = concat(var.incoming_ssl_cidrs, ["${chomp(data.http.icanhazip.response_body)}/32"])
  iptable_ssl_cidr_jsonencode = jsonencode([for i in local.new_incoming_ssl_cidrs : { "addr" = i, "desc" = "" }])
}

module "aviatrix_controller_build" {
  source                 = "git@github.com:AviatrixDev/terraform-aviatrix-aws-controller.git"
  create_iam_roles       = false
  use_existing_vpc       = (var.controller_vpc_id != "" ? true : false)
  vpc_id                 = var.controller_vpc_id
  subnet_id              = var.controller_subnet_id
  use_existing_keypair   = true
  key_pair_name          = var.keypair_name
  ec2_role_name          = "aviatrix-role-ec2"
  controller_name_prefix = var.testbed_name
  allow_upgrade_jump     = true
  enable_ssh             = true
  release_infra          = var.release_infra
  ami_id                 = var.aviatrix_controller_ami_id
  incoming_ssl_cidrs     = ["0.0.0.0/0"]
  aws_account_id         = data.aws_caller_identity.current.account_id
  admin_email            = var.avx_controller_admin_email
  admin_password         = var.avx_controller_admin_password
  access_account_email   = var.avx_controller_admin_email
  access_account_name    = var.aviatrix_aws_access_account
  customer_license_id    = var.aviatrix_customer_id
  controller_version     = var.upgrade_target_version

}

resource "aws_security_group_rule" "ingress_rule_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = local.new_incoming_ssl_cidrs
  security_group_id = module.aviatrix_controller_build.security_group_id
}

resource "aviatrix_controller_security_group_management_config" "security_group_config" {
  provider                         = aviatrix.new_controller
  enable_security_group_management = false
  depends_on = [
    module.aviatrix_controller_build
  ]
}

# resource "null_resource" "call_api_set_allow_list" {
#   provisioner "local-exec" {
#     command = <<-EOT
#             AVTX_CID=$(curl -X POST  -k https://${module.aviatrix_controller_build.aviatrix_controller_public_ip_address}/v1/backend1 -d 'action=login_proc&username=admin&password=Aviatrix123#'| awk -F"\"" '{print $34}');
#             curl -k -v -X PUT https://${module.aviatrix_controller_build.aviatrix_controller_public_ip_address}/v2.5/api/controller/allow-list --header "Content-Type: application/json" --header "Authorization: cid $AVTX_CID" -d '{"allow_list": ${local.iptable_ssl_cidr_jsonencode}, "enable": true, "enforce": true}'
#         EOT
#   }
#     depends_on = [module.aviatrix_controller_build]
# }

# Create an Aviatrix Azure Account
resource "aviatrix_account" "azure_account" {
  provider            = aviatrix.new_controller
  account_name        = var.aviatrix_arm_access_account
  cloud_type          = 8
  arm_subscription_id = var.ARM_SUBSCRIPTION_ID
  arm_directory_id    = var.ARM_TENANT_ID
  arm_application_id  = var.ARM_CLIENT_ID
  arm_application_key = var.ARM_CLIENT_SECRET
  depends_on          = [module.aviatrix_controller_build]
}

resource "aviatrix_controller_cert_domain_config" "controller_cert_domain" {
  provider    = aviatrix.new_controller
  cert_domain = var.cert_domain
  depends_on = [
    aviatrix_account.azure_account
  ]
}

# Create spoke VNET and end VM.
module "arm-spoke-vnet" {
  source = "git@github.com:AviatrixDev/automation_test_scripts.git//Regression_Testbed_TF_Module/modules/testbed-vnet-arm?ref=master"
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
  account_name         = var.aviatrix_arm_access_account
  region               = var.transit_vnet_reg
  name                 = "${var.testbed_name}-Tr-VNET"
  cidr                 = "172.16.0.0/16"
  aviatrix_firenet_vpc = false
  depends_on           = [aviatrix_account.azure_account]
}

# Create an Aviatrix Transit Gateway
resource "aviatrix_transit_gateway" "transit" {
  provider          = aviatrix.new_controller
  cloud_type        = 8
  account_name      = var.aviatrix_arm_access_account
  gw_name           = "${var.testbed_name}-Transit-GW"
  vpc_id            = (var.transit_vnet_id != "" ? var.transit_vnet_id : aviatrix_vpc.transit_vnet[0].vpc_id)
  vpc_reg           = (var.transit_vnet_id != "" ? var.transit_vnet_reg : aviatrix_vpc.transit_vnet[0].region)
  gw_size           = var.transit_size
  subnet            = (var.transit_vnet_cidr != "" ? var.transit_subnet_cidr : cidrsubnet(aviatrix_vpc.transit_vnet[0].cidr, 10, 320))
  insane_mode       = true
  ha_subnet         = (var.transit_vnet_cidr != "" ? var.transit_ha_subnet_cidr : cidrsubnet(aviatrix_vpc.transit_vnet[0].cidr, 10, 325))
  ha_gw_size        = var.transit_size
  single_ip_snat    = false
  connected_transit = true
  depends_on        = [aviatrix_account.azure_account]
}

# Create an Aviatrix Spoke Gateway
resource "aviatrix_spoke_gateway" "spoke" {
  provider          = aviatrix.new_controller
  count             = var.spoke_count
  cloud_type        = 8
  account_name      = var.aviatrix_arm_access_account
  gw_name           = "${var.testbed_name}-Spoke-GW-${count.index}"
  vpc_id            = "${module.arm-spoke-vnet.vnet_name[count.index]}:${module.arm-spoke-vnet.rg_name[count.index]}:${module.arm-spoke-vnet.resource_guid[count.index]}"
  vpc_reg           = var.location
  gw_size           = var.spoke_size
  subnet            = module.arm-spoke-vnet.subnet_cidr[count.index]
  manage_ha_gateway = false
  depends_on = [
    aviatrix_account.azure_account,
    module.arm-spoke-vnet,
  ]
}

# Create an Aviatrix AWS Spoke HA Gateway
resource "aviatrix_spoke_ha_gateway" "spoke_ha" {
  provider        = aviatrix.new_controller
  count           = var.spoke_count
  primary_gw_name = aviatrix_spoke_gateway.spoke[count.index].id
  subnet          = module.arm-spoke-vnet.subnet_cidr[count.index]
  gw_name         = "${var.testbed_name}-Spoke-GW-${count.index}-${var.spoke_ha_postfix_name}"
}

# Create Spoke-Transit Attachment
resource "aviatrix_spoke_transit_attachment" "spoke" {
  provider        = aviatrix.new_controller
  count           = var.spoke_count
  spoke_gw_name   = aviatrix_spoke_gateway.spoke[count.index].gw_name
  transit_gw_name = aviatrix_transit_gateway.transit.gw_name
  depends_on = [
    aviatrix_spoke_ha_gateway.spoke_ha
  ]
}
