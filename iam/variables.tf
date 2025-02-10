variable "eks_role_name" {
  description = "IAM role name for the EKS cluster"
  type        = string
  default     = "EksClusterRole"
}

variable "node_role_name" {
  description = "IAM role name for the worker nodes"
  type        = string
  default     = "EKS-WORKER-NODE-ROLE"
}