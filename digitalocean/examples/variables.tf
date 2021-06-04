variable "k8s_name" {
  type        = string
  description = "Nome do cluster kubernetes"
  default     = "terrak8s"
}

variable "region" {
  type        = string
  description = "Região dos recursos"
  default     = "nyc1"
}