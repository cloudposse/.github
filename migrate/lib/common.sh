function title() {
    export TITLE="$1"
}

function error() {
    printf "“❌ \e[31mError: %s\e[0m\n" "$*"
    exit 1
}

function info() {
    printf "✅︎ %s\n" "$*"
}

function install() {
    local source=${1}
    local destination=${2:-$source}
    local source_file=$(template_file $source)
    if [ -f "${source_file}" ]; then
        info "Installing $destination from $source_file"
        cp -a $source_file $destination
        git add $destination
    else
        error "Template not found: $source"
    fi
}

function auto_merge() {
    export AUTO_MERGE=${1:-true}
}

function template_file() {
    if [ -f ${MIGRATE_PATH}/templates/${REPO_TYPE}/$1 ]; then
        echo ${MIGRATE_PATH}/templates/${REPO_TYPE}/$1
    elif [ -f ${MIGRATE_PATH}/templates/default/$1 ]; then
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

    local existing_labels=$(gh label list)

    for label in "${required_labels[@]}"; do
        if ! echo "$existing_labels" | grep -q "$label"; then
            gh label create "$label" -c '#b60205'
            info "Created label [$label]"
        fi
    done
}
