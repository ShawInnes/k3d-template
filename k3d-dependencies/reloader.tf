resource "kubernetes_namespace" "reloader" {
  metadata {
    name = "reloader"
  }
}
