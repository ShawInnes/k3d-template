locals {
  databases = setunion(toset(var.databases), toset(var.environments))
  
  databases_map = {
    for database in setunion(toset(var.databases), toset(var.environments)) :
    database => database # 
    # random_password.database[database].result
  }
}

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

# This should be used to create random passwords
# resource "random_password" "database" {
#   for_each = local.databases
#   length   = 16
#   special  = false
# }

locals {
  secrets_map = tomap({
    "postgres-password" = "postgres"
    "password" = "postgres"
    "replication-password" = "postgres"
  })
}

resource "kubectl_manifest" "postgres-secrets" {
  yaml_body = templatefile("./k8s/postgres-secrets.tftpl", {
    namespace = kubernetes_namespace.postgres.id
    databases = merge(local.databases_map, local.secrets_map)
  })
}
