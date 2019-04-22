#!/bin/bash

kubectl delete svc -n default canaryapp-ext	
kubectl delete svc -n default canaryapp
kubectl delete deployment -n default injector
kubectl delete deployment -n default canaryapp

kubectl delete --as=admin --as-group=system:masters -f ${BASH_SOURCE%/*}/../k8s/rbac-setup.yml

cat ${BASH_SOURCE%/*}/../k8s/prometheus-service.yml | \
    sed "s/_stackdriver_project_id:.*/_stackdriver_project_id: $GOOGLE_CLOUD_PROJECT/" | \
    sed "s/_kubernetes_cluster_name:.*/_kubernetes_cluster_name: canary-tutorial/" | \
    sed "s/_kubernetes_location:.*/_kubernetes_location: us-central1-f/" | \
    kubectl delete -f -


kubectl delete -f ${BASH_SOURCE%/*}/../k8s/quick-install.yml

