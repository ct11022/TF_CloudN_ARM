testbed_name = "caag-arm-ex-67-reg"

#Use exsiting screct key for all testbed items SSH login.
public_key_path = "~/.ssh/apitest.pub"

# For create the VNET CIDR and subnet CIDR in Azure for controller
# controller_vnet_cidr   = "10.109.0.0/24"
# controller_subnet_cidr = "10.109.0.0/24"

#controller will be upgraded to the particular version of you assign
upgrade_target_version = "6.7-patch"

#if user want to create transit gw at existng VPC, you need to fill & enable following parameters
# transit_vnet_id = "ryan-cw-arm-avx-transit-vnet-01:ryan-cw-rg:e8ce487d-1ec9-4cf1-8957-221cd4fc5c85"
# transit_vnet_reg = "West US"
# transit_vnet_cidr = "10.88.0.0/16"
# transit_subnet_cidr = "10.88.7.64/26"
# transit_ha_subnet_cidr = "10.88.7.192/26"

incoming_ssl_cidr = ["218.161.71.144/32", "54.193.25.159/32", "54.241.35.249/32", "67.207.111.163/32"]


# caag_name = ""
# vcn_restore_snapshot_name = "6.5"
# on_prem = "10.44.44.44"
