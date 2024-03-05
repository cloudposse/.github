#!/bin/bash

function install_gitignore() {
    if [ ! -f .gitignore ]; then
        install .gitignore
    fi
}
