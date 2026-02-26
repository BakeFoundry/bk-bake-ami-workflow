# Bake AMI Workflow

This GitHub Composite Action orchestrates the AMI baking process by calling the `bk-bake-ami` module with predefined inputs and logic.

## Usage

Add the following step to your GitHub Actions workflow:

```yaml
- name: Bake AMI
  uses: BakeFoundry/bk-bake-ami-workflow@v1
  with:
    ami_name: 'my-custom-ami'
    ami_owner: 'amazon'
    architecture: 'x86_64'
    os_type: 'linux'
    aws_region: 'us-east-1'
    aws_role_arn: 'arn:aws:iam::123456789012:role/my-github-actions-role'
    vpc_name: 'my-custom-vpc'
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `ami_name` | Name of the AMI | Yes | - |
| `ami_owner` | Owner of the AMI (e.g., `amazon`) | Yes | - |
| `architecture` | Architecture of the AMI | Yes | `x86_64` |
| `os_type` | Operating System type | Yes | `linux` |
| `aws_region` | AWS Region for the baking process | Yes | `us-east-1` |
| `aws_role_arn` | AWS Role ARN to assume | Yes | - |
| `vpc_name` | Name of the VPC to check/create | Yes | `bake-vpc` |
| `github_token` | GitHub token for authentication | Yes | - |

## Outputs

| Output | Description |
|--------|-------------|
| `ami_id` | The ID of the baked AMI |
| `ami_name` | The name of the baked AMI |
| `ami_arn` | The ARN of the baked AMI |

## Logic

The action leverages several modules to perform the following:
1.  **VPC Management**: Checks if a VPC with `vpc_name` exists. If not, it calls the `bk-create-vpc` module to create one.
2.  **AMI Fetching**: Uses Terraform to identify the correct base AMI based on filters.
3.  **Baking**: Executes the baking process using the specified inputs.
4.  **Authentication**: Uses the provided `github_token` for repository access and module calls.

## Folder Structure

```text
bk-bake-ami-workflow/
├── terraform/          # Terraform configurations for AMI data fetching
│   ├── main.tf
│   ├── outputs.tf
│   └── providers.tf
├── action.yml          # Composite action definition
└── README.md           # Documentation
```
