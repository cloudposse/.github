#!/bin/bash

function rebuild_readme() {
  if [ ! -f README.yaml ]; then
    info "README.yaml file not found, skipping..."
    return 0
  fi

  make readme

  git add README.md
}
