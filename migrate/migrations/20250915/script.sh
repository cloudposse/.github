title "Replace Makefile with atmos.yaml"

remove Makefile
remove docs/github-action.md
remove docs/targets.md
install atmos.yaml

# Iterate over workflow test files and add workflow_dispatch inputs
for workflow_file in .github/workflows/test*.yml .github/workflows/test*.yaml; do
    if [ -f "$workflow_file" ]; then
        # Remove empty workflow_dispatch: {} if it exists
        sed -i '' 's/workflow_dispatch: *{}/workflow_dispatch:/' "$workflow_file"
        # Check if workflow_dispatch already exists in the 'on' section
        if grep -q "workflow_dispatch:" "$workflow_file"; then
            # Add inputs section if it doesn't exist
            if ! grep -A 20 "workflow_dispatch:" "$workflow_file" | grep -q "inputs:"; then
                sed -i '' '/workflow_dispatch:/a\
    inputs:\
      ref:\
        description: "The fully-formed ref of the branch or tag that triggered the workflow run"\
        required: false\
        type: "string"\
      sha:\
        description: "The sha of the commit that triggered the workflow run"\
        required: false\
        type: "string"' "$workflow_file"
            fi
        else
            # Add workflow_dispatch section after the 'on:' line
            sed -i '' '/^on:/a\
  workflow_dispatch:\
    inputs:\
      ref:\
        description: "The fully-formed ref of the branch or tag that triggered the workflow run"\
        required: false\
        type: "string"\
      sha:\
        description: "The sha of the commit that triggered the workflow run"\
        required: false\
        type: "string"' "$workflow_file"
        fi
        
        # Add the ref and sha inputs if they don't already exist (when inputs: already exists)
        if grep -A 20 "workflow_dispatch:" "$workflow_file" | grep -q "inputs:" && ! grep -A 50 "workflow_dispatch:" "$workflow_file" | grep -q "ref:"; then
            sed -i '' '/inputs:/a\
      ref:\
        description: "The fully-formed ref of the branch or tag that triggered the workflow run"\
        required: false\
        type: "string"' "$workflow_file"
        fi
        
        if grep -A 20 "workflow_dispatch:" "$workflow_file" | grep -q "inputs:" && ! grep -A 50 "workflow_dispatch:" "$workflow_file" | grep -q "sha:"; then
            sed -i '' '/inputs:/a\
      sha:\
        description: "The sha of the commit that triggered the workflow run"\
        required: false\
        type: "string"' "$workflow_file"
        fi
    fi
done


# Merge the PR
auto_merge
