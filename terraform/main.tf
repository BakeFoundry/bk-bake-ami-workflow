provider "aws" {
  region = "us-east-1"
}

module "bake-ami" {
  source                 = "github.com/BakeFoundry/bk-bake-ami-module?ref=8f3998ff1a3d20786d9358d4fb2ff952f0c5268c"
  ami_name               = var.ami_name
  ami_owner              = var.ami_owner
  ami_architecture       = var.ami_architecture
  ami_os_type            = var.ami_os_type
  baking_recipe_playbook = var.baking_recipe_playbook
  application_name       = var.application_name
  version_tag            = var.version_tag
}
