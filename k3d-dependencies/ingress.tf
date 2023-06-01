resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "nginx-controller" {
  name       = "nginx-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace = kubernetes_namespace.ingress-nginx.id
  depends_on = [
    kubernetes_namespace.ingress-nginx
  ]
}

data "kubernetes_service" "nginx-ingress-controller" {
  metadata {
    name      = "${resource.helm_release.nginx-controller.name}-ingress-nginx-controller"
    namespace = kubernetes_namespace.ingress-nginx.id
  }
  depends_on = [
    resource.helm_release.nginx-controller
  ]
}
