network_interfaces = {
    mgmt = {
      device_index       = 1
      subnet_id_map          = {
        us-west-1b = <YOUR_EXISTING_VPC_SUBNET_FGTLOGIN_AZA_ID>,
        us-west-1c = <YOUR_EXISTING_VPC_SUBNET_FGTLOGIN_AZB_ID>
      }
      enable_public_ip   = true
      source_dest_check  = true
      #security_groups = ["\<SECURITY_GROUP_ID\>"]
    },
    internal_traffic = {
      device_index     = 0
      subnet_id_map        = {
        us-west-1b = <YOUR_EXISTING_VPC_SUBNET_FGTINTERNAL_AZA_ID>,
        us-west-1c = <YOUR_EXISTING_VPC_SUBNET_FGTINTERNAL_AZB_ID>
      }
      to_gwlb = true
      #security_groups = ["\<SECURITY_GROUP_ID\>"]
    }
}
