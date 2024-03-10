export SHELL := /bin/bash
export TMPDIR := ./tmp
export MIGRATE_PATH := $(PWD)
export MIGRATION_PATH := $(MIGRATE_PATH)/migrations/$(MIGRATION)
export BATCH ?= repos.txt
#export GIT_XARGS_OPTS := --keep-cloned-repositories

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
		$(GIT_XARGS_OPTS) \
		--loglevel DEBUG \
		--skip-archived-repos \
		--repos $(MIGRATION_PATH)/$(BATCH) \
		--branch-name migration/$(MIGRATION) \
		--commit-message 'chore: run migration/$(MIGRATION)' \
		--skip-pull-requests \
		'$(MIGRATE_PATH)/run.sh' '$(MIGRATION)'
