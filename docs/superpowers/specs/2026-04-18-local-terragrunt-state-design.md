# Local Terragrunt State Design

## Goal

Add repo-local ignore rules and an explicit local Terraform state layout so the
`platform` repository keeps generated Terragrunt and Terraform artifacts out of git and
stores state in predictable per-environment paths.

## Outcome

After this work:

- the repo has a root `.gitignore`
- Terraform and Terragrunt generated files are ignored
- Terragrunt writes local state into a repo-local `.state/` directory
- `testing` and `production` use separate state files

## Design Summary

This change should stay small and explicit:

- add one root `.gitignore`
- update `terragrunt/root.hcl` to generate a local backend configuration
- keep one state file per environment under `.state/`

Recommended state layout:

- `.state/testing/terraform.tfstate`
- `.state/production/terraform.tfstate`

## Ignore Scope

The `.gitignore` should cover:

- `.state/`
- `.terragrunt-cache/`
- `.terraform/`
- `.terraform.lock.hcl`
- `*.tfstate`
- `*.tfstate.*`

This repo does not need to commit any generated Terraform working files.

## Backend Scope

Terragrunt should generate a local backend file for each environment so Terraform uses
the repo-local `.state/` path instead of environment working directories or ad hoc
defaults.

The backend path should derive from the Terragrunt directory name so `testing` and
`production` automatically separate their state files without duplicating config in
each environment file.

## Non-Goals

This change should not:

- introduce remote state
- add locking services
- change the cluster module inputs
- change the `mise` workflow beyond naturally benefiting from the new ignore rules

## Decision

Use a root `.gitignore` plus Terragrunt-generated local backend configuration to store
per-environment state under `.state/` in the repository root.
