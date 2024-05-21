title "Use GitHub Action Workflows from \`cloudposse/.github\` Repo"

install_github_settings
install .github/workflows
remove .github/workflows/feature-branch.yml
remove .github/workflows/main-branch.yml

# Merge the PR
auto_merge
