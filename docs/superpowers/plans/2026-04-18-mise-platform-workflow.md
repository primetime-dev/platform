# Mise Platform Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a root `mise.toml` to the `platform` repo so contributors can install the required CLI tools and run the common Terragrunt and bootstrap workflows from one place.

**Architecture:** `mise.toml` becomes the repo's single workflow entry point. It pins the toolchain used by this repository and defines tasks that wrap the existing Terraform, Terragrunt, and bootstrap layout without replacing the current scripts. The README is updated to prefer `mise install` and `mise run ...` over ad hoc local command sequences.

**Tech Stack:** mise, Terraform, Terragrunt, Bash, doctl, kubectl, helm, shellcheck, shfmt

---

## File Map

### Create

- `/Users/max.kryvych/Projects/primetime-dev/platform/mise.toml`

### Modify

- `/Users/max.kryvych/Projects/primetime-dev/platform/README.md`

## Task 1: Add Root Mise Tooling And Task Definitions

**Files:**
- Create: `/Users/max.kryvych/Projects/primetime-dev/platform/mise.toml`

- [ ] **Step 1: Create the pinned tool definitions**

```toml
[tools]
terraform = "1.9.8"
terragrunt = "0.67.16"
doctl = "1.115.0"
kubectl = "1.31.2"
helm = "3.16.2"
shellcheck = "0.10.0"
shfmt = "3.10.0"
```

- [ ] **Step 2: Add the formatting and lint tasks**

```toml
[tasks.fmt]
description = "Format shell scripts and Terraform files"
run = """
shfmt -i 2 -w bootstrap/*.sh
terraform fmt -recursive terraform
"""

[tasks.lint]
description = "Lint shell scripts and validate Terraform module formatting"
run = """
shellcheck bootstrap/*.sh
terraform fmt -check -recursive terraform
"""
```

- [ ] **Step 3: Add the Terragrunt workflow tasks**

```toml
[tasks.plan-testing]
description = "Plan the testing cluster with Terragrunt"
dir = "terragrunt/testing"
run = "terragrunt plan"

[tasks.apply-testing]
description = "Apply the testing cluster with Terragrunt"
dir = "terragrunt/testing"
run = "terragrunt apply"

[tasks.destroy-testing]
description = "Destroy the testing cluster with Terragrunt"
dir = "terragrunt/testing"
run = "terragrunt destroy"
```

- [ ] **Step 4: Add the bootstrap and dashboard helper tasks**

```toml
[tasks.bootstrap]
description = "Apply shared namespaces and install the Kubernetes Dashboard"
run = """
./bootstrap/apply-namespaces.sh
./bootstrap/install-dashboard.sh
"""

[tasks.dashboard-token]
description = "Create a Kubernetes Dashboard login token"
run = "kubectl -n kubernetes-dashboard create token admin-user"

[tasks.dashboard-port-forward]
description = "Port-forward the Kubernetes Dashboard proxy service"
run = "kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443"
```

- [ ] **Step 5: Format and inspect the `mise` config**

Run:
```bash
cd /Users/max.kryvych/Projects/primetime-dev/platform
mise fmt
sed -n '1,240p' mise.toml
```

Expected: `mise.toml` is formatted and contains the pinned tools plus the task set from the approved design.

## Task 2: Update The Platform README To Prefer Mise

**Files:**
- Modify: `/Users/max.kryvych/Projects/primetime-dev/platform/README.md`

- [ ] **Step 1: Replace the manual prerequisites section with the `mise` entry point**

```markdown
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
```

- [ ] **Step 2: Add the common `mise run ...` workflow commands**

```markdown
## Common Tasks

```bash
mise run fmt
mise run lint
mise run plan-testing
mise run apply-testing
mise run destroy-testing
mise run bootstrap
mise run dashboard-token
mise run dashboard-port-forward
```
```

- [ ] **Step 3: Keep the operator-managed prerequisites explicit**

Add README text stating:

- `DIGITALOCEAN_TOKEN` must still be exported by the operator
- kubeconfig must still be saved with `doctl kubernetes cluster kubeconfig save ...`
- `DOKS_KUBERNETES_VERSION` may be exported manually, or Terragrunt will derive it via `doctl`

- [ ] **Step 4: Re-read the README for scope drift**

Check that the updated README does not imply:

- new deployment features
- ingress support
- Terraform-managed dashboard add-ons

Expected: README stays aligned with the approved platform and `mise` design.

## Task 3: Verify The Mise Workflow

**Files:**
- Create: `/Users/max.kryvych/Projects/primetime-dev/platform/mise.toml`
- Modify: `/Users/max.kryvych/Projects/primetime-dev/platform/README.md`

- [ ] **Step 1: Verify `mise` can read the config and list tasks**

Run:
```bash
cd /Users/max.kryvych/Projects/primetime-dev/platform
mise tasks ls
```

Expected: the output lists `fmt`, `lint`, `plan-testing`, `apply-testing`,
`destroy-testing`, `bootstrap`, `dashboard-token`, and `dashboard-port-forward`.

- [ ] **Step 2: Run the safe local tasks that do not require cloud access**

Run:
```bash
cd /Users/max.kryvych/Projects/primetime-dev/platform
mise run fmt
mise run lint
```

Expected: the formatting and lint tasks complete successfully in the local repo.

- [ ] **Step 3: Document the cloud-dependent tasks without claiming they were executed**

Run:
```bash
cd /Users/max.kryvych/Projects/primetime-dev/platform
mise tasks info plan-testing
mise tasks info apply-testing
mise tasks info destroy-testing
mise tasks info bootstrap
```

Expected: each task resolves to the intended Terragrunt or bootstrap command sequence.

- [ ] **Step 4: Commit the `mise` workflow change as one logical update**

Run:
```bash
cd /Users/max.kryvych/Projects/primetime-dev/platform
git add mise.toml README.md
git commit -m "feat: add mise workflow for platform tooling"
```

Expected: one commit captures the repo-local toolchain and task entry point.
