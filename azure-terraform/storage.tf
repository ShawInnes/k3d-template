
# resource "kubernetes_persistent_volume" "postgresql" {
#   for_each = toset(var.environments)

#   metadata {
#     name = "postgresql-${each.key}"

#     labels = {
#       type = "local"
#     }
#   }

#   spec {
#     storage_class_name = "local-path"

#     capacity = {
#       storage = "2Gi"
#     }

#     access_modes = ["ReadWriteOnce"]

#     persistent_volume_source {
#       host_path {
#         path = "/mnt/k3dvol"
#       }
#     }
#   }
# }

# resource "kubernetes_persistent_volume_claim" "postgresql" {
#   for_each = toset(var.environments)

#   metadata {
#     name      = "postgresql-${each.key}-claim"
#     namespace = kubernetes_namespace.whoami[each.key].metadata[0].name
#   }

#   spec {
#     storage_class_name = "local-path"
#     access_modes       = ["ReadWriteOnce"]

#     resources {
#       requests = {
#         storage = "2Gi"
#       }
#     }
#   }
# }

# resource "helm_release" "postgresql" {
#   for_each  = toset(var.environments)
#   namespace = kubernetes_namespace.whoami[each.key].metadata[0].name

#   name       = "postgresql"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "postgresql"

#   set {
#     name  = "persistence.storageClass"
#     value = "postgresql"
#   }

#   set {
#     name  = "persistence.selector"
#     value = <<EOT
# matchLabels:
#   environment: ${each.key}
#     EOT
#   }
# }
