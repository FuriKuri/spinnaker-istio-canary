#!/bin/bash

kubectl apply --as=admin --as-group=system:masters -f \
    https://storage.googleapis.com/stackdriver-prometheus-documentation/rbac-setup.yml
curl -sS "https://storage.googleapis.com/stackdriver-prometheus-documentation/prometheus-service.yml" | \
    sed "s/_stackdriver_project_id:.*/_stackdriver_project_id: $GOOGLE_CLOUD_PROJECT/" | \
    sed "s/_kubernetes_cluster_name:.*/_kubernetes_cluster_name: canary-tutorial/" | \
    sed "s/_kubernetes_location:.*/_kubernetes_location: us-central1-f/" | \
    kubectl apply -f -

curl -sSL "https://www.spinnaker.io/downloads/kubernetes/quick-install.yml" | \
    sed 's/version:.*/version: 1.13.4/g' | kubectl apply -f -