#!/bin/bash

if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
    echo "Project is missing. Set GOOGLE_CLOUD_PROJECT"
    exit 1
fi

gcloud config set project $GOOGLE_CLOUD_PROJECT
gcloud config set compute/zone us-central1-f
gcloud beta container clusters create canary-tutorial \
    --machine-type=n1-standard-2 --cluster-version=1.12 \
    --enable-stackdriver-kubernetes \
    --scopes=gke-default,compute-ro \
    --addons Istio \
    --istio-config auth=MTLS_PERMISSIVE
gcloud container clusters get-credentials canary-tutorial

kubectl create ns canary
kubectl label namespace canary istio-injection=enabled