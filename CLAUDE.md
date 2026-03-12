# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **GitHub Composite Action** (`action.yml`) that automates AWS AMI baking. It accepts AMI filter criteria and a baking recipe (Ansible playbook), then uses Terraform to invoke the external `bk-bake-ami-module` to fetch a base AMI, customize it, and return the resulting AMI details.

## Commands

### Pre-commit / Linting
```bash
pre-commit run --all-files
```

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
    → external module: BakeFoundry/bk-bake-ami-module@e886d3c6
        → fetches base AMI (filtered by name/owner/architecture/os_type)
        → runs Ansible playbook (baking_recipe)
        → creates baked AMI
    → terraform outputs (ami_id, ami_name, ami_arn)
    → action.yml step outputs
```

### Key Files

- **`action.yml`**: Composite action definition — inputs, AWS OIDC auth, Terraform execution, output extraction
- **`terraform/main.tf`**: AWS provider (us-east-1) + instantiates `bk-bake-ami-module`
- **`terraform/variables.tf`**: 7 input variables mirroring action inputs
- **`terraform/outputs.tf`**: Passes `ami_id`, `ami_name`, `ami_arn` from module back to action

### Action Inputs

| Input | Description |
|---|---|
| `ami_name` | Base AMI name filter pattern |
| `ami_owner` | AMI owner (e.g. `"amazon"`) |
| `ami_architecture` | Architecture (e.g. `"x86_64"`) |
| `ami_os_type` | OS type (e.g. `"linux"`) |
| `role_to_assume` | AWS IAM role ARN (OIDC) |
| `baking_recipe_playbook` | Absolute path to Ansible playbook |
| `application_name` | Application identifier for the AMI |
| `version_tag` | Version tag for the baked AMI |

### External Module Dependency

The Terraform module source is pinned to a specific commit of `BakeFoundry/bk-bake-ami-module`. To upgrade the module, update the `ref=` value in `terraform/main.tf`.

### CI/CD Workflows

- **`pre-commit.yml`**: Runs pre-commit hooks on all pushes/PRs
- **`version.yml`**: Semantic versioning and automated releases via `bakefoundry/bk-release-workflow@v1` (triggered on push/PR to main)
- **`notify-pr.yml`**: Sends Discord notifications on PR events via `BakeFoundry/bk-bake-pr-reviewes@v1`

## Important Notes

- `baking_recipe_playbook` must be an **absolute path** (use `${{ github.workspace }}/path/to/playbook.yml` in callers)
- AWS authentication uses OIDC — no static credentials; `role_to_assume` must have appropriate permissions
- Terraform state is not stored remotely in this repo; it runs ephemerally within the GitHub Actions runner
