#!/bin/bash
gh repo list cloudposse --limit 500 --json name,owner \
    --jq '.[] | select(.name | test("^terraform")) | select(.name | test("^cloudposse/terraform-aws-route53-record") | not) | select(.name | test("^terraform-provider") | not) | select(.name | test("^terraform-aws-components") | not) | .owner.login + "/" + .name' > repos.txt

split -d -l 16 repos.txt repos-
