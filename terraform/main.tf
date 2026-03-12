provider "aws" {
  region = "us-east-1"
}

module "ami_fetcher" {
  source                 = "github.com/BakeFoundry/bk-bake-ami-module?ref=e886d3c6f419f78aa4d0419639cf920e6c9a10d5"
  ami_name               = var.ami_name
  ami_owner              = var.ami_owner
  ami_architecture       = var.ami_architecture
  ami_os_type            = var.ami_os_type
  baking_recipe_playbook = var.baking_recipe_playbook
  application_name       = var.application_name
}

module "ami_builder" {
  source = "github.com/BakeFoundry/bk-bake-ami-module?ref=e886d3c6f419f78aa4d0419639cf920e6c9a10d5"

  depends_on = [module.ami_fetcher]

  source_ami_id          = module.ami_fetcher.ami_id
  baking_recipe_playbook = var.baking_recipe_playbook
  application_name       = var.application_name
  version_tag            = var.version_tag
}
