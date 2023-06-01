
data "kubernetes_namespace" "environment" {
  for_each = toset(var.environments)

  metadata {
    name = each.key
  }
}
