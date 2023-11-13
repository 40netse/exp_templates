## Note: Please go through all arguments in this file and replace the content with your configuration! This file is just an example.
## "<YOUR-OWN-VALUE>" are parameters that you need to specify your own value.

## Root config
region     = "us-west-2" # e.g. "us-east-2"

## VPC
security_groups = {
  secgrp1 = {
    description = "Security group by Terraform"
    ingress = {
      all_traffic = {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    egress = {
      all_traffic = {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
  }
}

existing_security_vpc = {
    name = "mdw-exp-test-inspection-vpc"
    id = "vpc-0d68baf14bd53bd18" # FIX THIS
}

#existing_tgw = {
#    id = "tgw-055c3f759f16730cf"
#}
#
#igw_id = "igw-0eaadbf6d9758d377"

vpc_cidr_block     = "10.0.0.0/24" # e.g. "10.0.0.0/16"
spoke_cidr_list    = ["192.168.0.0/24", "192.168.1.0/24"] # e.g. ["10.1.0.0/16"]
availability_zones = ["us-west-2a", "us-west-2c"] # e.g. ["us-west-1b", "us-west-1c"]



## Transit Gateway
tgw_name        = "tgw-mdw-exp"
tgw_description = "his is a test tgw for mdw exp"

## Auto scale group
# This example is a hybrid license ASG
fgt_intf_mode = "2-arm"
asgs = {
  fgt_byol_asg = {
      template_name = "fgt_asg_template"
      fgt_version = "7.2.6"
      instance_type = "c5n.xlarge"
      license_type = "byol"
      fgt_password = "Texas4me!" # e.g. "fortinet"
      keypair_name = "mdw-key-oregon" # Keypair should be created manually
      lic_folder_path = "./license"
      ##fortiflex_refresh_token = "" # e.g. "NasmPa0CXpd56n6TzJjGqpqZm9Thyw"
      ##fortiflex_sn_list = ["", ""] # e.g. ["FGVMMLTM00000001", "FGVMMLTM00000002"]
      ##fortiflex_configid_list = [] # e.g. [2343]
      enable_fgt_system_autoscale = true
      intf_security_group = {
        login_port = "secgrp1"
        internal_port = "secgrp1"
      }
      user_conf_file_path = "./fgt_config.conf" # e.g. "./fgt_config.conf"
        # There are 3 options for providing user_conf data: 
        # user_conf_content : FortiGate Configuration
        # user_conf_file_path : The file path of configuration file
        # user_conf_s3 : Map of AWS S3 

      asg_max_size = 2
      asg_min_size = 2
      # asg_desired_capacity = 1
      create_dynamodb_table = true
      dynamodb_table_name = "fgt_asg_track_table"
  },
  fgt_on_demand_asg = {
      template_name = "fgt_asg_template_on_demand"
      fgt_version = "7.2.6"
      instance_type = "c5n.xlarge"
      license_type = "on_demand"
      fgt_password = "Texas4me!" # e.g. "fortinet"
      keypair_name = "mdw-key-oregon" # Keypair should be created manually
      enable_fgt_system_autoscale = true
      intf_security_group = {
        login_port = "secgrp1"
        internal_port = "secgrp1"
      }
      user_conf_file_path = "./fgt_config.conf" # e.g. "./fgt_config.conf"
        # There are 3 options for providing user_conf data: 
        # user_conf_content : FortiGate Configuration
        # user_conf_file_path : The file path of configuration file
        # user_conf_s3 : Map of AWS S3 
      asg_max_size = 2
      asg_min_size = 0
      # asg_desired_capacity = 0
      dynamodb_table_name = "fgt_asg_track_table"
      scale_policies = {
        byol_cpu_above_80 = {
            policy_type               = "SimpleScaling"
            adjustment_type           = "ChangeInCapacity"
            cooldown                  = 60
            scaling_adjustment        = 1
        },
        byol_cpu_below_30 = {
            policy_type               = "SimpleScaling"
            adjustment_type           = "ChangeInCapacity"
            cooldown                  = 60
            scaling_adjustment        = -1
        },
        ondemand_cpu_above_80 = {
            policy_type               = "SimpleScaling"
            adjustment_type           = "ChangeInCapacity"
            cooldown                  = 60
            scaling_adjustment        = 1
        },
        ondemand_cpu_below_30 = {
            policy_type               = "SimpleScaling"
            adjustment_type           = "ChangeInCapacity"
            cooldown                  = 60
            scaling_adjustment        = -1
        }
      }
  }
}

## Cloudwatch Alarm
cloudwatch_alarms = {
  byol_cpu_above_80 = {
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 80
    dimensions = {
      AutoScalingGroupName = "fgt_byol_asg"
    }
    alarm_description = "This metric monitors average ec2 cpu utilization of Auto Scale group fgt_asg_byol."
    datapoints_to_alarm = 1
    alarm_asg_policies     = {
      policy_name_map = {
        "fgt_on_demand_asg" = ["byol_cpu_above_80"]
      }
    }
  },
  byol_cpu_below_30 = {
    comparison_operator = "LessThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 30
    dimensions = {
      AutoScalingGroupName = "fgt_byol_asg"
    }
    alarm_description = "This metric monitors average ec2 cpu utilization of Auto Scale group fgt_asg_byol."
    datapoints_to_alarm = 1
    alarm_asg_policies     = {
      policy_name_map = {
        "fgt_on_demand_asg" = ["byol_cpu_below_30"]
      }
    }
  },
  ondemand_cpu_above_80 = {
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 80
    dimensions = {
      AutoScalingGroupName = "fgt_on_demand_asg"
    }
    alarm_description = "This metric monitors average ec2 cpu utilization of Auto Scale group fgt_asg_ondemand."
    alarm_asg_policies     = {
      policy_name_map = {
        "fgt_on_demand_asg" = ["ondemand_cpu_above_80"]
      }
    }
  },
  ondemand_cpu_below_30 = {
    comparison_operator = "LessThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 30
    dimensions = {
      AutoScalingGroupName = "fgt_on_demand_asg"
    }
    alarm_description = "This metric monitors average ec2 cpu utilization of Auto Scale group fgt_asg_ondemand."
    alarm_asg_policies     = {
      policy_name_map = {
        "fgt_on_demand_asg" = ["ondemand_cpu_below_30"]
      }
    }
  }
}

# Gateway Load Balancer
enable_cross_zone_load_balancing = true

## Spoke VPC
#enable_east_west_inspection = true
# "<YOUR-OWN-VALUE>" # e.g. 
#spk_vpc = {
# # This is optional. The module will create Transit Gateway Attachment under each subnet in argument 'subnet_ids', and also create route table to let all traffic (0.0.0.0/0) forward to the TGW attachment with the subnets associated.
#     "spk_vpc1" = {
#       vpc_id = "vpc-09fdd28792621de90",
#       subnet_ids = [
#         "subnet-0e1f3fb535285fc92",
#         "subnet-0cd7de2246a7a65ff"
#       ]
#     },
#    "spk_vpc2" = {
#     vpc_id = "vpc-0fdf15739d781e32e",
#     subnet_ids = [
#       "subnet-0e586ed9b5eb1185f",
#       "subnet-0a4ed032562309727"
#     ]
#   }
#}

## Tag
general_tags = {
  "purpose" = "MDW_EXP_TEST"
}



