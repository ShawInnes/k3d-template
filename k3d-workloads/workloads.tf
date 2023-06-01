
resource "kubernetes_config_map" "whoami" {
  for_each = toset(var.environments)

  metadata {
    name      = "whoami"
    namespace = data.kubernetes_namespace.environment[each.key].metadata[0].name
  }

  data = {
    environment = "configmap-${each.key}"
  }
}

resource "kubernetes_deployment" "whoami" {
  for_each = toset(var.environments)

  metadata {
    name      = "whoami"
    namespace = data.kubernetes_namespace.environment[each.key].metadata[0].name

    annotations = {
      "reloader.stakater.com/auto" : "true"
    }

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
          app = "whoami"
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
    namespace = data.kubernetes_namespace.environment[each.key].metadata[0].name
  }

  spec {
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "NodePort"
    selector = {
      app = "whoami"
    }
  }
}

resource "kubernetes_ingress_v1" "whoami" {
  wait_for_load_balancer = true

  for_each = toset(var.environments)

  metadata {
    name      = "whoami"
    namespace = data.kubernetes_namespace.environment[each.key].metadata[0].name
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "${each.key}.localtest.me"

      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_deployment.whoami[each.key].metadata[0].labels.app
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
