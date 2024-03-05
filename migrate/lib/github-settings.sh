function install_github_settings() {
    # IMPORTANT `settings.yml` uses `_extends` keyword and mergify uses `extends` keyword
    info "Installing GitHub settings"
    local settings=".github/settings.yml"

    mkdir -p $(dirname $settings)
    if [ -f $settings ]; then
        info "GitHub settings already installed"
        # Ensure it's always extending from the .github repo
        yq -ei '._extends = ".github"' $settings

        # Remove the erroneous extends key, if present
        yq -ei 'del(.extends)' $settings
    else 
        info "GitHub settings not found, initializing to .github"
        info "Creating $settings"
        echo "_extends: .github" > $settings
    fi

    # finally, let's sort the file so _extends is at the top.
    yq -ei 'sort_keys(.)' $settings

    # Format the YAML for humans
    yamlfix -c ${MIGRATE_PATH}/yamlfix.yml $settings

    git add $settings

}
