#!/bin/bash

function migrate_readme() {

    readme_yaml="${1:-README.yaml}"

    if [ ! -f "${readme_yaml}" ]; then
        error "${readme_yaml} file not found."
    fi
    # This is used in the event `github_repo` is not properly set in the `README.yaml`
    export GITHUB_REPO="${XARGS_REPO_OWNER}/${XARGS_REPO_NAME}"
    ${MIGRATE_PATH}/lib/readme.py ${readme_yaml}
}


function rebuild_readme() {
  if [ ! -f README.yaml ]; then
    info "README.yaml file not found, skipping..."
    return 0
  fi

  make readme

  git add README.md
}

function generate_description() {
  local description=$(cat README.yaml *.tf | \
    mods --no-cache --quiet --word-wrap=2048 --raw -f \
      'Provide a clear 1-3 sentence description in a spartan conversational tone, that describes this terraform module suitable \
      for inclusion in the README.md of the module. Respond with GitHub flavored markdown and use links where appropriate. The target \
      audience is developers with terraform knowledge. Do not link the Terraform term. Do not link to the module you are describing. \
      Use code ticks for things like shell commands, terraform resources, modules or kubernetes resource definitions. Avoid too many adjectives \
      or hyperbole. Focus on what it is and does.')

}

function generate_introduction() {
  local description=$(cat README.yaml *.tf | \
    mods --no-cache --quiet --word-wrap=2048 --raw -f \
      'Act as an expert technical documentation writer with experience writing technical documentation for Open Source projects. \
      Write a thorough explanation for a chapter of a REAMDE that explains what this module does in a spartan conversational tone written by an experienced DevOps engineer.\
      Focus on what it is and does. Use concrete terms of what it does, not aspirations and endeavors. \
      It can be as long as necessary. \
      Add a section called "Key Features" which very succinctly highlights to top features of the module, but do not include the examples or features of the examples that do not directly relate to the module. \
      This feature list should be a bulleted list. 
      This repo is identified by the "github_repo" key in the README.yaml file. \
      Respond with GitHub flavored markdown and use links where appropriate. \
      The target audience is developers with terraform knowledge. \
      If discussing Cloud Posse, link to https://cloudposse.com, but only the first time per paragraph. Use "Cloud Posse" instead of "CloudPosse" \
      Use code ticks for things like shell commands, terraform resources, modules or kubernetes resource definitions. \  
      Link to any modules referenced, with exception of the current module. \
      For AWS services, link to the most relevant page in the AWS documentation. \
      For each AWS service used by the module, explain succinctly what it is and the benefit of why it is used. \
      For example, if you are using an S3 bucket, link to the S3 documentation.\
      This explanation will be present within the repository itself, so do not directly suggest to visit module or repository itself.\
      We discuss related modules elsewhere, so only bring up the most relevant ones here, if necessary.
      Any modules discussed should also be linked to their documentation. \
      Any terraform resources referenced should be linked to their documentation. \
      Combine many one sentence parargraphs into a single paragraph. \
      Do not use fancy words like "repertoire" or try to sound cute. \
      Do not say things like as stated in the documentation or as stated in the README. \
      Do not use the "related" or "references" section from the README.yaml as part of the description. \
      Do not say "This repository" or "This project". \
      Do not state the obvious. \
      DO not state things such as "This module is a Terraform module" or that they need to have an AWS account or login credentials or the benefits in general of using modules.\
      Do not say things like "Go back to the index" or "Read the next chapter" as this is not a book. \
      Do not repeat the name of the current module multiple times in the explanation. 
      Do not reuse the same phrases repeatedly like "key feature" over and over again. \
      Do not use too many adjectives and avoid hyperbole. \
      Do not add a conclusion or summary.\
      Do not break it into additional chapters, unless asked. \
      Do not add a title. \
      Do not link the Terraform term. \
      Do not link to the module you are describing. \
      Do not say anything like "this module presupposes general background knowledge" \
      Do not discuss cost of provisioning the resources. \
      Do not link to any other chapters with anchors. \
      Do not include example usage, or further information as the focus needs to be on the module itself. \
      ')
}
