# Shared TFLint policy for Cloud Posse Terraform modules.
# Used by `atmos lint` (see .github/atmos/terraform-module.yaml) unless a module
# provides its own .tflint.hcl.

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Every module call must be pinned to a version (registry `version` or a git ref).
rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_module_version" {
  enabled = true
}

# Every provider needs an explicit source and a version constraint.
rule "terraform_required_providers" {
  enabled = true
  source  = true
  version = true
}

rule "terraform_required_version" {
  enabled = true
}

# Every input and output must be documented.
rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

# Deprecated syntax, e.g. legacy `.*` splats and "${var.x}" interpolation-only expressions.
rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_lookup" {
  enabled = true
}

# Hygiene.
rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}
