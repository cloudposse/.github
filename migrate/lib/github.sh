
function delete_branch_protection() {
    local default_branch=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
    gh api -X DELETE /repos/${XARGS_REPO_OWNER}/${XARGS_REPO_NAME}/branches/${default_branch}/protection
}