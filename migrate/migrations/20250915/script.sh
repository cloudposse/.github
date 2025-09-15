title "Replace Makefile with atmos.yaml"

remove Makefile
remove docs/github-action.md
remove docs/targets.md
install atmos.yaml

# Iterate over workflow test files and display their contents
for workflow_file in .github/workflows/test*.yml .github/workflows/test*.yaml; do
    if [ -f "$workflow_file" ]; then
        # Use yq to add the workflow_dispatch inputs to the 'on' section
        yq eval '.on.workflow_dispatch.inputs.ref.description = "The fully-formed ref of the branch or tag that triggered the workflow run" |
                 .on.workflow_dispatch.inputs.ref.required = false |
                 .on.workflow_dispatch.inputs.ref.type = "string" |
                 .on.workflow_dispatch.inputs.sha.description = "The sha of the commit that triggered the workflow run" |
                 .on.workflow_dispatch.inputs.sha.required = false |
                 .on.workflow_dispatch.inputs.sha.type = "string"' -i "$workflow_file"
    fi
done

# Merge the PR
auto_merge
