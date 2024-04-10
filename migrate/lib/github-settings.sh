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
    # Fetch the current name and description of the repo and update the settings file
    local repo_description=$(gh repo view --json description --jq '.description')
    local repo_homepage=$(gh repo view --json homepageUrl --jq '.homepageUrl')
    local repo_topics=$(gh api repos/{owner}/{repo}/topics --jq '.names | join(", ")')

    yq -ei ".repository.name = \"$XARGS_REPO_NAME\"" $settings
    yq -ei ".repository.description = \"$repo_description\"" $settings
    if [ -z "$repo_homepage" ]; then
        yq -ei ".repository.homepage = \"https://cloudposse.com/accelerate\"" $settings
    else
        yq -ei ".repository.homepage = \"$repo_homepage\"" $settings
    fi
    
    yq -ei ".repository.topics = \"$repo_topics\"" $settings

    # finally, let's sort the file so _extends is at the top.
    yq -ei 'sort_keys(.)' $settings
    sed -i '' '/# Upstream changes/d' $settings
    yq -ei '(._extends | key) head_comment="Upstream changes from _extends are only recognized when modifications are made to this file in the default branch."' $settings
    
    git add $settings
}
