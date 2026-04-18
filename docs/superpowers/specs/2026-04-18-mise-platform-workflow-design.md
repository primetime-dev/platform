# Mise Platform Workflow Design

## Goal

Add a single `mise` entry point to the `platform` repository so required CLI tools and
common demo workflows can be installed and run from one place.

## Outcome

After this work:

- the repo has one root `mise.toml`
- `mise install` provisions the core tools used by this repository
- `mise run ...` exposes common platform workflows as named tasks
- the repo README documents the `mise` workflow as the preferred local entry point

## Design Summary

The design stays intentionally small:

- one root `mise.toml`
- no duplicate wrapper shell scripts for Terragrunt commands
- tasks wrap the existing `bootstrap` scripts and Terragrunt directory structure
- the config covers only tools this repo actually uses

## Tool Scope

The `mise` config should manage these tools:

- `terraform`
- `terragrunt`
- `doctl`
- `kubectl`
- `helm`
- `shellcheck`
- `shfmt`

Versions should be pinned explicitly in `mise.toml` so the repo is reproducible and
the toolchain does not drift silently.

## Task Scope

The `mise` config should expose these tasks:

- `fmt`
- `lint`
- `plan-testing`
- `apply-testing`
- `destroy-testing`
- `bootstrap`
- `dashboard-token`
- `dashboard-port-forward`

### `fmt`

Formats shell scripts and Terraform files in this repo.

### `lint`

Runs shell linting and Terraform validation commands that fit this repo.

### `plan-testing`

Runs the Terragrunt plan flow in `terragrunt/testing`.

### `apply-testing`

Runs the Terragrunt apply flow in `terragrunt/testing`.

### `destroy-testing`

Runs the Terragrunt destroy flow in `terragrunt/testing`.

### `bootstrap`

Runs the namespace bootstrap and dashboard installation scripts in sequence.

### Dashboard tasks

Two small dashboard tasks keep the post-bootstrap flow obvious:

- `dashboard-token`
- `dashboard-port-forward`

This is clearer than one opaque shell blob that tries to do both.

## Documentation Scope

The README should explain:

- `mise install`
- the common `mise run ...` commands
- that `DIGITALOCEAN_TOKEN` and kubeconfig are still operator-managed inputs

## Non-Goals

This change should not:

- replace the existing bootstrap scripts
- add new deployment behavior
- add ingress or other cluster add-ons
- create multiple `mise` config files

## Decision

Use one root `mise.toml` with pinned tools and a small set of tasks that map directly
to the repo's existing Terraform, Terragrunt, and bootstrap workflow.
