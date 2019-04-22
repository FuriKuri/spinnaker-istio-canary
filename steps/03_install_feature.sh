#!/bin/bash

export HALYARD_POD=$(kubectl -n spinnaker get pods -l \
    stack=halyard,app=spin \
    -o=jsonpath='{.items[0].metadata.name}')

kubectl -n spinnaker exec $HALYARD_POD -- bash -c "hal config canary google enable"
kubectl -n spinnaker exec $HALYARD_POD -- bash -c "hal config canary google account add canary-tutorial --project $GOOGLE_CLOUD_PROJECT"
kubectl -n spinnaker exec $HALYARD_POD -- bash -c "hal config canary google edit --stackdriver-enabled=true"
kubectl -n spinnaker exec $HALYARD_POD -- bash -c "hal deploy apply"