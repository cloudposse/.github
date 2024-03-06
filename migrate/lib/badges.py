#!/usr/bin/env python3

# This implementation uses ruamel.yaml, a python library that can handle whitespace and comments.
#
# The first implementation attempted to use `yq` to parse the YAML file and update the badges section.
# Unfortunately, yq loses whitespace, and rewrites any multi-line strings and quoted strings.
# This caused the README.yaml to be reformatted and lose its original structure, which is not acceptable.
# It turns out that many YAML processors (especially based on Go) do not properly handle whitespace, 
# comments, and multi-line strings in YAML. 
# - https://github.com/mikefarah/yq/discussions/1584
# - https://github.com/go-yaml/yaml/issues/827
# 

import sys
import os
from ruamel.yaml import YAML

def add_newlines_before_comments(data):
    prev_item = None
    for item in data.items():
        key_node = item[0]
        # Check if the current node has a comment
        if hasattr(key_node, 'comment') and key_node.comment:
            comment = key_node.comment[0]
            if comment and prev_item and not (hasattr(prev_item, 'comment') and prev_item.comment):
                # Add a newline before the current comment block only if the previous item does not have a comment
                prev_item.comment[2] = ['\n']
        prev_item = key_node


def migrate_badges(readme_yaml="README.yaml"):
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.indent(mapping=2, sequence=4, offset=2)
    yaml.width = 4096  # Set to a large number to avoid line wrapping
    data = None

    documents = []

    # Load the YAML file with potentially multiple documents
    try:
        with open(readme_yaml, 'r') as file:
            documents = list(yaml.load_all(file))
    except FileNotFoundError:
        print(f"{readme_yaml} file not found.")
        return

    for data in documents:
        # Extract GITHUB_REPO value
        github_repo = data.get('github_repo', None)
        if not github_repo:
            print(f"github_repo is not set in the {readme_yaml} file.")
            pass

        if 'badges' in data and isinstance(data['badges'], list):
            # Names of badges to be removed (substrings)
            badges_to_remove = ['Codefresh', 'Build Status', 'Latest Release', 'Commit', 'GitHub Action Build Status', 'Discourse', 'Forum', 'Slack']

            # Remove unwanted badges
            data['badges'] = [badge for badge in data['badges'] if not any(removal_str in badge['name'].strip() for removal_str in badges_to_remove)]
        else:
            data['badges'] = []

        # Add new badges
        new_badges = [
            {"name": "Latest Release", "image": f"https://img.shields.io/github/release/{github_repo}.svg?style=for-the-badge", "url": f"https://github.com/{github_repo}/releases/latest"},
            {"name": "Last Updated", "image": f"https://img.shields.io/github/last-commit/{github_repo}.svg?style=for-the-badge", "url": f"https://github.com/{github_repo}/commits"},
            {"name": "Slack Community", "image": "https://slack.cloudposse.com/for-the-badge.svg", "url": "https://slack.cloudposse.com"}
        ]

        # Add badges for specific workflow files if they exist
        if os.path.isfile(".github/workflows/test.yml"):
            new_badges.append({"name": "Tests", "image": f"https://img.shields.io/github/actions/workflow/status/{github_repo}/test.yml?style=for-the-badge", "url": f"https://github.com/{github_repo}/actions/workflows/test.yml"})

        if os.path.isfile(".github/workflows/lambda.yml"):
            new_badges.append({"name": "Tests", "image": f"https://img.shields.io/github/actions/workflow/status/{github_repo}/lambda.yml?style=for-the-badge", "url": f"https://github.com/{github_repo}/actions/workflows/lambda.yml"})

        data['badges'].extend(new_badges)

        # Ruamel accidentally deletes this comment sometimes when updating the badges
        data.yaml_set_comment_before_after_key('related', before='\nList any related terraform modules that this module may be used with or that this module depends on.')

        # Set 'contributors' section to an empty array, as we handle this now with an image
        data['contributors'] = []

        add_newlines_before_comments(data)
        
    # Write back the updated YAML with multiple documents
    with open(readme_yaml, 'w') as file:
        yaml.dump_all(documents, file)

if __name__ == "__main__":
    migrate_badges(sys.argv[1])
