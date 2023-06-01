terraform {
  required_providers {
    k3d = {
      source  = "pvotal-tech/k3d"
      version = "0.0.6"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
  }
}

provider "k3d" {
  # Configuration options
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-dev"
}

provider "helm" {
  repository_config_path = "${path.module}/.helm/repositories.yaml" 
  repository_cache       = "${path.module}/.helm"
    
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "k3d-dev"
  }
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = "k3d-dev"
}

