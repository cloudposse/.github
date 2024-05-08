title "Use GitHub Action Workflows from \`cloudposse/.github\` Repo"

delete_branch_protection
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
