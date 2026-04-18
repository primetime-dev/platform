terraform {
  source = "${get_parent_terragrunt_dir()}/../terraform/modules/doks-cluster"
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "local" {
    path = "${local.state_path}"
  }
}
EOF
}

locals {
  environment = basename(get_terragrunt_dir())
  region      = get_env("DOKS_REGION", "ams3")
  kubernetes_version = "1.31.2-do.0"
  maintenance_policy = {
    day        = "sunday"
    start_time = "02:00"
  }
  state_path = "${get_parent_terragrunt_dir()}/../.state/${local.environment}/terraform.tfstate"
}

inputs = {
  region             = local.region
  kubernetes_version = local.kubernetes_version
  auto_upgrade       = true
  surge_upgrade      = true
  maintenance_policy = local.maintenance_policy
}
