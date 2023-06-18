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

resource "kubectl_manifest" "cert-manager-letsencrypt-issuer" {
  yaml_body = <<PVC
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    email: ${var.acme_email_address}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: cluster-issuer-account-key
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx
PVC
}

resource "kubectl_manifest" "cert-manager-selfsigned-issuer" {
  yaml_body = <<PVC
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
PVC
}

resource "kubectl_manifest" "cert-manager-ca-certificate" {
  yaml_body = <<PVC
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: selfsigned-ca
  namespace: cert-manager
spec:
  isCA: true
  commonName: selfsigned-ca
  secretName: root-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
    group: cert-manager.io
PVC
}

resource "kubectl_manifest" "cert-manager-ca-issuer" {
  yaml_body = <<PVC
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
  namespace: cert-manager
spec:
  ca:
    secretName: root-secret
PVC
}

