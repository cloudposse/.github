title "Update Scaffolding"

migrate_readme
rebuild_readme
install_mergify

# We've implemented repository rulesets to replace this functionality
# We don't care if it errors right now, as it might have already run.
(delete_branch_protection >/dev/null 2>&1) || true

# Merge the PR
auto_merge
