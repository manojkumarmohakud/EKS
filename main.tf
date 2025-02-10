module "network" {
  source                     = "../modules/network"
  vpc_cidr                   = "10.0.0.0/16"
  vpc_name                   = "Manoj-eks-vpc"
  igw_name                   = "Manoj-eks-gw"
  public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidr_blocks = ["10.0.4.0/24", "10.0.5.0/24"]
  availability_zones         = ["us-east-1a", "us-east-1b"]
  public_subnet_name_prefix  = "Manoj-eks-public-subnet"
  private_subnet_name_prefix = "Manoj-eks-private-subnet"
  public_rt_name             = "Manoj-eks-public-rt"
  private_rt_name            = "Manoj-eks-private-rt"
}

module "security" {
  source                     = "../modules/securitygroup"
  security_group_name        = "Manoj-eks-securitygroup"
  security_group_description = "desc"
  inbound_port               = [80, 22]
  vpc_id                     = module.network.vpc_id

}
module "iam" {
  source = "../modules/iam"
}

module "eks" {
  source                 = "../modules/eks"
  cluster_name           = "Manoj-eks-nginx"
  capacity_type          = "ON_DEMAND"
  public_subnets         = module.network.public_subnet_ids
  security_group_ids     = [module.security.security_group_id]
  endpoint_public_access = true
  node_group_name        = "Manoj_Node_Group"
  instance_types         = ["t3.medium"]
  desired_size           = 1
  max_size               = 2
  min_size               = 1
  eks_role_arn           = module.iam.eks_role_arn  # ✅ Pass IAM Role ARN from IAM module
  node_role_arn          = module.iam.node_role_arn  # ✅ Pass IAM Role ARN from IAM module
}

# kubectl to connect to EKS
/*resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region us-east-1 --name ${module.eks.cluster_name}"
  }

  depends_on = [module.eks]
}*/

