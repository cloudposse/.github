#!/bin/bash
gh repo list cloudposse --limit 500 --json name,owner \
	--jq '.[] | select(.name | test("^github-action-")) | select(.name | test("github-action-atmos-dependencies-test") | not) | .owner.login + "/" + .name' > repos.txt

split -d -l 16 repos.txt repos-
