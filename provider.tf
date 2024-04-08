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
      # version = "2.22.1"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "azurerm" {
  features {}
}
provider "aws" {
  region                   = var.aws_controller_region
  shared_config_files      = var.aws_shared_config_files
  shared_credentials_files = var.aws_shared_credentials_files
  profile                  = var.aws_shared_config_profile_name

}
provider "aviatrix" {
  controller_ip           = module.aviatrix_controller_build.public_ip
  username                = var.avx_controller_admin_username
  password                = var.avx_controller_admin_password
  skip_version_validation = true
  alias                   = "new_controller"
}
