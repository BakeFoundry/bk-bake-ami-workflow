# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **GitHub Composite Action** (`action.yml`) that automates AWS AMI baking. It accepts AMI filter criteria and a baking recipe (Ansible playbook), then uses Terraform to invoke the external `bk-bake-ami-module` to fetch a base AMI, customize it, and return the resulting AMI details.

## Commands

### Pre-commit / Linting (requires Docker)
```bash
pre-commit run --all-files
```
The terraform-fmt and checkov hooks run via Docker images, so Docker must be running.

### Terraform (manual validation)
```bash
cd terraform
terraform init
terraform validate
terraform fmt -recursive .
```

### Infrastructure Security Scanning
```bash
docker run --rm -v $(pwd):/tf bridgecrew/checkov:latest -d /tf
```

## Architecture

### Data Flow

```
action.yml inputs
    → TF_VAR_* environment variables
    → terraform/ (init + apply)
    → module "bake-ami" (BakeFoundry/bk-bake-ami-module@f1050330)
        → fetches base AMI (filtered by name/owner/architecture/os_type)
        → runs Ansible playbook (baking_recipe)
        → creates baked AMI
    → terraform outputs (ami_id, ami_name, ami_arn)
    → action.yml step outputs via $GITHUB_OUTPUT
```

### Key Files

- **`action.yml`**: Composite action definition — inputs, AWS OIDC auth, Terraform execution, output extraction
- **`terraform/main.tf`**: AWS provider (us-east-1) + instantiates `bk-bake-ami-module` as `module.bake-ami`
- **`terraform/variables.tf`**: Input variables mirroring action inputs
- **`terraform/outputs.tf`**: Passes `ami_id`, `ami_name`, `ami_arn` from module back to action

### Known Inconsistencies

- `README.md` documents outdated inputs (e.g. `vpc_name`, `github_token`, `aws_region`) that no longer exist in `action.yml`

### External Module Dependency

The Terraform module source is pinned to commit `d3fd8ac3d62e6b8e147642d26b3eaf12f5772e2b` of `BakeFoundry/bk-bake-ami-module`. To upgrade the module, update the `ref=` value in `terraform/main.tf`.

### CI/CD Workflows

- **`pre-commit.yml`**: Runs pre-commit hooks on all pushes/PRs
- **`version.yml`**: Semantic versioning via `bakefoundry/bk-release-workflow@v1` — runs `dry-run` on PRs, real release on push to main
- **`notify-pr.yml`**: Discord notifications on PR events via `BakeFoundry/bk-bake-pr-reviewes@v1`

## Important Notes

- `baking_recipe_playbook` must be an **absolute path** — the action prepends `${{ github.workspace }}/` to the input value
- AWS authentication uses OIDC — no static credentials; `role_to_assume` must have appropriate permissions
- Terraform state is not stored remotely; it runs ephemerally within the GitHub Actions runner
- Terraform is pinned to `$GITHUB_ACTION_PATH/terraform` so it resolves relative to the action, not the caller's workspace
