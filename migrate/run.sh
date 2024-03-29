#!/bin/bash
#
# IMPORTANT: This script should be invoked by `git-xargs`
#

export LABELS="auto-update,migration,no-release"
export YAMLFIX_CONFIG_PATH="${MIGRATE_PATH}/yamlfix.yml"
# Check if MIGRATE_PATH is not set
if [ -z "${MIGRATE_PATH}" ]; then
    echo "Error: MIGRATE_PATH is not set; this should be the base path where the migrations folder exists."
    exit 1
fi

# Check if MIGRATE_PATH does not exist
if [ ! -d "${MIGRATE_PATH}" ]; then
    echo "Error: MIGRATE_PATH does not exist: ${MIGRATE_PATH}"
    exit 1
fi

migration=$1
migration_path=${MIGRATE_PATH}/migrations/$migration
migration_script=${migration_path}/script.sh
migration_readme=${migration_path}/README.md

if [ -z "${migration}" ]; then
    echo "Error: No migration specified"
    exit 1
fi

if [ ! -f "${migration_script}" ]; then
    echo "Error: Migration not found: $migration_script"
    exit 1
fi

# Check if XARGS_DRY_RUN, XARGS_REPO_NAME, or XARGS_REPO_OWNER is not set
if [[ -z "$XARGS_DRY_RUN" || -z "$XARGS_REPO_NAME" || -z "$XARGS_REPO_OWNER" ]]; then
    echo "Error: This script should be invoked via git-xargs."
    exit 1
fi

# Use migration's `.gitignore`, since not all repos have one
git config --local core.excludesFile ${MIGRATE_PATH}/.gitignore

# Clone the `build-harness` to a centralized location so we don't have to do it for every migration
if [ ! -d "${MIGRATE_PATH}/tmp/build-harness" ]; then
    git clone https://github.com/cloudposse/build-harness.git "${MIGRATE_PATH}/tmp/build-harness"
fi

# Load all the helper functions
for script in ${MIGRATE_PATH}/lib/*.sh; do
    set -e
    source "$script"
    set +e
done

# Export the repo type
repo_type


if [ -d "${MIGRATE_PATH}/templates/${REPO_TYPE}" ]; then
    info "Using ${REPO_TYPE} repository type for (${XARGS_REPO_NAME})"
else
    error "Error: No templates found for repository type: ${REPO_TYPE}"
fi

# Perform the actual migration
set -e
info "Starting migration $migration"
source ${MIGRATE_PATH}/migrations/$migration/script.sh
set +e

# Commit the changes
git commit -a --message "chore: ${TITLE}"
git push origin HEAD

# due to a bug in `git-xargs`, we need to clean up manually before exiting
# https://github.com/gruntwork-io/git-xargs/issues/53
git clean -fxd

if [  "${XARGS_DRY_RUN}" == "false" ]; then
    # First, we have to ensure labels already exist. They will not be created on-demand.
    create_labels

    # Create or update the pull request
    gh pr create --title="${TITLE}" --body-file=${migration_readme} --label=${LABELS} || \
        gh pr edit --title="${TITLE}" --body-file=${migration_readme} --add-label=${LABELS}
    info "PR: $(gh pr view --json url --jq .url)"
    # Automatically merge this PR after checks pass, using admin privileges to bypass branch protections.
    # Then delete the branch.
    if [ "${AUTO_MERGE}" == "true" ]; then
        info "Auto-merging PR"
        gh pr merge --auto --squash --delete-branch
    fi
fi
