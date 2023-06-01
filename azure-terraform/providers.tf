terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.90.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "hey-lemonade"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "azurerm" {
  features {

  }
}
