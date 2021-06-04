resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = var.k8s_name
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.20.2-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 1

  }
}