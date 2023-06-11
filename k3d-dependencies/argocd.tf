
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml
resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = kubernetes_namespace.argocd.id
  wait      = true
  timeout   = 600

  values = [
    "${file("./k8s/argocd-values.yaml")}"
  ]

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
}
