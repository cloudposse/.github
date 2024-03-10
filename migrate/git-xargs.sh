#!/usr/bin/env bash

# Due to just endless problems working around `git-xargs` limitations, challenges with rate limits,
# resorting to a basic shell script that does the same thing, but with more control and less magic and no parallelism.
set -e

migration=$1
batch=$2

# Validate usage
if [[ -z "$migration" || -z "$batch" ]]; then
    echo "Usage: $0 <migration_branch> <batch>"
    exit 1
fi
curdir=$(pwd)
migration_branch="migration/${migration}"
migration_dir="migrations/${migration}"
repos="${migration_dir}/${batch}"

# Test if the repo file exists
if [[ ! -f "$repos" ]]; then
  echo "Repo file for ${batch} batch does not exist: $repos"
  exit 1
fi

if [[ ! -d "migrations/${migration}" ]]; then
  echo "Migration does not exist: $migration"
  exit 1
fi

while IFS= read -r repo; do
  if [[ $repo == \#* ]]; then
    continue
  fi
  cd "${curdir}" 
  repo_name=$(basename "$repo" .git)
  repo_owner=$(basename "$(dirname "$repo")")
  repo_url="git@github.com:${repo_owner}/${repo_name}.git"
  tmp_dir="tmp/$repo_owner/$repo_name"

  echo "Processing $repo_url"
  if [[ ! -d "$tmp_dir" ]]; then
    mkdir -p $(dirname "$tmp_dir")
    git clone "$repo_url" "${tmp_dir}"
  fi

  cd "${tmp_dir}" || exit

  # Identify the default branch
  default_branch=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)

  git checkout "${default_branch}"
  # Ensure our branch is reset to match the remote default branch, so that we can apply the migration cleanly
  git reset --hard origin/${default_branch}
  git pull origin "${default_branch}"

  if git rev-parse --verify "${migration_branch}" >/dev/null 2>&1; then
    echo "Deleting existing ${migration_branch} branch"
    git branch -D "${migration_branch}"
  fi
  echo "Creating ${migration_branch} branch"
  git checkout -b "${migration_branch}"

  # Always start clean
  git clean -fxd

  export XARGS_DRY_RUN=${XARGS_DRY_RUN:-true}
  export XARGS_REPO_NAME="${repo_name}"
  export XARGS_REPO_OWNER="${repo_owner}"
  export MIGRATE_PATH="${curdir}"
  echo "Performing migration..."
  $curdir/run.sh "${migration}"
  if [[ $? -ne 0 ]]; then
    echo "Migration failed for ${repo}"
    exit 1
  fi

done < "${repos}"
