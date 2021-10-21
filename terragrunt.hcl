# iam_role = "arn:aws:iam::707026380822:role/global-admin-role"
#iam_role = "arn:aws:iam::335827566077:role/FullAccessRole-DeleteLater"

remote_state {
  backend = "local"
  config  = {}
  #---------------------------------------------------#
  # The following vars must be changed per environment
  #---------------------------------------------------#
  # config = {
  #   key            = "${path_relative_to_include()}/terraform.tfstate"
  #   bucket         = "aa-terraform-707026380822-dev"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}


terraform {
  before_hook "get_defaults" {
    commands = ["init", "get_terraform_commands_that_need_vars()", "init-from-module"]
    # execute  = ["cp", "-i", "${get_parent_terragrunt_dir()}/default.tf", "."]
    execute = ["echo", "Done"]
  }

  before_hook "get_environment" {
    commands = ["init", "get_terraform_commands_that_need_vars()"]
    # execute  = ["cp", "${get_parent_terragrunt_dir()}/environment.tf", "."]
    execute = ["echo", "${get_parent_terragrunt_dir()}/environment.tf"]
  }

  extra_arguments "parallelize" {
    commands  = ["get_terraform_commands_that_need_vars()"]
    arguments = ["-parallelism=1000"]
  }

  extra_arguments "always_local_plan" {
    commands  = ["plan"]
    arguments = ["-out=./saved-plan"]
  }

  extra_arguments "force_saved_plan" {
    commands  = ["apply"]
    arguments = ["./saved-plan"]
  }
}


