plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  deep_check = false
}

config {
  call_module_type = "local"
}

# Disable specific rules that cause false positives in modules
rule "aws_resource_missing_tags" {
  enabled = false
}

rule "aws_iam_role_policy_invalid_name" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}
