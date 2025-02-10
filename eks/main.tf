resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn  

  vpc_config {
    subnet_ids             = var.public_subnets
    security_group_ids     = var.security_group_ids
    endpoint_public_access = var.endpoint_public_access
  }

  depends_on = [var.eks_role_arn]  
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn  
  subnet_ids      = var.public_subnets
  instance_types  = var.instance_types
  capacity_type   = var.capacity_type

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}" = "owned"
  }

  depends_on = [var.node_role_arn]  
}
