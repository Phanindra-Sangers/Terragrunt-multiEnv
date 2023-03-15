module "eks_vpc" {
  source = "./clari5-eks-cluster"
  region = "ap-south-1"
  resource_tags = {
    "env"     = "dev"
    "project" = "clari5"
    "Iaac"    = "Terraform"
  }
  ############################ VPC VARIABLES ################################
  create_vpc             = true
  vpc_name               = "clari5-dev-vpc"
  vpc_cidr               = "10.0.0.0/16"
  public_subnets         = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  private_subnets        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true
  reuse_nat_ips          = true

  ####################################### BASTION HOST VARAIBLES ###################################################
  ####################################### EKS CLUSTER VARIABELS ########################################

  eks_cluster_name        = "clari5-dev-cluster"
  eks_cluster_version     = "1.24"
  endpoint_public_access  = false
  endpoint_private_access = true

  ####################################### EKS NODE GROUP VARAIBLES #####################################

  node_group_name               = "clari5-dev-node-group"
  eks_ami_type                  = "AL2_x86_64"
  eks_node_size                 = 50
  eks_instance_types            = ["t3a.medium"]
  eks_scale_config_desired_size = 2
  eks_scale_config_max_size     = 5
  eks_scale_config_min_size     = 2
  ############################## RDS VARIABLES ######################################

  identifier        = "devdbfor"
  db_name           = "clari5RDSinstance"
  allocated_storage = "50"
  storage_type      = "gp2"
  storage_encrypted = true

  backup_retention_period             = 7
  performance_insights_enabled        = false
  engine                              = "MySQL"
  major_engine_version                = "8.0"
  iam_database_authentication_enabled = false
  #availability_zone = "ap-south-1a"
  multi_az                       = false
  create_db_parameter_group      = false
  #parameter_group_name           = "clari5-dev-rds-mysql-pg"
  create_db_instance             = true
  instance_class                 = "db.m5d.large"
  family                         = "mysql8.0"
  deletion_protection            = false
  username                       = "admin"
  instance_use_identifier_prefix = false
  #subnet_ids =  ["${module.vpc.private_subnets}"]
  #vpc_security_group_ids = "sg-05d00bcde1683594f"
  create_db_subnet_group = true
  db_subnet_group_name   = "clari5-dev-subnet-db"

  ################################################### PRITUNEL #######################
  # pritunl_instance_create = false
  # pritunl_instance_name   = "pritunl_vpn_server"
  # pritunl_ami_id          = "ami-04473c3d3be6a927f"
  # pritunl_instance_type   = "t3a.small"


}