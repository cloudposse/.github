# terraform-module scaffold

Managed files for Cloud Posse Terraform modules, applied with [`atmos scaffold`](https://atmos.tools/cli/commands/scaffold/generate) (experimental).

Managed files: `AGENTS.md`, `context.tf`, `.github/CODEOWNERS`, `.github/settings.yml`, `.github/dependabot.yml`, and the four thin workflow callers in `.github/workflows/`. The scaffold never touches module code (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `examples/`, `tests/`).

```shell
# first time, in the module repo
atmos scaffold generate <this-directory-or-git-url> . --force --defaults \
  --set module_name=terraform-aws-example --set description="..."

# later (this is what `atmos fix` will run)
atmos scaffold generate <source> . --update --merge-strategy=theirs --merge-driver=text --defaults --skip-hooks
```

Managed files are fully owned by the scaffold and are overwritten on update. Put repo-specific agent notes in `docs/AGENTS.local.md`, which `AGENTS.md` points to and the scaffold does not manage.

Notes
- Every file in the template directory is generated into the target, so keep docs outside it (this file lives one level up). Only `*.tmpl` files are rendered (use `target:` in `scaffold.yaml` to drop the suffix). Everything else is copied verbatim, so GitHub `${{ }}` expressions are safe.
- `context.tf` is a copy of the `terraform-null-label` export. `atmos vendor pull` cannot currently write to the repository root. Keep it equal to the latest `exports/context.tf` in `cloudposse/terraform-null-label`.
