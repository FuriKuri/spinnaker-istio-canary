#!/bin/bash

echo "Create application ..."
curl -d@${BASH_SOURCE%/*}/../spinnaker/canary-app.json -X POST \
    -H "Content-Type: application/json" -H "Accept: /" \
    http://localhost:8080/gate/applications/canaryapp/tasks

sleep 10

curl -d@${BASH_SOURCE%/*}/../spinnaker/enable-canary.json -X POST \
    -H "Content-Type: application/json" -H "Accept: /" \
    http://localhost:8080/gate/applications/canaryapp/tasks

echo "Create pipeline ..."
curl -d@${BASH_SOURCE%/*}/../spinnaker/simple-deploy.json -X POST \
    -H "Content-Type: application/json" -H "Accept: /" \
    http://localhost:8080/gate/pipelines
curl -d@${BASH_SOURCE%/*}/../spinnaker/simple-deploy-istio.json -X POST \
    -H "Content-Type: application/json" -H "Accept: /" \
    http://localhost:8080/gate/pipelines

echo "Setup canary config ..."
curl -d@${BASH_SOURCE%/*}/../spinnaker/create-canary-config.json -X POST \
    -H "Content-Type: application/json" -H "Accept: /" \
    http://localhost:8080/gate/v2/canaryConfig
curl -d@${BASH_SOURCE%/*}/../spinnaker/create-canary-config-istio.json -X POST \
    -H "Content-Type: application/json" -H "Accept: /" \
    http://localhost:8080/gate/v2/canaryConfig

export CANARY_CONFIG_ID=$(curl localhost:8080/gate/v2/canaryConfig | jq -r '.[] | select(.name == "canary-config") | .id')
export ISTIO_CANARY_CONFIG_ID=$(curl localhost:8080/gate/v2/canaryConfig | jq -r '.[] | select(.name == "istio-canary-config") | .id')


curl -d@../spinnaker/canary-config.json -X PUT \
    -H "Content-Type: application/json" -H "Accept: /" \
    "http://localhost:8080/gate/v2/canaryConfig/$CANARY_CONFIG_ID"    

curl -d@../spinnaker/canary-config-istio.json -X PUT \
    -H "Content-Type: application/json" -H "Accept: /" \
    "http://localhost:8080/gate/v2/canaryConfig/$ISTIO_CANARY_CONFIG_ID" 

echo "Create canary pipeline ..."
export PIPELINE_ID=$(curl \
    localhost:8080/gate/applications/canaryapp/pipelineConfigs/Simple%20Deploy \
    | jq -r '.id')

jq '(.stages[] | select(.refId == "9") | .pipeline) |= env.PIPELINE_ID | (.stages[] | select(.refId == "8") | .pipeline) |= env.PIPELINE_ID' ${BASH_SOURCE%/*}/../spinnaker/canary-deploy.json | \
    curl -d@- -X POST \
    -H "Content-Type: application/json" -H "Accept: /" \
    http://localhost:8080/gate/pipelines

export PIPELINE_CANARY_ID=$(curl \
    localhost:8080/gate/applications/canaryapp/pipelineConfigs/Istio%20Simple%20Deploy \
    | jq -r '.id')
jq '(.stages[] | select(.refId == "9") | .pipeline) |= env.PIPELINE_CANARY_ID | (.stages[] | select(.refId == "8") | .pipeline) |= env.PIPELINE_CANARY_ID' ${BASH_SOURCE%/*}/../spinnaker/canary-deploy-istio.json | \
    curl -d@- -X POST \
    -H "Content-Type: application/json" -H "Accept: /" \
    http://localhost:8080/gate/pipelines

export PIPELINE_ID=$(curl \
    localhost:8080/gate/applications/canaryapp/pipelineConfigs/Simple%20Deploy \
    | jq -r '.id')
jq '(.stages[] | select(.refId == "9") | .pipeline) |= env.PIPELINE_ID | (.stages[] | select(.refId == "8") | .pipeline) |= env.PIPELINE_ID | (.stages[] | select(.refId == "16") | .canaryConfig | .canaryConfigId) |= env.CANARY_CONFIG_ID' ${BASH_SOURCE%/*}/../spinnaker/aca-deploy.json | \
    curl -d@- -X POST \
    -H "Content-Type: application/json" -H "Accept: /" \
    http://localhost:8080/gate/pipelines

export PIPELINE_CANARY_ID=$(curl \
    localhost:8080/gate/applications/canaryapp/pipelineConfigs/Istio%20Simple%20Deploy \
    | jq -r '.id')

jq '(.stages[] | select(.refId == "9") | .pipeline) |= env.PIPELINE_CANARY_ID | (.stages[] | select(.refId == "8") | .pipeline) |= env.PIPELINE_CANARY_ID | (.stages[] | select(.refId == "16") | .canaryConfig | .canaryConfigId) |= env.ISTIO_CANARY_CONFIG_ID' ${BASH_SOURCE%/*}/../spinnaker/aca-deploy-istio.json | \
    curl -d@- -X POST \
    -H "Content-Type: application/json" -H "Accept: /" \
    http://localhost:8080/gate/pipelines

