include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  cluster_name   = "primetime-production"
  node_pool_name = "production-default"
  node_size      = "s-2vcpu-4gb"
  node_count     = 2
  tags = [
    "primetime",
    "env:production",
  ]
}
