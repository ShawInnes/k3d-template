variable "environments" {
  default = ["development", "test", "production"]
}

variable "domain" {
  default = "azure.shawinnes.com"
}

resource "kubernetes_namespace" "whoami" {
  for_each = toset(var.environments)

  metadata {
    name = each.key
  }
}

resource "kubernetes_config_map" "whoami" {
  for_each = toset(var.environments)

  metadata {
    name      = "whoami"
    namespace = kubernetes_namespace.whoami[each.key].metadata[0].name
  }

  data = {
    environment = "configmap-${each.key}"
  }
}

resource "kubernetes_deployment" "whoami" {
  for_each = toset(var.environments)

  metadata {
    name      = "whoami"
    namespace = kubernetes_namespace.whoami[each.key].metadata[0].name

    labels = {
      app = "whoami"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "whoami"
      }
    }
    template {
      metadata {
        labels = {
          app             = "whoami"
          aadpodidbinding = "${each.key}-msi"
        }
      }
      spec {
        container {
          image = "containous/whoami"
          name  = "whoami"

          env {
            name = "WHOAMI_NAME"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.whoami[each.key].metadata[0].name
                key  = "environment"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "whoami" {
  for_each = toset(var.environments)

  metadata {
    name      = "whoami"
    namespace = kubernetes_namespace.whoami[each.key].metadata[0].name
  }

  spec {
    port {
      port        = 80
      target_port = 80
    }
    selector = {
      app = "whoami"
    }
  }
}

resource "kubernetes_ingress" "whoami" {
  for_each = toset(var.environments)

  metadata {
    name      = "whoami"
    namespace = kubernetes_namespace.whoami[each.key].metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "${each.key}.${var.domain}"

      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_deployment.whoami[each.key].metadata[0].labels.app
            service_port = 80
          }
        }
      }
    }

    tls {
      hosts       = ["${each.key}.${var.domain}"]
      secret_name = "${each.key}-ingress-cert"
    }
  }
}

resource "azurerm_user_assigned_identity" "msi" {
  for_each = toset(var.environments)

  resource_group_name = "MC_hey-lemonade_hey-lemonade_australiaeast"
  location            = "australiaeast"

  name = "${each.key}-msi"
}


resource "kubernetes_manifest" "azureidentity" {
  for_each = toset(var.environments)

  manifest = {
    apiVersion = "aadpodidentity.k8s.io/v1"
    kind       = "AzureIdentity"
    metadata = {
      name      = "${each.key}-msi"
      namespace = kubernetes_namespace.whoami[each.key].metadata[0].name
    }
    spec = {
      type       = 0
      resourceID = azurerm_user_assigned_identity.msi[each.key].id
      clientID   = azurerm_user_assigned_identity.msi[each.key].client_id
    }
  }
}


resource "kubernetes_manifest" "azureidentitybinding" {
  for_each = toset(var.environments)

  manifest = {
    apiVersion = "aadpodidentity.k8s.io/v1"
    kind       = "AzureIdentityBinding"
    metadata = {
      name      = "${each.key}-msi-binding"
      namespace = kubernetes_namespace.whoami[each.key].metadata[0].name
    }
    spec = {
      azureIdentity = "${each.key}-msi"
      selector      = "${each.key}-msi"
    }
  }
}
