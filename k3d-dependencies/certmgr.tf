resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

locals {
  cert-manager-version = "1.12.0"
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "${local.cert-manager-version}"

  set {
    name = "installCRDs"
    value = "true"
  }

  namespace = kubernetes_namespace.cert-manager.id
}

resource "kubectl_manifest" "cert-manager-issuer" {
  yaml_body = <<PVC
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    email: technology@heylemonade.com.au
    privateKeySecretRef:
      name: cluster-issuer-account-key
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx
PVC
}
