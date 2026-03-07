variable "ami_name" {
  description = "AMI name filter"
  type        = string
}

variable "ami_owner" {
  description = "AMI owner"
  type        = string
}

variable "ami_architecture" {
  description = "AMI architecture"
  type        = string
}

variable "ami_os_type" {
  description = "AMI OS type"
  type        = string
}

variable "baking_recipe_playbook" {
  description = "Baking recipe playbook"
  type        = string
}

variable "application_name" {
  description = "Application name"
  type        = string
}
