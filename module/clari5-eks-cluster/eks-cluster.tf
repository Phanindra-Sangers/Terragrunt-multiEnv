resource "aws_eks_cluster" "eks" {
   
  name                           = var.eks_cluster_name  #"TEST-EKS-CLUSTER"
  role_arn                       = aws_iam_role.eks-iam-role-clari5.arn
  version                        = var.eks_cluster_version
  vpc_config {
    subnet_ids                   = module.vpc.private_subnets
    endpoint_public_access       = var.endpoint_public_access
    endpoint_private_access      = var.endpoint_private_access
    security_group_ids           = [aws_security_group.eks_additional_sg.id]
    
  }

  depends_on = [
    aws_iam_role.eks-iam-role-clari5,
    aws_security_group.eks_additional_sg
  ]
  
  tags                          =  merge(tomap({
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    
  }),var.resource_tags)
}

resource "aws_security_group" "eks_additional_sg" {
  vpc_id                    = module.vpc.vpc_id
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  tags = var.resource_tags
}