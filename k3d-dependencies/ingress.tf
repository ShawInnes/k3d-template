resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

# https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml
resource "helm_release" "nginx-controller" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "tcp.5432"
    value = "postgres/postgres-postgresql:5432"
  }

  set {
    name  = "tcp.6379"
    value = "redis/redis-master:6379"
  }

  namespace = kubernetes_namespace.ingress-nginx.id
  depends_on = [
    kubernetes_namespace.ingress-nginx
  ]
}
