#!/bin/bash

git config --local user.email "devops@smarsh.com"
git config --local user.name "smarsh-concourse-ci"

if [[ "${GITHUB_EVENT}" == "push" ]]; then
    if [[ -d operational-readiness/ ]]; then
        cd operational-readiness/
        echo "Updating operational-readiness.yml based on operational-readiness-template.yml"
        yq merge ../../../operational-readiness-template.yml operational-readiness.yml >> temp.yml
        rm operational-readiness.yml
        mv temp.yml operational-readiness.yml
        rm operational-readiness.md
        ./../../../build_markdown.sh
        
        updated_markdown_content=`base64 operational-readiness.md`
        or_markdown_sha=`curl -H "Authorization: token ${ACCESS_TOKEN}" \
        https://api.github.com/repos/${GITHUB_REPO}/contents/operational-readiness/operational-readiness.md  | jq -r .sha`

        or_markdown_sha=`curl --header "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/repos/${GITHUB_REPO}/contents/operational-readiness/operational-readiness.md  | jq -r .sha`

        http --print= --ignore-stdin PUT https://api.github.com/repos/${GITHUB_REPO}/contents/operational-readiness/operational-readiness.md \
        "Authorization: token ${ACCESS_TOKEN}" \
        "Content-Type: application/json" \
        message="Updated operational-readiness.md via github action" \
        content="$updated_markdown_content" \
        sha="$or_markdown_sha" \
        branch="${BRANCH}"

    else
        echo "Creating operational-readiness directory and contents"
        mkdir operational-readiness/
        cp ../../operational-readiness-template.yml operational-readiness/operational-readiness.yml
        cd operational-readiness
        ./../../../build_markdown.sh

        updated_markdown_content=`base64 operational-readiness.md`
        http --print= --ignore-stdin PUT -H https://api.github.com/repos/${GITHUB_REPO}/contents/operational-readiness/operational-readiness.md \
        "Authorization: token ${ACCESS_TOKEN}" \
        "Content-Type: application/json" \
        message="Updated operational-readiness.md via github action" \
        content="$updated_markdown_content" 
        branch="master"${BRANCH}
    fi

    array=()

    while IFS= read -r line; do
        array+=("$line")
    done < ../../../products.yml

    product=`yq r operational-readiness.yml product`

    if [[ " ${array[@]} " =~ " ${product} " ]]; then
        json_data=`yq r -j operational-readiness.yml`

        curl --header "Content-Type: application/json" \
        --request POST \
        --data "${json_data}" \
        --header "authorization: X-API-KEY ${API_KEY}" \
        https://operational-readiness.apps.prod.smarsh.cloud/api/v1/repos
    else
        RED='\033[0;31m'
        NC='\033[0m'
        echo -e "\n${RED}Please update the product name in operational-readiness.yml to match ${array[@]}${NC}\n\n"
        exit 1
        for product in "${array[@]}"; do
            echo "${product}"
        done
    fi
else
    array=()

    while IFS= read -r line; do
        array+=("$line")
    done < ../../products.yml

    product=`yq r operational-readiness/operational-readiness.yml product`

    if [[ " ${array[@]} " =~ " ${product} " ]]; then
        exit 0
    else
        RED='\033[0;31m'
        NC='\033[0m'
        echo -e "\n${RED}Please update the product name in operational-readiness.yml to match:${NC}\n"
        for product in "${array[@]}"; do
            echo "${product}"
        done
        exit 1
    fi
fi