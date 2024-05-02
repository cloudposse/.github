function title() {
    export TITLE="$1"
}

function error() {
    printf "“❌ \e[31mError: %s\e[0m\n" "$*" >&2
    exit 1
}

function info() {
    printf "✅︎ %s\n" "$*" >&2
}

function gh() {
  while true; do
    # Check the GitHub API rate limit
    rate_limit=$(command gh api rate_limit | jq '.resources.core.remaining')
    
    # Print the current rate limit
    info "GitHub API rate limit: $rate_limit remaining"
    
    # If the rate limit is sufficient, break the loop
    if (( rate_limit > 10 )); then
      break
    fi
    
    # Sleep for 60 seconds before checking the rate limit again
    info "Rate limit too low, sleeping for 60 seconds..."
    sleep 60
  done
  
  # Call the gh command with the provided arguments
  command gh "$@"
  exit_code=$?
  # Generate a random number between 500 and 3000 (representing milliseconds)
  random_milliseconds=$(( RANDOM % 2500 + 500 ))

  # Convert milliseconds to seconds
  random_seconds=$(echo "scale=3; $random_milliseconds / 1000" | bc)
  
  # Sleep for the random amount of time
  sleep $random_seconds
  return $exit_code
}


function install() {
    local source=${1}
    local destination=${2:-$source}
    local source_file=$(template_file $source)
    if [ -f "${source_file}" ]; then
        info "Installing file $destination from $source_file"
        cp -a $source_file $destination
        git add $destination
		elif [ -d "${source_file}" ]; then
        info "Installing directory $destination from $source_file"
				mkdir -p $destination
        cp -a $source_file/ $destination/
        git add $destination
    else
        error "Template not found: $source"
    fi
}

function remove() {
    local file=${1}
		git rm $file
}

function auto_merge() {
    export AUTO_MERGE=${1:-true}
}

function template_file() {
    if [ -f ${MIGRATE_PATH}/templates/${REPO_TYPE}/$1 ]; then
        echo ${MIGRATE_PATH}/templates/${REPO_TYPE}/$1
    elif [ -f ${MIGRATE_PATH}/templates/default/$1 ]; then
        echo ${MIGRATE_PATH}/templates/default/$1
    elif [ -d ${MIGRATE_PATH}/templates/${REPO_TYPE}/$1 ]; then
        echo ${MIGRATE_PATH}/templates/${REPO_TYPE}/$1
    elif [ -d ${MIGRATE_PATH}/templates/default/$1 ]; then
        echo ${MIGRATE_PATH}/templates/default/$1
    else
        error "Template not found: $1"
    fi
}

function repo_type() {
    if [ -f "main.tf" ]; then
        export REPO_TYPE="terraform-module"
    elif [[ "${XARGS_REPO_NAME}" =~ "terraform-provider" ]]; then
        export REPO_TYPE="terraform-provider"
    elif [[ "${XARGS_REPO_NAME}" =~ "terraform-" ]]; then
        export REPO_TYPE="terraform-module"
    elif [ "${XARGS_REPO_NAME}" == "test" ]; then
        export REPO_TYPE="test"
    elif [ -f "action.yml" ]; then
        export REPO_TYPE="github-action"
    elif [ -f "Dockerfile" ]; then
        export REPO_TYPE="docker"
    elif [ -f "package.json" ]; then
        export REPO_TYPE="node"
    else
        export REPO_TYPE="default"
    fi
}


function create_labels() {
    # Ideally this would happen by `.github/settings.yml`, however there's an order of 
    # operations issue, since the labels we use may not yet have been synced to the repo.
    # So instead, let's create them now, and let them get updated/corrected later.

    IFS=',' read -ra required_labels <<< "$LABELS"

    local existing_labels=$(gh label list --json name  --jq '.[].name')

    for label in "${required_labels[@]}"; do
        if ! echo "$existing_labels" | grep -q "$label"; then
            gh label create "$label" -c '#b60205'
            info "Created label [$label]"
        fi
    done
}
