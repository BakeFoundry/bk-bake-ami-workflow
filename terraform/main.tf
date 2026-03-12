provider "aws" {
  region = "us-east-1"
}

module "bake-ami" {
  source                 = "github.com/BakeFoundry/bk-bake-ami-module?ref=f1050330dbffbf9e1cdc058b48a70bfab13ff993"
  ami_name               = var.ami_name
  ami_owner              = var.ami_owner
  ami_architecture       = var.ami_architecture
  ami_os_type            = var.ami_os_type
  baking_recipe_playbook = var.baking_recipe_playbook
  application_name       = var.application_name
}

module "ami_builder" {
  source = "github.com/BakeFoundry/bk-bake-ami-module?ref=f1050330dbffbf9e1cdc058b48a70bfab13ff993"

  depends_on = [module.ami_fetcher]

  source_ami_id          = module.ami_fetcher.ami_id
  baking_recipe_playbook = var.baking_recipe_playbook
  application_name       = var.application_name
  version_tag            = var.version_tag
}
