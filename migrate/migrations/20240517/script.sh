title "Update GitHub Workflows to Fix ReviewDog TFLint Action"

install .github/workflows
remove .github/workflows/feature-branch.yml
remove .github/workflows/release-branch.yml
remove .github/workflows/release-published.yml
remove .github/workflows/feature-branch-chatops.yml

# Merge the PR
auto_merge
