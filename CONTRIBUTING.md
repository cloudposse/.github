# Contributing

First off, thank you for considering contributing to Cloud Posse! It's people like you that make our community great.

## Code of Conduct

Cloud Posse has adopted a Code of Conduct that we expect project participants to adhere to. Please read [the full text](CODE_OF_CONDUCT.md) so that you can understand what actions will and will not be tolerated.

## What Should I Know Before I Get Started?

### Cloud Posse Projects

Each Cloud Posse project is hosted in its own repository on GitHub. Before contributing, familiarize yourself with the specific project you are interested in. Each repository typically contains a [`README.md`](README.md) with an overview of the project, and instructions for setting up your development environment and running tests.

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

Before creating bug reports, please check the Github Issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible. Fill out issue template as the information it asks for helps us resolve issues faster.

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for Cloud Posse, including completely new features and minor improvements to existing functionality. Following these guidelines helps maintainers and the community understand your suggestion and find related suggestions.

### Your First Code Contribution

Unsure where to begin contributing to Cloud Posse? You can start by looking through issues with the following labels:

| Label                                                                                 | Usage                                                                    |
| :------------------------------------------------------------------------------------ | :----------------------------------------------------------------------- |
| ![`help-wanted`](https://img.shields.io/badge/help_wanted-388bfd?style=for-the-badge) | issues which should only require a few lines of code, and a test or two. |
| ![`beginner`](https://img.shields.io/badge/beginner-388bfd?style=for-the-badge)       | issues which should be a bit more involved than issues.                  |

### Pull Requests

The process described here has several goals:

- Maintain Cloud Posse's quality
- Fix problems that are important to users
- Engage the community in working toward the best possible Cloud Posse
- Enable a sustainable system for Cloud Posse's maintainers to review contributions

Please follow these steps to have your contribution considered by the maintainers:

1. Follow all instructions in [Pull Request template](.github/PULL_REQUEST_TEMPLATE.md)
2. Follow the [styleguides](#styleguides)
3. After you submit your pull request, verify that all status checks are passing
4. If you need to request a review on your PR, please do so in the #pr-reviews Slack channel

While the prerequisites above must be satisfied prior to having your pull request reviewed, the reviewer(s) may ask you to complete additional design work, tests, or other changes before your pull request can be ultimately accepted.


#### Versioning

The release automation relies on labels to increment the semantic versioning tag. Releases are applied manually by maintainers.
If no label is applied, "minor" is assumed.

As a reference, the following is a mapping between labels and [semver](https://semver.org/):


1. `Patch`: A minor, backward compatible change. Increments patch version, e.g. 1.0.**1**
2. `Minor`: New features that do not break anything, e.g. 1.**1**.1
3. `Major`: Breaking changes (or first stable release), e.g. **2**.0.0
4. `No-release`: Do not release a new version

Typically when a module is pre-release, e.g. 0.x.x, each new feature will be a minor release. Once the module hits 1.x, simpler features, which fit the definition of patch, will be labelled as such.

Only Cloud Posse engineers should move a module from v0 to v1, and usually we prefer that it not be a breaking change. In fact, it's not uncommon for v1 to be just a new label for the current release, prompted by the desire to release a v2 that has a breaking change.

#### Stale Issues/PRs

It is proposed that stale issues/PRs are labelled `stale` after 30 days, and closed after 60 days if the `stale` label is present.

A Slack notification will be sent when an issue/PR is labelled `stale`.

To handle exceptions, additional labels have been proposed to control treatment of stale issues. The `stale` label will not be applied if any of the following labels are applied to a PR.

The currently proposed labels are:

- `High Priority`: an update which will improve feature coverage and/or quality, and will benefit the module's consumers
- `Expedite`: an update which should be attended to ASAP - perhaps due to a defect that could cause data loss or a security flaw

## Styleguides

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move resource to..." not "Moves resource to...")
- Limit the first line to 72 characters or less

### Pull Requests
- Reference GitHub Issues and Pull Requests liberally in a `## References` section. 
- Use `Closes #1234` to indicate when a PR fixes an issue.

### Terraform Styleguide & Best Practices

All Terraform should adhere to our [Terraform Best Practices](https://docs.cloudposse.com/reference/best-practices/terraform-best-practices/).

## Terraform Module Contributions

### Updating Module Documentation

When updating variables, update the variable description if it could be made clearer, and especially if a new map/object attribute is added

To update the README and Terraform registry documentation, run the following commands:

```shell
make init
make readme
```

You may also need to install gomplate: https://docs.gomplate.ca/installing/

### Updating the Module Examples

Each module has at least one example, located at `examples/complete/`. These are used as a guide for module consumers as well as for the Terratest inputs.

1. If changes were made to the main `versions.tf` file, update the `versions.tf` files in the example directories with the same new version.
2. Where possible, update the example with representative values to include your changes in the test coverage.
   1. This will likely require the Terratest tests (written in Go) to be updated as well. These are located in `test/src/`.

### Deprecating a Variable

Sometimes variables have been defined with less than optimal types, or their usage changes over time due to provider/API changes.

To avoid introducing breaking changes, here is a suggested approach for deprecating a variable:

1. Add a file `variables-deprecated.tf` if it doesn't already exist
3. Add your replacement variable to `variables.tf`
4. Configure the deprecated variable as a fallback for the replacement one, i.e. use the value of the deprecated variable if it not the default value and the replacement variable is the default value. Otherwise, the replacement variable takes precedence.

#### Examples:

- [terraform-aws-s3-bucket / variables-deprecated.tf](https://github.com/cloudposse/terraform-aws-s3-bucket/blob/main/variables-deprecated.tf)

### Optional Input Variables

Terraform does not easily allow conditional creation of resources based on input values.

To avoid errors like `The "count" value depends on resource attributes that cannot be determined until apply time, so Terraform cannot predict how many instances will be created. To work around this, use the -target argument to first apply only the resources that the count depends on.` Cloud Posse has [standardised](https://github.com/cloudposse/terraform-aws-security-group/wiki/Naming-Conventions,-Deprecating-Inputs,-Optional-Inputs#optional-inputs) on using lists where inputs may be empty, and they determine the existence of another resource.

This is because we are then able to use the length of the list as the conditional subject, rather than the value itself.

If you hit this case, define the variable using a list of the type you need, with the default `[]` and `nullable = false`.
Add a validation condition to prohibit more than 1 element in the list.

#### Examples:

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
            nullable    = false
            validation {
              condition     = length(var.target_security_group_id) < 2
              error_message = "Only 1 security group can be targeted."
            }
        }
    ```

### Testing

Each module has Terratest tests in the `test/src` directory. Tests are written in Go.

#### Local Testing

Using [Leapp](https://docs.cloudposse.com/howto/geodesic/authenticate-with-leapp/), [aws-vault](https://docs.cloudposse.com/howto/geodesic/authenticate-with-aws-vault/) or or some other method, populate the following AWS credential environment variables for a suitable account:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`

##### Running Tests Natively

This requires `go` to be installed.

```shell
cd test/src
make test
```

⚠️ Tests may crash, leaving resources behind. We recommend using a dedicated AWS account for testing,
and regularly running a tool such as [aws-nuke](https://github.com/rebuy-de/aws-nuke) or 
[cloud-nuke](https://github.com/gruntwork-io/cloud-nuke) to clean up after tests.

##### Running Tests in Docker

If running on an architecture other than amd64, specify the architecture in the docker pull command, e.g.

```shell
docker pull --platform linux/amd64 cloudposse/test-harness:latest 
```

```shell
cd test/src
make docker/test
```

#### Test Updates

Sometimes tests may need to be updated to take into account the changes included.

Typically there is one test file located at `test/src/examples_complete_test.go`

The following steps are generally required:

1. Add variables to `examples/complete/variables.tf`
2. Update corresponding values in `examples/complete/fixtures.us-east-2.tfvars`
3. Modify the test assertions in the Go file to compare newly added values

### Automated Checks

Currently PR approval for Terraform modules is subject to the following checks. Checks must be approved by a contributor/maintainer after the PR contents has been inspected. This is to help guard against malicious use of Github Actions runners, or checking invalid contributions.

1. Terraform linting
2. Compare README to terraform-docs output
3. Check for CODEOWNERS approval requirement
4. Labels validated

The full workflow can be seen [here](https://github.com/cloudposse/github-actions-workflows-terraform-module/blob/main/.github/workflows/feature-branch.yml).

In addition, maintainers will manually run Terratest tests against the PR branch to ensure the
changes can be applied successfully, using the fixtures from `examples/complete/`.

This is done via ChatOps by adding a comment with content `/terratest`. ChatOps commands are only
available to maintainers.