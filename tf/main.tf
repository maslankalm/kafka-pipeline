provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
  required_version = ">= 1.3.0"
}

data "kubernetes_namespace" "default" {
  metadata {
    name = "default"
  }
}
