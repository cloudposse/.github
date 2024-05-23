#!/bin/bash

function update_terratest() {
  if [ -f test/src/go.mod ]; then
    info "Updating terratest"
    cd test/src
		go get -u github.com/gruntwork-io/terratest
		go mod tidy
		cd -

		git add test/src/go.mod
		git add test/src/go.sum
  fi
}
