include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  cluster_name   = "primetime-testing"
  node_pool_name = "testing-default"
  node_size      = "s-2vcpu-2gb"
  node_count     = 1
  tags = [
    "primetime",
    "env:testing",
  ]
}
