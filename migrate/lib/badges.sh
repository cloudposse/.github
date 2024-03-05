function migrate_badges() {

    readme_yaml="${1:-README.yaml}"

    if [ ! -f "${readme_yaml}" ]; then
        error "${readme_yaml} file not found."
    fi

    export GITHUB_REPO=$(yq '.github_repo' ${readme_yaml})

    if [ "${GITHUB_REPO}" == "null" ]; then
        error "GITHUB_REPO is not set in the ${readme_yaml} file."
    fi

    #  image: "https://img.shields.io/github/release/cloudposse/terraform-aws-documentdb-cluster.svg"
    # Action: add ?style=for-the-style
    yq -ei '.badges |= map(select(.image | test("img.shields.io")).image |= (. | sub("\.svg$"; ".svg?style=for-the-badge")) ) ' ${readme_yaml}

    # image: "https://slack.cloudposse.com/badge.svg"
    # Action: replace /badge.svg with /for-the-badge.svg
    yq -ei '.badges |= map(select(.image | test("slack.cloudposse.com")).image |= (. | sub("/badge\.svg$"; "/for-the-badge.svg")) ) ' ${readme_yaml}

    # - name: "Codefresh Build Status"
    #  image: "https://g.codefresh.io/api/badges/pipeline/cloudposse/terraform-modules%2Fterraform-aws-ecs-web-app?type=cf-1"
    #  url: "https://g.codefresh.io/public/accounts/cloudposse/pipelines/5dbb22a15c2e97b3b73ab484"
    yq -ei 'del(.badges[] | select(.name == "*Codefresh*"))' ${readme_yaml}

    # - name: "Build Status"
    #   image: "https://travis-ci.org/cloudposse/terraform-aws-ec2-ami-backup.svg?branch=master"
    #   url: "https://travis-ci.org/cloudposse/terraform-aws-ec2-ami-backup"
    # Action: delete it
    yq -ei 'del(.badges[] | select(.name == "*Build Status*"))' ${readme_yaml}

    # - name: "Latest Release"
    #   image: "https://img.shields.io/github/release/cloudposse/terraform-aws-ec2-ami-backup.svg"
    #   url: "https://travis-ci.org/cloudposse/terraform-aws-ec2-ami-backup/releases"
    # Action: Replace it
    yq -ei 'del(.badges[] | select(.name == "Latest Release"))' ${readme_yaml}

    #- name: GitHub Action Build Status
    #  image: https://github.com/cloudposse/terraform-aws-lambda-elasticsearch-cleanup/workflows/Lambda/badge.svg?branch=master
    #  url: https://github.com/cloudposse/terraform-aws-lambda-elasticsearch-cleanup/actions?query=workflow%3ALambda
    yq -ei 'del(.badges[] | select(.name == "GitHub Action Build Status"))' ${readme_yaml}

    #- name: "Discourse Forum"
    #  image: "https://img.shields.io/discourse/https/ask.sweetops.com/posts.svg"
    #  url: "https://ask.sweetops.com/"
    # Action: Remove it
    yq -ei 'del(.badges[] | select(.name == "Discourse Forum"))' ${readme_yaml}
    

    # Now let's add the correct badges
    yq -ei 'del(.badges[] | select(.name == "*Release*"))' ${readme_yaml}
    yq -ei '.badges += [
        {
          "name": "Latest Release",
          "image": "https://img.shields.io/github/release/" + env(GITHUB_REPO) + ".svg?style=for-the-badge",
          "url": "https://github.com/" + env(GITHUB_REPO) + "/releases/latest"
        }
    ]' ${readme_yaml}

    yq -ei 'del(.badges[] | select(.name == "*Updated*"))' ${readme_yaml}
    yq -ei 'del(.badges[] | select(.name == "*Commit*"))' ${readme_yaml}
    yq -ei '.badges += [
        {
          "name": "Last Updated",
          "image": "https://img.shields.io/github/last-commit/" + env(GITHUB_REPO) + ".svg?style=for-the-badge",
          "url": "https://github.com/" + env(GITHUB_REPO) + "/commits"
        }
    ]' ${readme_yaml}

    if [ -f ".github/workflows/test.yml" ]; then
        yq -ei 'del(.badges[] | select(.name == "*Test*"))' ${readme_yaml}
        yq -ei '.badges += [
            {
              "name": "Tests",
              "image": "https://img.shields.io/github/actions/workflow/status/" + env(GITHUB_REPO) + "/test.yml?style=for-the-badge",
              "url": "https://github.com/" + (env(GITHUB_REPO) | tostring) + "/actions/workflows/test.yml"
            }
        ]' ${readme_yaml}
    fi

    
    if [ -f ".github/workflows/lambda.yml" ]; then
        yq -ei 'del(.badges[] | select(.name == "*Test*"))' ${readme_yaml}
        yq -ei '.badges += [
            {
              "name": "Tests",
              "image": "https://img.shields.io/github/actions/workflow/status/" + env(GITHUB_REPO) + "/lambda.yml?style=for-the-badge",
              "url": "https://github.com/" + env(GITHUB_REPO) + "/actions/workflows/lambda.yml"
            }
        ]' ${readme_yaml}
    fi    

    # This should always be the last badge we append, so it appears on the right.
    yq -ei 'del(.badges[] | select(.name == "*Slack*"))' ${readme_yaml}
    yq -ei '.badges += [
        {
          "name": "Slack Community",
          "image": "https://slack.cloudposse.com/for-the-badge.svg",
          "url": "https://slack.cloudposse.com"
        }
    ]' ${readme_yaml}

    # Format the YAML for humans
    yamlfix -c ${MIGRATE_PATH}/yamlfix.yml $readme_yaml
}
