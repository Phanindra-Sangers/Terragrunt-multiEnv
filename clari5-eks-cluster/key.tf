resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.eks_cluster_name
  public_key = tls_private_key.example.public_key_openssh
}
resource "local_sensitive_file" "private_key" {
  filename          = "${var.eks_cluster_name}-key.pem"
  content           = tls_private_key.example.private_key_pem
  file_permission   = "0400"
}