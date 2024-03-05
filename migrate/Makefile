export SHELL := /bin/bash
export TMPDIR := ./tmp
export MIGRATE_PATH := $(PWD)
export MIGRATION_PATH := $(MIGRATE_PATH)/migrations/$(MIGRATION)

deps:
	brew install gh yq
	pip3 install yamlfix

clean::
	rm -rf $(TMPDIR)/git-xargs*
	
.PHONY: run
run:
	export GITHUB_OAUTH_TOKEN=$$(gh auth token); \
	echo $$GITHUB_OAUTH_TOKEN; \
	mkdir -p $$TMPDIR; \
	git-xargs \
		--loglevel DEBUG \
		--skip-archived-repos \
		--repos $(MIGRATION_PATH)/repos.txt \
		--keep-cloned-repositories \
		--branch-name migration/$(MIGRATION) \
		--commit-message 'chore: run migration/$(MIGRATION)' \
		--skip-pull-requests \
		'$(MIGRATE_PATH)/run.sh' '$(MIGRATION)'
