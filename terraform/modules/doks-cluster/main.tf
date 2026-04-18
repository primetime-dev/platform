terraform {
  required_version = ">= 1.6.0"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

resource "digitalocean_kubernetes_cluster" "this" {
  name          = var.cluster_name
  region        = var.region
  version       = var.kubernetes_version
  auto_upgrade  = var.auto_upgrade
  surge_upgrade = var.surge_upgrade
  tags          = var.tags

  maintenance_policy {
    day        = var.maintenance_policy.day
    start_time = var.maintenance_policy.start_time
  }

  node_pool {
    name       = var.node_pool_name
    size       = var.node_size
    node_count = var.node_count
    tags       = var.tags
  }
}
