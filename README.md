# platform

This repository owns platform-layer assets for the demo environment story.

## Scope

- reusable Terraform module for a DigitalOcean Kubernetes cluster
- Terragrunt environment separation for `testing` and `production`
- shared namespace manifests
- local bootstrap scripts for namespaces and Headlamp

## Out of Scope

- application Deployments
- application Services
- ingress controllers
- GitOps controllers
- centralized deploy workflows

Application repos own their own plain Kubernetes manifests under `k8s/`.

## Environment Layout

- `terraform/modules/doks-cluster`: shared DOKS cluster module
- `terragrunt/testing`: low-cost demo environment
- `terragrunt/production`: production-shaped example environment
- `bootstrap`: local post-cluster setup scripts

## Tooling

The preferred local entry point for this repo is `mise`.

```bash
mise install
```

This installs the pinned versions of:

- `terraform`
- `terragrunt`
- `doctl`
- `kubectl`
- `helm`
- `shellcheck`
- `shfmt`

Tool versions are pinned in [`mise.toml`](/Users/max.kryvych/Projects/primetime-dev/platform/mise.toml:1).
Because upstream version lookup was blocked in the sandbox used to assemble this repo,
the Terraform pin should be treated as an intentional starting point and bumped
deliberately on a machine with working networked tool resolution.

## Operator Inputs

- `DIGITALOCEAN_TOKEN` must be configured in your shell
- kubeconfig must still be saved with `doctl kubernetes cluster kubeconfig save ...`
- Kubernetes version is pinned in [`terragrunt/root.hcl`](/Users/max.kryvych/Projects/primetime-dev/platform/terragrunt/root.hcl:18)
  and should be bumped deliberately when updating the cluster

## Common Tasks

```bash
mise run fmt
mise run lint
mise run plan-testing
mise run apply-testing
mise run destroy-testing
mise run bootstrap
mise run headlamp-token
mise run headlamp-port-forward
```

## Local State

Terragrunt generates a local Terraform backend for each environment and stores state in
repo-local paths:

- `.state/testing/terraform.tfstate`
- `.state/production/terraform.tfstate`

Generated Terraform and Terragrunt artifacts are ignored by the root `.gitignore`.

## Create The Testing Cluster

```bash
mise run plan-testing
mise run apply-testing
```

## Save Kubeconfig

```bash
doctl kubernetes cluster kubeconfig save primetime-testing
```

## Bootstrap Shared Namespaces And Headlamp

```bash
mise run bootstrap
```

## Open Headlamp

```bash
mise run headlamp-token
mise run headlamp-port-forward
```

Then open `http://localhost:4466`.

If the Headlamp service port differs in a later chart release, inspect the namespace
services and use the service and port printed by the install script.

## Destroy The Testing Cluster

```bash
mise run destroy-testing
```
