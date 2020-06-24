#!/bin/bash

function readYaml {
    paths=`yq r --printMode p $1 operational-readiness-subjects.$2[*]`
    for path in $paths; do
      subject=`echo $path | sed "s/operational-readiness-subjects.$2.//g"`
      if [[ `yq r $1 $path.exists` == true ]]; then
        eval "$subject"="white_check_mark"
      else
        eval "$subject"="x"
      fi
      if [[ `yq r $1 $path.urls` ]]; then
        urls=`yq r $1 $path.urls | sed 's/-//g' | sed 's/^[[:space:]]*//g'`
        arr=()
        for url in $urls; do
            arr+=("$url")
        done
        test="${arr[@]}"
        export "$subject"_urls="$test"
      else
         eval "$subject"_urls="None"
      fi
    done
}

#<----------------- Source Control ----------------->

readYaml "operational-readiness.yml" "sourceControl" 

source_control="### SourceControl\n
|Commitment|Exists|URLs (if applicable)|\n
|:---|:---:|:---:|\n
|Readme|":$readme:"|${readme_urls[@]}""|\n
|Contributing|":$contributing:"|${contributing_urls[@]}|\n
|Application Diagram|":$app_architecture_diagram:"|${app_architecture_diagram_urls[@]}|\n
|Master Branch Management|":$master_branch_mgmt:"|${master_branch_mgmt_urls[@]}|"

echo -e $source_control >> operational-readiness.md


#<----------------- Security Checks ----------------->

readYaml "operational-readiness.yml" "securityChecks"

security_checks="### SecurityChecks\n
|Commitment|Exists|URLs (if applicable)\n
|:---|:---:|:---:|\n
|Snyk|":$snyk:"|"${snyk_urls[@]}"|\n
|Sonar|":$sonar:"|"${sonar_urls[@]}"|"

echo -e $security_checks >> operational-readiness.md


#<----------------- CICD ----------------->

readYaml "operational-readiness.yml" "cicd"

cicd="### CICD\n
|Commitment|Exists|URLs (if applicable)\n
|:---|:---:|:---:|\n
|Artifact Repository|":$artifact_repository:"|"${artifact_repository_urls[@]}"|\n
|Version Management|":$version_mgmt:"|"${version_mgmt_urls[@]}"|\n
|Pipeline Configs|":$pipeline_configs:"|"${pipeline_configs_urls[@]}"|\n
|Slack Alerts|":$slack_alerts:"|"${slack_alerts_urls[@]}"|"

echo -e $cicd >> operational-readiness.md

#<----------------- PaaS Services ----------------->

readYaml "operational-readiness.yml" "paasServices"

paas_services="### PaasServices\n
|Commitment|Exists|URLs (if applicable)\n
|:---|:---:|:---:|\n
|Queue|":$queue:"|"${queue_urls[@]}"|\n
|Object Store|":$object_store:"|"${object_store_urls[@]}"|\n
|Relational Databases|":$relational_databases:"|"${relational_databases_urls[@]}"|\n
|Instrumentation|":$instrumentation:"|"${instrumentation_urls[@]}"|
|Secret Storage|":$secret_storage:"|"${secret_storage_urls[@]}"|
|Logging|":$logging:"|"${logging_urls[@]}"|
|Observability|":$observability:"|"${observability_urls[@]}"|
|Monitoring|":$monitoring:"|"${monitoring_urls[@]}"|"

echo -e $paas_services >> operational-readiness.md