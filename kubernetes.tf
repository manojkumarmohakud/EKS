provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]  # 👈 Ensures EKS cluster is created first
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]  # 👈 Ensures EKS cluster is created first
}

# ✅ Automatically update kubeconfig after cluster creation
resource "null_resource" "configure_kubectl" {
  depends_on = [module.eks]  # 👈 Ensures cluster exists before running command

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region us-east-1 --name ${module.eks.cluster_name}"
  }
}

resource "kubernetes_deployment" "nginx" {
  depends_on = [null_resource.configure_kubectl]  # 👈 Ensures kubeconfig is updated

  metadata {
    name = "nginx"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 2  
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"  # Exposes the service externally
  }
}
