title "Update GitHub Workflows to use shared workflows from '.github' repo"

install .github/workflows
remove .github/workflows/feature-branch.yml
remove .github/workflows/release-branch.yml
remove .github/workflows/release-published.yml
remove .github/workflows/feature-branch-chatops.yml

# Merge the PR
auto_merge
