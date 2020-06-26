#!/bin/bash

git config --local user.email "devops@smarsh.com"
git config --local user.name "smarsh-concourse-ci"

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
    
    postDataJson="{\"message\":\"Updated operational-readiness.md via github action\",\"content\":\"$updated_markdown_content\",\"sha\":\"$or_markdown_sha\"}"

    curl -X PUT -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" \
    -d $postDataJson \
    https://api.github.com/repos/${GITHUB_REPO}/contents/operational-readiness/operational-readiness.md

else
    echo "Creating operational-readiness directory and contents"
    mkdir operational-readiness/
    cp ../../operational-readiness-template.yml operational-readiness/operational-readiness.yml
    cd operational-readiness
    ./../../../build_markdown.sh

    postDataJson="{\"message\":\"Updated operational-readiness.md via github action\",\"content\":\"$updated_markdown_content\"}"

    updated_markdown_content=`base64 operational-readiness.md`
    curl -X PUT -H "Authorization: token ${ACCESS_TOKEN}" -H "Content-Type: application/json" -d $postDataJson \
    https://api.github.com/repos/${GITHUB_REPO}/contents/operational-readiness/operational-readiness.md 
fi

json_data=`yq r -j operational-readiness.yml`

curl --header "Content-Type: application/json" \
  --request POST \
  --data "${json_data}" \
  --header "authorization: X-API-KEY ${API_KEY}" \
  https://operational-readiness.apps.prod.smarsh.cloud/api/v1/repos
