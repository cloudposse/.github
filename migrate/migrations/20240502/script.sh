title "Use GitHub Action Workflows from \`cloudposse/.github\` Repo"

install_github_settings
install .github/workflows
remove .github/workflows/auto-readme.yml

# Merge the PR
auto_merge
