# get all available AZs in our region
data "aws_availability_zones" "available_zones" {
  state = "available"
}
# reserve Elastic IP to be used in our NAT gateway
resource "aws_eip" "nat_gw_elastic_ip" {
  vpc = true

  tags = {
    Name = "eks-nat-eip"
  }
}

# create VPC using the official AWS module
module "vpc" {
  source                      = "terraform-aws-modules/vpc/aws"
  version                     = "3.14.0"

  name                        =  var.vpc_name
  cidr                        =  var.vpc_cidr
  azs                         = data.aws_availability_zones.available_zones.names
  create_vpc                  = var.create_vpc
  private_subnets             = var.private_subnets

  public_subnets              = var.public_subnets

  # enable single NAT Gateway to save some money
  # WARNING: this could create a single point of failure, since we are creating a NAT Gateway in one AZ only
  # feel free to change these options if you need to ensure full Availability without the need of running 'terraform apply'
  # reference: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/2.44.0#nat-gateway-scenarios
  enable_nat_gateway          = var.enable_nat_gateway
  single_nat_gateway          = var.single_nat_gateway  
  one_nat_gateway_per_az      = var.one_nat_gateway_per_az
  enable_dns_hostnames        = var.enable_dns_hostnames 
  reuse_nat_ips               = var.reuse_nat_ips
  external_nat_ip_ids         = [aws_eip.nat_gw_elastic_ip.id]

  # add VPC/Subnet tags required by EKS
  tags = merge(tomap({
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }), var.resource_tags
  )
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "kubernetes.io/role/elb"                    = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}