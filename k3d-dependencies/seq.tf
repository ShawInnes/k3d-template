resource "kubernetes_namespace" "seq" {
  metadata {
    name = "seq"
  }
}

resource "kubectl_manifest" "seq-pvc" {
  yaml_body = <<PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: seq
  namespace: ${kubernetes_namespace.seq.id}
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
PVC
}

