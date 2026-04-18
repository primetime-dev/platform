output "cluster_id" {
  description = "DigitalOcean Kubernetes cluster ID."
  value       = digitalocean_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "DigitalOcean Kubernetes cluster name."
  value       = digitalocean_kubernetes_cluster.this.name
}

output "cluster_region" {
  description = "DigitalOcean Kubernetes cluster region."
  value       = digitalocean_kubernetes_cluster.this.region
}

output "kubernetes_version" {
  description = "DigitalOcean Kubernetes cluster version slug."
  value       = digitalocean_kubernetes_cluster.this.version
}
