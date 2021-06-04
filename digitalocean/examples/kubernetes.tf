resource "kubernetes_namespace" "k8s" {
  metadata {
    name = "terraformns"
  }
}