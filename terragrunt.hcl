skip = true

remote_state {
  backend = "gcs"
  config = {
    skip_bucket_creation = true
    bucket               = "gcp-serverless-terraform-tfstate"
    prefix               = "${path_relative_to_include()}/${get_env("TF_VAR_env", "dev")}"
  }
}

terraform {
  extra_arguments "disable_input" {
    commands = get_terraform_commands_that_need_input()
    arguments = [
      "-input=false",
    ]
  }

  extra_arguments "disable_interactive_approve" {
    commands = [
      "apply",
    ]
    arguments = [
      "-auto-approve",
    ]
  }

  extra_arguments "env_tfvars" {
    commands = get_terraform_commands_that_need_vars()
    optional_var_files = [
      "${get_terragrunt_dir()}/${get_env("TF_VAR_env", "dev")}.tfvars",
    ]
  }
}

inputs = {
  application      = "gcp-serverless"
  locations        = get_env("TF_VAR_env", "dev") == "prod" ? ["EU", "US", "ASIA"] : ["EU", "US"]
  regions          = get_env("TF_VAR_env", "dev") == "prod" ? ["europe-west1", "us-central1", "asia-east2"] : ["europe-west1", "us-central1"]
  project_id       = "gcp-serverless-${get_env("TF_VAR_env", "dev")}"
  functions_bucket = "gcp-serverless-${get_env("TF_VAR_env", "dev")}-functions"
  domain           = "gcp-serverless-${get_env("TF_VAR_env", "dev")}.slamdev.net"
}
