# TF_CloudN_ARM
This is a terraform script is use for build a standard testbed with 1 Controller 1 Tr with HA, 1 Spoke with HA, 2 Spoke end VM (Private x 1, Public x 1)in Azure CSP to CloudN testing 

### Description

This Terraform configuration launches a new Aviatrix controller in Azure. Then, it initializes controller and installs with specific released version. It also configures 1 Spoke(HA) GWs and attaches to Transit(HA) GW 

### Prerequisites

### 1. Authenticating to Azure

Please refer to the documentation for
the [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) Terraform providers to decide how
to authenticate to Azure.

## If you have Service Principal with a Client Secret Please refer to the following usage
If your storing the credentials as Environment Variables, Please add TF_VAR_ENV variables
``` shell
$ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
$ export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
$ export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"

Add following
$ export TF_VAR_ARM_CLIENT_ID=$ARM_CLIENT_ID
$ export TF_VAR_ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
$ export TF_VAR_ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
$ export TF_VAR_ARM_TENANT_ID=$ARM_TENANT_ID
```

Or you can define credentials in the "provider.tf"
This method requires the use of the key in the provider_cred.tfvars at next stes.
``` terraform
variable "client_secret" {
}

# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.ARM_SUBSCRIPTION_ID
  client_id       = var.ARM_CLIENT_ID
  client_secret   = var.ARM_CLIENT_SECRET
  tenant_id       = var.ARM_TENANT_ID
}
```

### 2. Aviatrix Credentials
Provide testbed info such as controller password, license etc as necessary in provider_cred.tfvars file.
``` terraform
aviatrix_controller_password = "Enter_your_controller_password"  
aviatrix_admin_email  = "Enter_your_controller_admin_email"  
aviatrix_license_id  = "Enter_license_ID_string_for_controller"
ARM_SUBSCRIPTION_ID = ""
ARM_CLIENT_ID = ""
ARM_CLIENT_SECRET = ""
ARM_TENANT_ID = ""
github_token  = "Github oAthu token allow TF access Aviatrix private Repo"  
```
### 3. The Arguments for Customized
Provide feather testbed info such as exsits Transit VNET, upgrade_target_version etc in terraform.tfvars file to customized testbed.
``` terraform
testbed_name = ""  
public_key_path = "Adding exsiting public key to spoke end vm"
controller_vnet_id = "Deploy the controller on existing VPC"  
controller_subnet_id = "The subnet ID belongs to above VPC"  
controller_vpc_cidr  = "VPC CIDR"  
upgrade_target_version = "it will be upgraded to the particular version of you assign"  
transit_vnet_id = "Deploy the Transit GW on existing VPC" 
transit_vnet_reg = "The VPC region" 
transit_vnet_cidr = "VPC CIDR"  
transit_subnet_cidr = "Subnet CIDR" 
transit_ha_subnet_cidr = "Subnet CIDR" 
incoming_ssl_cidr = ["CIDR", "It makes access to controller"]  
```

### 4. Usage for Terraform
```
terraform init
terraform apply -var-file=provider_cred.tfvars -target=module.aviatrix_controller_initialize -auto-approve && terraform apply -var-file=provider_cred.tfvars -auto-approve
terraform show
terraform destroy -var-file=provider_cred.tfvars -auto-approve
terraform show
```
