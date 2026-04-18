variable "cluster_name" {
  description = "Name of the DigitalOcean Kubernetes cluster."
  type        = string
}

variable "region" {
  description = "DigitalOcean region slug for the cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "DigitalOcean Kubernetes version slug for the cluster."
  type        = string
}

variable "node_pool_name" {
  description = "Name of the default node pool."
  type        = string
}

variable "node_size" {
  description = "DigitalOcean Droplet size slug for worker nodes."
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
}

variable "tags" {
  description = "Tags applied to the cluster and default node pool."
  type        = list(string)
  default     = []
}

variable "auto_upgrade" {
  description = "Whether cluster auto-upgrades are enabled."
  type        = bool
  default     = true
}

variable "surge_upgrade" {
  description = "Whether surge upgrades are enabled."
  type        = bool
  default     = true
}

variable "maintenance_policy" {
  description = "Weekly maintenance window for cluster upgrades."
  type = object({
    day        = string
    start_time = string
  })
}
