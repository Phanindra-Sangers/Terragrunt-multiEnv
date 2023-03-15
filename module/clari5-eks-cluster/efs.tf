resource "aws_efs_file_system" "clari5-efs" {
   creation_token = "efs"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
   tags = merge(tomap( {
     Name = "${var.resource_tags["project"]}-${var.resource_tags["env"]}-efs"
   }), var.resource_tags)
 }

 
resource "aws_efs_mount_target" "efs-mt" {
   
   file_system_id  = aws_efs_file_system.clari5-efs.id
   subnet_id =  "${element(module.vpc.private_subnets,count.index)}"  #module.vpc.private_subnets[0]
   security_groups = [aws_security_group.efs-sg.id]
   count = 3
 }
 
resource "aws_security_group" "efs-sg" {
   name = "${var.resource_tags["project"]}-${var.resource_tags["env"]}-efs-sg"
   description= "Allos inbound efs traffic from ec2"
   vpc_id = module.vpc.vpc_id

   ingress {
     #security_groups = [aws_security_group.ec2.id]
     cidr_blocks = ["${var.vpc_cidr}"]
     from_port = 2049
     to_port = 2049 
     protocol = "tcp"
   }     
        
   egress {
     cidr_blocks = ["0.0.0.0/0"]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
   tags = var.resource_tags
 }