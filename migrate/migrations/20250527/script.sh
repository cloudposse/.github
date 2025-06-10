title "Replace Makefile with atmos.yaml"

remove Makefile
remove docs/github-action.md
remove docs/targets.md
migrate_readme
install atmos.yaml

# Merge the PR
auto_merge
