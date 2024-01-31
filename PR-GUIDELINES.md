# Terraform Module Contributor Guidelines

## Purpose

This document is intended to be a quick reference for contributors (reviewers and PR authors) to [Cloud Posse's Terraform modules](https://github.com/orgs/cloudposse/repositories?q=terraform&type=source)

## General Terraform Module Guidelines

1. [Terraform Best Practices ](https://docs.cloudposse.com/reference/best-practices/terraform-best-practices/)
2. https://www.reddit.com/r/Terraform/comments/19arrun/comment/kinusdl/

## PR Guidelines

### Documentation

1. Fill out the PR template
2. Update the readme
   ```shell
   make init
   make github/init
   make readme
   ```

You may also need to install gomplate: https://docs.gomplate.ca/installing/ 

3. When updating variables, update the variable description if it could be made clearer, and especially if a new map/object attribute is added

### Updating the examples

Each module has at least one example, located at `examples/complete/`. These are used as a guide for module consumers as well as for the Terratest inputs.

Where possible, update the example with representative values to include your changes in the test coverage.

### Deprecating a variable

Sometimes variables have been defined with less than optimal types, or their usage changes over time due to provider/API changes.

To avoid introducing breaking changes, here is a suggested approach for deprecating a variable:

1. Add a file `variables-deprecated.tf` if it doesn't already exist
2. Move the deprecated variable into this file
3. Add your replacement variable
4. Configure the deprecated variable as a fallback of the replacement one, i.e. populate the value of the deprecated variable if the replacement variable is not supplied.

Examples:

- [terraform-aws-s3-bucket / variables-deprecated.tf](https://github.com/cloudposse/terraform-aws-s3-bucket/blob/main/variables-deprecated.tf)

### Optional input variables

Terraform does not easily allow conditional creation of resources based on input values.

To avoid errors like `The "count" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many instances will be created. To work around this, use the -target argument to first apply only the resources that the count depends on.` Cloud Posse has [standardised](https://github.com/cloudposse/terraform-aws-security-group/wiki/Naming-Conventions,-Deprecating-Inputs,-Optional-Inputs#optional-inputs) on using lists where inputs may be empty, and they determine the existence of anothe resource.

This is because we are then able to use the length of the list as the conditional subject, rather than the value itself.

If you hit this case, define the variable using a list of the type you need, with the default `[]`. Add a validation condition to prohibit more than 1 element in the list.

Examples:

- [terraform-aws-security-group / variables.tf](https://github.com/cloudposse/terraform-aws-security-group/blob/main/variables.tf)
  ```hcl
    variable "target_security_group_id" {
            type        = list(string)
            description = <<-EOT
            The ID of an existing Security Group to which Security Group rules will be assigned.
            The Security Group's name and description will not be changed.
            Not compatible with `inline_rules_enabled` or `revoke_rules_on_delete`.
            If not provided (the default), this module will create a security group.
            EOT
            default     = []
            validation {
            condition     = length(var.target_security_group_id) < 2
            error_message = "Only 1 security group can be targeted."
            }
        }
    ```

## PR Management

The release automation relies on labels to increment the semantic versioning tag.

As a reference, the following is a mapping between labels and semver:

1. `Patch`: A minor, backward compatible change. Increments patch version, e.g. 1.0.**1**
2. `Minor`: New features that do not break anything, e.g. 1.**1**.1
3. `Major`: Breaking changes (or first stable release), e.g. **2**.0.0
4. `No-release`: Do not release a new version

Typically when a module is pre-release, e.g. 0.x.x, each new feature will be a minor release. Once the module hits 1.x, simpler features, which fit the definition of patch, will be labelled as such.

### Stale Issues

It is proposed that stale issues/PRs are labelled `stale` after 30 days, and closed after 60 days if the `stale` label is present.

A Slack notification will be sent when an issue/PR is labelled `stale`.

To handle exceptions, additional labels have been proposed to control treatment of stale issues. The `stale` label will not be applied if any of the following labels are applied to a PR.

The currently proposed labels are:

- `High Priority`: an update which will improve feature coverage and/or quality, and will benefit the module's consumers
- `Expedite`: an update which should be attended to ASAP - perhaps due to a defect that could cause data loss or a security flaw

## Automation

Currently PR approval is subject to the following checks. Checks must be approved by a contributor/maintainer after the PR contents has been inspected. This is to help guard against malicious use of Github Actions runners, or checking invalid contributions.

1. Terraform linting
2. Compare README to terraform-docs output
3. Check for CODEOWNERS approval requirement
4. Labels validated

The full workflow can be seen [here](https://github.com/cloudposse/github-actions-workflows-terraform-module/blob/main/.github/workflows/feature-branch.yml).

## Testing

Each module has Terratest tests in the `test/src` directory. Tests are written in Go.

### Local Testing

Using aws-vault or Leapp or some other method, populate the following AWS credential environment variables for a suitable account:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_SESSION_TOKEN

```shell
cd test/src
make docker/test
```

### Test Updates

Sometimes tests may need to be updated to take into account the changes included.

Typically there is one test file located at `test/src/examples_complete_test.go`

The following steps are generally required:

1. Add variables to `examples/complete/variables.tf`
2. Update corresponding values in `examples/complete/fixtures.us-east-2.tfvars`
3. Modify the test assertions in the Go file to compare newly added values
