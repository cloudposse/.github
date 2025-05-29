title "Replace Makefile with atmos.yaml"

remove Makefile
remove docs/terraform.md
remove docs/targets.md
migrate_readme
install atmos.yaml

# Merge the PR
auto_merge
