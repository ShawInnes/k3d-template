resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }
}

resource "random_password" "redis" {
  length   = 16
  special  = false
}

resource "kubectl_manifest" "redis-secrets" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: redis-secrets
  namespace: ${kubernetes_namespace.redis.id}
type: Opaque
data:
  redis: ${base64encode(random_password.redis.result)}
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
