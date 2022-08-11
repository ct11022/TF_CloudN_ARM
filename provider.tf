terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.8.0"
    }
    null = {
      source = "hashicorp/null"
    }
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
    }
  }
}
provider "azurerm" {
  features {}
}
provider "aviatrix" {
  controller_ip           = module.aviatrix_controller_build.aviatrix_controller_public_ip_address
  username                = var.avx_controller_admin_username
  password                = var.avx_controller_admin_password
  skip_version_validation = true
  alias                   = "new_controller"
}
