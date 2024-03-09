title "Update Scaffolding"

migrate_badges
rebuild_readme
install_mergify

# We've implemented repository rulesets to replace this functionality
# We don't care if it errors right now, as it might have already run.
delete_branch_protection || true

# Merge the PR
#auto_merge
