resource "kubernetes_namespace" "reloader" {
  metadata {
    name = "reloader"
  }
}

resource "helm_release" "reloader" {
  name       = "reloader"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"

  set {
    name  = "reloader.reloadStrategy"
    value = "annotations"
  }

  namespace = kubernetes_namespace.reloader.id
}

