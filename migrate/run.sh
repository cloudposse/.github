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
curdir=$(pwd)

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

current_branch=$(git rev-parse --abbrev-ref HEAD)

# Identify the default branch
default_branch=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)

# Ensure our branch is reset to match the remote default branch, so that we can apply the migration cleanly
git reset --hard origin/${default_branch}

# Use migration's `.gitignore`, since not all repos have one
git config --local core.excludesFile ${MIGRATE_PATH}/.gitignore

# Clone the `build-harness` to a centralized location so we don't have to do it for every migration
if [ ! -d "${MIGRATE_PATH}/tmp/build-harness" ]; then
    git clone https://github.com/cloudposse/build-harness.git "$(dirname ${curdir})/build-harness"
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

# due to a bug in `git-xargs`, we need to clean up manually before exiting
# https://github.com/gruntwork-io/git-xargs/issues/53
git clean -fxd

# Commit the changes
git commit -a --message "chore: ${TITLE}"

# Get the differences between the current branch and the default branch
diff=$(git diff origin/${default_branch}...HEAD)

# Check if there are any changes
if [ -z "$diff" ]; then
  info "No changes relative to main; not creating a PR."
  # Check if the remote branch exists
  if git ls-remote --heads origin "${current_branch}" | grep -q "${current_branch}"; then
    info "Remote branch exists. Deleting..."
    git push origin --delete "${current_branch}"
  fi
  exit 0
fi

if [ "${current_branch}" != "${default_branch}" ]; then
    git push origin HEAD --force
fi

if [  "${XARGS_DRY_RUN}" == "false" ]; then
    # First, we have to ensure labels already exist. They will not be created on-demand.
    create_labels

    # Create or update the pull request
    gh pr create --title="${TITLE}" --body-file=${migration_readme} --label="${LABELS}" || \
        gh pr edit --title="${TITLE}" --body-file=${migration_readme} --add-label="${LABELS}"
    info "PR: $(gh pr view --json url --jq .url)"
    gh pr view --json url --jq .url >> ${MIGRATE_PATH}/pr.log
    # Automatically merge this PR after checks pass, using admin privileges to bypass branch protections.
    # Then delete the branch.
    if [ "${AUTO_MERGE}" == "true" ]; then
        info "Auto-merging PR"
        gh pr merge --admin --squash --delete-branch
    fi
fi

# Clean up again, so that `git-xargs` doesn't commit the cache files from `gh` cli in the `tmp/` folder
git clean -fxd