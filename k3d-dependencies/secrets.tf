locals {
  databases = setunion(toset(var.databases), toset(var.environments))
  
  databases_map = {
    for database in setunion(toset(var.databases), toset(var.environments)) :
    database => database # 
    # random_password.database[database].result
  }
}

# This should be used to create random passwords
# resource "random_password" "database" {
#   for_each = local.databases
#   length   = 16
#   special  = false
# }

resource "kubectl_manifest" "postgres-secrets" {
  yaml_body = templatefile("./k8s/postgres-secrets.tftpl", {
    namespace = kubernetes_namespace.postgres.id
    databases = local.databases_map
  })
}
