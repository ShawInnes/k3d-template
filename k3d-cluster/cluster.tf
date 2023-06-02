resource "k3d_cluster" "dev" {
  name    = "dev"
  servers = 1
  agents  = 2

  network = "k3d-dev-net"

  # volume {
  #   source      = "${path.cwd}/volume"
  #   destination = "/mnt/k3dvol"
  #   node_filters = ["agent:*"]
  # }

  port {
    host_port      = 443
    container_port = 443
    node_filters = [
      "loadbalancer",
    ]
  }

  port {
    host_port      = 80
    container_port = 80
    node_filters = [
      "loadbalancer",
    ]
  }

  port {
    host_port      = 5432
    container_port = 5432
    node_filters = [
      "loadbalancer",
    ]
  }

  port {
    host_port      = 6379
    container_port = 6379
    node_filters = [
      "loadbalancer",
    ]
  }

  k3d {
    disable_load_balancer = false
    disable_image_volume  = false
  }

  k3s {
    extra_args {
      arg          = "--disable=traefik"
      node_filters = ["server:*"]
    }
  }

  kubeconfig {
    update_default_kubeconfig = true
    switch_current_context    = false
  }

  registries {
    create {
      name = "registry.localtest.me"
      host_port = 5500
    }
  }
}

