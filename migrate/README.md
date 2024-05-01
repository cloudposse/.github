## Usage

Create a migration script in [`migrations/<date>/script.sh`](migrations/) and use the helpers in [`lib/`](lib/).

```shell
# Export this environment variable to actually create and merge PRs
export XARGS_DRY_RUN=false 

# Pass the migration and the list of repos in the migration to process.
./git-xargs.sh 20240304 repos.txt
```

## How it Works

The `lib/` folder contains helper libraries (bash).  Define one file per tool. See the existing libraries for conventions.

The `migrations/` folder contains subfolders, one per migration. By convention, we should use dates (e.g. `20230302`).

Inside each date-based migration folder, there should be a few files.
- `README.md` which will both describe the migration and be used as the body of the PR.
- `repos.txt` a list of repos which this migration applies to. You can also batch this using the `split` command.
- `script.sh` a script that is invoked in the context of the library and will perform the migration operations

There's a `templates/` folder, which contains a number of subfolders. Each subfolder represents a repository type.
Including a `default` folder, which is used when no files are found for a given repository type.

## Helper Functions

- The `template_file` function will use the `REPO_TYPE` environment variable to find the best template file. It searches from the most specific to the list specific (e.g., `defaults/``)
- The `info` function emits a friendly message
- The `error` function emits the error and exits 1
- The `title` function sets the title that will be used subsequently when the PR is opened
- The `install` function will use the `template_file` function to install a file from one of the suitable templates
- THe `gh` function will call the `gh` command but respect GitHub API rate limits

## Tips & Tricks

1. Use `yq` for manipulating YAML. It will preserve comments but not whitespace. It will also replace Unicode characters with their escape sequence. Use `yamlfix` to restore the Unicode character.
2. Use `yamlfix` to format YAML and normalize whitespace.
3. Create a list of repos using the `gh repo list` command

<details><summary>Past Limitations Using `git-xargs` CLI</summary>

## Notable Limitations

We encountered significant obstacles using `git-xargs`. Here they are for posterity.

- `git-xargs` cannot add labels
- `git-xargs` [ignores `.gitignore`](https://github.com/gruntwork-io/git-xargs/issues/53), so it's best to handle clean-up before exiting the script
- `git-xargs` will not update PR title/description, so it's advisable to just use `gh` CLI instead
- `git-xargs` cannot auto-merge, so use `gh-cli` in script to commit, push, open PR, then merge
- Using `gh-cli` to bypass the `git-xargs` deficiencies, means rate limiting isn't respected by `git-xargs`
</details>
