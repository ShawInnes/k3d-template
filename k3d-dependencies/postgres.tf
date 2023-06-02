
resource "kubernetes_namespace" "postgres" {
  metadata {
    name = "postgres"
  }
}

resource "kubectl_manifest" "postgres-init" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: postgres-init
  namespace: ${kubernetes_namespace.postgres.id}
type: Opaque
data:
  init.sql: | 
    ${base64encode(templatefile("./k8s/postgres-init.tftpl", {
  databases = local.databases_map
}))}
YAML
}

resource "kubectl_manifest" "postgres-pvc" {
  yaml_body = <<PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres
  namespace: ${kubernetes_namespace.postgres.id}
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
PVC
}

# https://github.com/bitnami/charts/blob/main/bitnami/postgresql/values.yaml
resource "helm_release" "postgresql" {
  name      = "postgres"
  namespace = kubernetes_namespace.postgres.id
  wait      = true
  timeout   = 600

  values = [
    "${file("./k8s/postgres-values.yaml")}"
  ]

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"

  depends_on = [
    kubectl_manifest.postgres-secrets,
    kubectl_manifest.postgres-init,
    kubectl_manifest.postgres-pvc
  ]
}
