export README_DEPS ?= docs/targets.md
-include $(shell curl -sSL -o .build-harness "https://cloudposse.tools/build-harness"; echo .build-harness)

all: init deps build install run

deps:
	@exit 0
