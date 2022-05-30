output "controller_private_ip" {
  value = module.aviatrix_controller_build.aviatrix_controller_private_ip_address
}

output "controller_public_ip" {
  value = module.aviatrix_controller_build.aviatrix_controller_public_ip_address
}

output "spoke_public_vms_info" {
  value = module.arm-spoke-vnet.ubuntu_public_vms[*]
}

output "spoke_private_vms_info" {
  value = module.arm-spoke-vnet.ubuntu_private_vms[*]
}

