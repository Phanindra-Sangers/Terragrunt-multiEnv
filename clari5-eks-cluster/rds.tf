################SECURITY GROUP DEPENDENCY ##############
resource "aws_security_group" "allow_tls" {
  name        = "${var.resource_tags["project"]}-${var.resource_tags["env"]}-rds-sg"
  description = "Allow MYSQL inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "MySQL traffic from EKS Subnets"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = var.private_subnets 
    #cidr_blocks      = concat(var.private_subnets, var.rds_allowed_cidrs)
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
   

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
  
}

module "rds" {
  source                                   = "terraform-aws-modules/rds/aws"
  version                                  = "5.1.1"
  identifier                               = var.identifier
  instance_use_identifier_prefix           = var.instance_use_identifier_prefix
  allocated_storage                        = var.allocated_storage
  storage_type                             = var.storage_type
  storage_encrypted                        = var.storage_encrypted
  kms_key_id                               = var.kms_key_id
  replicate_source_db                      = var.replicate_source_db
  license_model                            = var.license_model
  replica_mode                             = var.replica_mode
  iam_database_authentication_enabled      = var.iam_database_authentication_enabled
  domain                                   = var.domain
  domain_iam_role_name                     = var.domain_iam_role_name
  engine                                   = var.engine
  engine_version                           = var.engine_version
  skip_final_snapshot                      = var.skip_final_snapshot
  snapshot_identifier                      = var.snapshot_identifier
  copy_tags_to_snapshot                    = var.copy_tags_to_snapshot
  final_snapshot_identifier_prefix         = var.final_snapshot_identifier_prefix
  instance_class                           = var.instance_class
  db_name                                  = var.db_name
  username                                 = var.username
  password                                 = var.password
  port                                     = var.port
  vpc_security_group_ids                   = ["${aws_security_group.allow_tls.id}"]
  availability_zone                        = var.availability_zone
  multi_az                                 = var.multi_az
  iops                                     = var.iops
  publicly_accessible                      = var.publicly_accessible
  monitoring_interval                      = var.monitoring_interval
  monitoring_role_arn                      = var.monitoring_role_arn
  monitoring_role_name                     = var.monitoring_role_name
  monitoring_role_use_name_prefix          = var.monitoring_role_use_name_prefix
  monitoring_role_description              = var.monitoring_role_description
  create_monitoring_role                   = var.create_monitoring_role
  allow_major_version_upgrade              = var.allow_major_version_upgrade
  auto_minor_version_upgrade               = var.auto_minor_version_upgrade
  apply_immediately                        = var.apply_immediately
  maintenance_window                       = var.maintenance_window
  backup_retention_period                  = var.backup_retention_period
  backup_window                            = var.backup_window
  restore_to_point_in_time                 = var.restore_to_point_in_time
  s3_import                                = var.s3_import
  tags                                     = var.tags
  db_instance_tags                         = var.db_instance_tags
  db_option_group_tags                     = var.db_option_group_tags
  db_parameter_group_tags                  = var.db_parameter_group_tags
  db_subnet_group_tags                     = var.db_subnet_group_tags
  create_db_subnet_group                   = var.create_db_subnet_group
  db_subnet_group_name                     = var.db_subnet_group_name
  db_subnet_group_use_name_prefix          = var.db_subnet_group_use_name_prefix
  db_subnet_group_description              = var.db_subnet_group_description
  subnet_ids                               = module.vpc.private_subnets
  # DB parameter group
  create_db_parameter_group                = var.create_db_parameter_group
  #parameter_group_name                     = var.parameter_group_name
  parameter_group_use_name_prefix          = var.parameter_group_use_name_prefix
  parameter_group_description              = var.parameter_group_description
  family                                   = var.family
  parameters                               = var.parameters
  # DB option group
  create_db_option_group                   = var.create_db_option_group
  option_group_name                        = var.option_group_name
  option_group_use_name_prefix             = var.option_group_use_name_prefix
  option_group_description                 = var.option_group_description
  major_engine_version                     = var.major_engine_version
  options                                  = var.options
  create_db_instance                       = var.create_db_instance
  timezone                                 = var.timezone
  character_set_name                       = var.character_set_name
  enabled_cloudwatch_logs_exports          = var.enabled_cloudwatch_logs_exports
  timeouts                                 = var.timeouts
  option_group_timeouts                    = var.option_group_timeouts
  deletion_protection                      = var.deletion_protection
  performance_insights_enabled             = var.performance_insights_enabled
  performance_insights_retention_period    = var.performance_insights_retention_period
  performance_insights_kms_key_id          = var.performance_insights_kms_key_id
  max_allocated_storage                    = var.max_allocated_storage
  ca_cert_identifier                       = var.ca_cert_identifier
  delete_automated_backups                 = var.delete_automated_backups
  create_random_password                   = var.create_random_password
  random_password_length                   = var.random_password_length
  network_type                             = var.network_type
  ################################################################################
# CloudWatch Log Group
  ################################################################################
  create_cloudwatch_log_group              = var.create_cloudwatch_log_group
  cloudwatch_log_group_retention_in_days   = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id          = var.cloudwatch_log_group_kms_key_id
  depends_on                               = [ 
    aws_security_group.allow_tls 
  ]
} 