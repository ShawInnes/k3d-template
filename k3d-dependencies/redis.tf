locals {
  redis_password = "redis"
  # random_password.redis.result
}

resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }
}

# resource "random_password" "redis" {
#   length   = 16
#   special  = false
# }

resource "kubectl_manifest" "redis-secrets" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: redis-secrets
  namespace: ${kubernetes_namespace.redis.id}
type: Opaque
data:
  redis: ${base64encode(local.redis_password)}
YAML
}

resource "kubectl_manifest" "redis-pvc" {
  yaml_body = <<PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis
  namespace: ${kubernetes_namespace.redis.id}
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
PVC
}

# https://github.com/bitnami/charts/blob/main/bitnami/redis/values.yaml
resource "helm_release" "redis" {
  name      = "redis"
  namespace = kubernetes_namespace.redis.id
  wait      = true
  timeout   = 600

  values = [
    "${file("./k8s/redis-values.yaml")}"
  ]

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"

  depends_on = [ 
    kubectl_manifest.redis-secrets,
    kubectl_manifest.redis-pvc
   ]
}
