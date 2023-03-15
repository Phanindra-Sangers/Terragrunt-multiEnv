resource "aws_eks_node_group" "worker-node-group" {

  cluster_name                 = aws_eks_cluster.eks.name
  node_group_name              = var.node_group_name
  node_role_arn                = aws_iam_role.workernodes.arn
  subnet_ids                   = module.vpc.private_subnets
  instance_types               = var.eks_instance_types
  disk_size                    = var.eks_node_size 
  ami_type                     = var.eks_ami_type #    "AL2_x86_64" #"BOTTLEROCKET_x86_64"   
  tags = merge(tomap({
    Name                                            = "${var.resource_tags["project"]}-${var.resource_tags["env"]}-worker-node"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
    
  }), var.resource_tags)

  scaling_config {
    desired_size = var.eks_scale_config_desired_size
    max_size     = var.eks_scale_config_max_size
    min_size     = var.eks_scale_config_min_size
    
  }
 
  remote_access {
    ec2_ssh_key              = aws_key_pair.generated_key.key_name 
    #source_security_group_ids = [aws_security_group.bastion_host_sg.id]
    
  }
  

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
  tags_all = {
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled" = "true"
  }
 lifecycle {
   create_before_destroy = true
 }
}

