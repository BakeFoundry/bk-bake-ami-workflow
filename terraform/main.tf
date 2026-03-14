provider "aws" {
  region = "us-east-1"
}

module "bake-ami" {
  source                 = "github.com/BakeFoundry/bk-bake-ami-module?ref=d3fd8ac3d62e6b8e147642d26b3eaf12f5772e2b"
  ami_name               = var.ami_name
  ami_owner              = var.ami_owner
  ami_architecture       = var.ami_architecture
  ami_os_type            = var.ami_os_type
  baking_recipe_playbook = var.baking_recipe_playbook
  application_name       = var.application_name
  version_tag            = var.version_tag
}
