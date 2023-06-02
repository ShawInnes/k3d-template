locals {
  unleash_password = "unleash"
  # random_password.database["unleash"].result
}

resource "kubernetes_namespace" "unleash" {
  metadata {
    name = "unleash"
  }
  count = var.install_unleash ? 1 : 0
}

resource "kubectl_manifest" "unleash-secrets" {
  yaml_body = <<PVC
apiVersion: v1
kind: Secret
metadata:
  name: unleash-secrets
  namespace: ${kubernetes_namespace.unleash[count.index].id}  
type: Opaque
data:
  unleash-password: ${base64encode(local.unleash_password)}
PVC

  count = var.install_unleash ? 1 : 0
}

# https://github.com/Unleash/helm-charts/blob/main/charts/unleash/values.yaml
resource "helm_release" "unleash" {
  name      = "unleash"
  namespace = kubernetes_namespace.unleash[count.index].id
  wait      = true
  timeout   = 600

  values = [
    "${file("./k8s/unleash-values.yaml")}"
  ]

  repository = "https://docs.getunleash.io/helm-charts"
  chart      = "unleash"

  depends_on = [
    helm_release.postgresql,
    kubectl_manifest.unleash-secrets
  ]

  count = var.install_unleash ? 1 : 0
}

# https://github.com/Unleash/helm-charts/blob/main/charts/unleash-edge/values.yaml
# resource "helm_release" "unleash-edge" {
#   name      = "unleash-edge"
#   namespace = kubernetes_namespace.unleash.id
#   wait      = true
#   timeout   = 600

#   values = [
#     "${file("./k8s/unleash-edge-values.yaml")}"
#   ]

#   repository = "https://docs.getunleash.io/helm-charts"
#   chart      = "unleash-edge"

#   depends_on = [
#     helm_release.unleash
#   ]

#   count = local.install_unleash ? 1 : 0
# }
