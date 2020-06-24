#!/bin/bash

if [[ -d operational-readiness/ ]]; then
    cd operational-readiness/
    echo "Updating operational-readiness.yml based on operational-readiness-template.yml"
    yq merge ../../../operational-readiness-template.yml operational-readiness.yml >> temp.yml
    rm operational-readiness.yml
    mv temp.yml operational-readiness.yml
    rm operational-readiness.md
    ./../../../build_markdown.sh
else
    echo "Creating operational-readiness directory and contents"
    mkdir operational-readiness/
    cp ../../operational-readiness-template.yml operational-readiness/operational-readiness.yml
    cd operational-readiness
    ./../../../build_markdown.sh
fi

json_data=`yq r -j operational-readiness.yml`

curl --header "Content-Type: application/json" \
  --request POST \
  --data "${json_data}" \
  --header "authorization: X-API-KEY ${API_KEY}" \
  https://operational-readiness.apps.prod.smarsh.cloud/api/v1/repos
