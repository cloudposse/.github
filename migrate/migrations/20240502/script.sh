title "Use GitHub Action Workflows from \`cloudposse/.github\` Repo"

install_github_settings
install .github/workflows
remove .github/workflows/auto-readme.yml
remove .github/workflows/auto-release.yml

# Merge the PR
auto_merge
