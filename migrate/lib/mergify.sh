function install_mergify() {
    # IMPORTANT `settings.yml` uses `_extends` keyword and mergify uses `extends` keyword
    info "Installing Mergify"
    local config=".github/mergify.yml"

    mkdir -p $(dirname $config)

    case "${REPO_TYPE}" in
        "terraform-provider")
            rm -f $config
            ;;
        "terraform-module")
            rm -f $config
            ;;
        "github-action")
            rm -f $config
            ;;
    esac
    
    if [ -f $config ]; then
        info "Mergify config already installed"
        # Ensure it's always extending from the .github repo
        yq -ei '.extends = ".github"' $config

        # Remove the erroneous _extends key, if present
        yq -ei 'del(._extends)' $config
        return
    else 
        info "Mergify config not found, initializing to .github"
        info "Creating $config"
        echo "extends: .github" > $config
    fi
    git add $config
}
