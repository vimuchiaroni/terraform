output "k8s_endpoint" {
  value = digitalocean_kubernetes_cluster.k8s.endpoint
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.k8s.kube_config
  sensitive = true
}

