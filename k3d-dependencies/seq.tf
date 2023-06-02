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

# https://github.com/datalust/helm.datalust.co/blob/main/charts/seq/values.yaml
resource "helm_release" "seq" {
  name       = "seq"
  repository = "https://helm.datalust.co"
  chart      = "seq"
  wait      = true
  timeout   = 600

  namespace = kubernetes_namespace.seq.id

  values = [
    "${file("./k8s/seq-values.yaml")}"
  ]

  depends_on = [
    helm_release.nginx-controller,
    kubernetes_namespace.seq,
    kubectl_manifest.seq-pvc
  ]
}
