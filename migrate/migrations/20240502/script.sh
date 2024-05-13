title "Use GitHub Action Workflows from \`cloudposse/.github\` Repo"

# We've implemented repository rulesets to replace this functionality
# We don't care if it errors right now, as it might have already run.
# Must run in a subshell.
(delete_branch_protection >/dev/null 2>&1) || true

install_github_settings
install .github/workflows
remove .github/workflows/feature-branch.yaml
remove .github/workflows/main-branch.yaml
remove .github/workflows/release.yaml
remove .github/workflows/auto-readme.yml
remove .github/workflows/auto-release.yml
remove .github/workflows/release-published.yml
remove .github/auto-release.yml
remove .github/configs/draft-release.yml

# Merge the PR
auto_merge
