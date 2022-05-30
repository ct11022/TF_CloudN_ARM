variable "location" {
  type        = string
  description = "Resource Group Location for Aviatrix Controller"
  default     = "West US"
}

variable "testbed_name" {
  type        = string
  description = "Customized Name for Test Bed"
}

variable "upgrade_target_version" {
  type        = string
  description = "it will be upgraded to the particular version of you assign"
  default     = "latest"
}

variable "controller_vnet_cidr" {
  type        = string
  description = "CIDR for controller VNET."
  default     = "10.168.0.0/24"
}

variable "controller_subnet_cidr" {
  type        = string
  description = "CIDR for controller subnet."
  default     = "10.168.0.0/24"
}

variable "controller_virtual_machine_size" {
  type        = string
  description = "Virtual Machine size for the controller."
  default     = "Standard_D2_v2"
}

variable "incoming_ssl_cidr" {
  type        = list(string)
  description = "Incoming cidr for security group used by controller."
}

variable "public_key_path" {
  type        = string
  description = "The path of public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "avx_controller_admin_username" {
  type        = string
  description = "Admin Username for the controller GUI."
  default     = "admin"
}

variable "avx_controller_admin_password" {
  type        = string
  description = "Admin Password for the controller GUI."
  default     = "Aviatrix123#"
}

variable "avx_controller_admin_email" {
  type    = string
  default = "ctseng@aviatrix.com"
}

variable "access_account_name" {
  description = "This name labels the account in the Aviatrix Controller."
  type        = string
  default     = "arm1"
}

variable "aviatrix_customer_id" {
  description = "Customer ID provided by Aviatrix to be able to use the product."
  type        = string

}

variable "ARM_SUBSCRIPTION_ID" {
  type        = string
  description = "This input variable using ENV variables $ARM_SUBSCRIPTION_ID."
}
variable "ARM_CLIENT_ID" {
  type        = string
  description = "This input variable using ENV variables $ARM_CLIENT_ID."
}
variable "ARM_CLIENT_SECRET" {
  type        = string
  description = "This input variable using ENV variables $ARM_CLIENT_SECRET."
}
variable "ARM_TENANT_ID" {
  type        = string
  description = "This input variable using ENV variables $ARM_TENANT_ID."
}

variable "pub_hostnum" {
  type        = number
  description = "Number to be used for public ubuntu instance private ip host part. Must be a whole number that can be represented as a binary integer."
  default     = 10
}

variable "pri_hostnum" {
  type        = number
  description = "Number to be used for private ubuntu instance private ip host part. Must be a whole number that can be represented as a binary integer."
  default     = 20
}

variable "transit_vnet_id" {
  description = "for private network, the transit vnet id"
  default     = ""
}

variable "transit_vnet_reg" {
  description = "Create in the exsits private network, the transit vnet region"
  default     = "West US"
}

variable "transit_vnet_cidr" {
  description = "Create in the exsits private network, the transit vnet cidr"
  default     = ""
}

variable "transit_subnet_cidr" {
  description = "Create in the exsitsor private network, the transit sunbet cidr"
  default     = ""
}

variable "transit_ha_subnet_cidr" {
  description = "Create in the exsits private network, the transit ha subnet cidr"
  default     = ""
}

variable "transit_size" {
  description = "Transit GW size"
  default     = "Standard_D8s_v3"
}

variable "spoke_size" {
  description = "Spoke GW size"
  default     = "Standard_B1ms"
}

variable "spoke_count" {
  description = "The number of spokes to create."
  default     = 1
}

variable "vnet_cidr" {
  description = "ARM VNET cidr"
  type        = list(string)
  default     = ["10.8.0.0/16", "10.9.0.0/16"]
}
variable "pub_subnet1_cidr" {
  description = "Public subnet 1 cidr"
  type        = list(string)
  default     = ["10.8.0.0/24", "10.9.0.0/24"]
}
variable "pub_subnet2_cidr" {
  description = "Public subnet 2 cidr"
  type        = list(string)
  default     = ["10.8.1.0/24", "10.9.1.0/24"]
}
variable "pri_subnet1_cidr" {
  description = "Private subnet 1 cidr"
  type        = list(string)
  default     = ["10.8.2.0/24", "10.9.2.0/24"]
}
variable "pri_subnet2_cidr" {
  description = "Private subnet 2 cidr"
  type        = list(string)
  default     = ["10.8.3.0/24", "10.9.3.0/24"]
}