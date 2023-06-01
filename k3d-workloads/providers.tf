terraform {
  required_providers {
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

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-dev"
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = "k3d-dev"
  #load_config_file       = false
}

