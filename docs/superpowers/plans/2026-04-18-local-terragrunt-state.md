# Local Terragrunt State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a root `.gitignore` and configure Terragrunt to write local Terraform state into predictable per-environment files under `.state/` in the `platform` repo.

**Architecture:** The root `.gitignore` owns all generated Terraform and Terragrunt artifacts for this repository. `terragrunt/root.hcl` generates a backend configuration so each environment uses a repo-local local backend path derived from its directory name, producing `.state/testing/terraform.tfstate` and `.state/production/terraform.tfstate` without duplicating backend blocks in each environment file.

**Tech Stack:** Terragrunt, Terraform, gitignore

---

## File Map

### Create

- `/Users/max.kryvych/Projects/primetime-dev/platform/.gitignore`

### Modify

- `/Users/max.kryvych/Projects/primetime-dev/platform/terragrunt/root.hcl`
- `/Users/max.kryvych/Projects/primetime-dev/platform/README.md`

## Task 1: Add Root Ignore Rules For Generated Infrastructure Files

**Files:**
- Create: `/Users/max.kryvych/Projects/primetime-dev/platform/.gitignore`

- [ ] **Step 1: Add ignore rules for repo-local state and generated Terraform files**

```gitignore
.state/
.terragrunt-cache/
.terraform/
.terraform.lock.hcl
*.tfstate
*.tfstate.*
```

- [ ] **Step 2: Inspect the new ignore file**

Run:
```bash
cd /Users/max.kryvych/Projects/primetime-dev/platform
sed -n '1,120p' .gitignore
```

Expected: the file contains only the infrastructure-generated artifacts defined in the approved design.

## Task 2: Generate A Local Backend From Terragrunt Root

**Files:**
- Modify: `/Users/max.kryvych/Projects/primetime-dev/platform/terragrunt/root.hcl`

- [ ] **Step 1: Add a local state path derived from the environment directory**

```hcl
locals {
  environment         = basename(get_terragrunt_dir())
  region              = get_env("DOKS_REGION", "ams3")
  kubernetes_version  = trimspace(
    run_cmd(
      "sh",
      "-c",
      "if [ -n \"${DOKS_KUBERNETES_VERSION:-}\" ]; then printf '%s' \"$DOKS_KUBERNETES_VERSION\"; else doctl kubernetes options versions --format Slug --no-header | head -n 1; fi"
    )
  )
  maintenance_policy = {
    day        = "sunday"
    start_time = "02:00"
  }
  state_path = "${get_parent_terragrunt_dir()}/../.state/${local.environment}/terraform.tfstate"
}
```

- [ ] **Step 2: Add generated backend configuration**

```hcl
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
```

- [ ] **Step 3: Inspect the updated Terragrunt root config**

Run:
```bash
cd /Users/max.kryvych/Projects/primetime-dev/platform
sed -n '1,240p' terragrunt/root.hcl
```

Expected: the file still points to the shared module, still derives Kubernetes version the same way, and now generates a local backend with per-environment state paths.

## Task 3: Document The Local State Behavior

**Files:**
- Modify: `/Users/max.kryvych/Projects/primetime-dev/platform/README.md`

- [ ] **Step 1: Add a short section describing local state**

```markdown
## Local State

Terragrunt generates a local Terraform backend for each environment and stores state in
repo-local paths:

- `.state/testing/terraform.tfstate`
- `.state/production/terraform.tfstate`

Generated Terraform and Terragrunt artifacts are ignored by the root `.gitignore`.
```

- [ ] **Step 2: Re-read the README to keep the scope narrow**

Check that the README documents:

- local state only
- no remote backend
- no locking service

Expected: the repo continues to present this as a local demo-friendly state layout, not a production backend strategy.

## Task 4: Verify The Config Shape

**Files:**
- Create: `/Users/max.kryvych/Projects/primetime-dev/platform/.gitignore`
- Modify: `/Users/max.kryvych/Projects/primetime-dev/platform/terragrunt/root.hcl`
- Modify: `/Users/max.kryvych/Projects/primetime-dev/platform/README.md`

- [ ] **Step 1: Review the three changed files together**

Run:
```bash
cd /Users/max.kryvych/Projects/primetime-dev/platform
sed -n '1,120p' .gitignore
printf '\n---\n'
sed -n '1,240p' terragrunt/root.hcl
printf '\n---\n'
sed -n '1,260p' README.md
```

Expected: ignore rules, backend generation, and docs all describe the same `.state/<environment>/terraform.tfstate` layout.

- [ ] **Step 2: Validate the Terragrunt task metadata still points at the same env workflow**

Run:
```bash
cd /Users/max.kryvych/Projects/primetime-dev/platform
MISE_STATE_DIR=/Users/max.kryvych/Projects/primetime-dev/platform/.mise-state mise trust /Users/max.kryvych/Projects/primetime-dev/platform/mise.toml
MISE_STATE_DIR=/Users/max.kryvych/Projects/primetime-dev/platform/.mise-state mise tasks validate
```

Expected: the `mise` task configuration still validates after the Terragrunt root file change.

- [ ] **Step 3: Remove the temporary local `mise` state used only for sandbox validation**

Run:
```bash
cd /Users/max.kryvych/Projects/primetime-dev/platform
rm -r .mise-state
```

Expected: no repo-local validation artifacts remain after verification.
