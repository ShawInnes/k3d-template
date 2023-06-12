resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

locals {
  cert-manager-version = "1.12.0"
}

data "http" "cert-manager-crds" {
  url = "https://github.com/cert-manager/cert-manager/releases/download/v${local.cert-manager-version}/cert-manager.crds.yaml"

  request_headers = {
    Accept = "text/plain"
  }
}

data "kubectl_file_documents" "cert-manager-crds" {
  content = data.http.cert-manager-crds.response_body
}

resource "kubectl_manifest" "cert-manager-crds" {
  for_each  = data.kubectl_file_documents.cert-manager-crds.manifests
  yaml_body = each.value
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "${local.cert-manager-version}"

  namespace = kubernetes_namespace.cert-manager.id
}

resource "kubectl_manifest" "cert-manager-issuer" {
  yaml_body = <<PVC
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
  namespace: ${kubernetes_namespace.cert-manager.id}
spec:
  ca:
    secretName: ca-key-pair
PVC
}

