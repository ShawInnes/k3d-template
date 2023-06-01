resource "kubernetes_namespace" "seq" {
  metadata {
    name = "seq"
  }
}

resource "kubectl_manifest" "seq-pv" {
  yaml_body = <<PV
apiVersion: v1
kind: PersistentVolume
metadata:
  name: seq
spec:
  storageClassName: local-path
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/k3dvol/seq"
PV

  depends_on = [
    kubernetes_namespace.seq
  ]
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

  depends_on = [
    kubectl_manifest.seq-pv
  ]
}

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
