#!/bin/bash

DECK_POD=$(kubectl -n spinnaker get pods -l \
    cluster=spin-deck,app=spin \
    -o=jsonpath='{.items[0].metadata.name}')
kubectl -n spinnaker port-forward $DECK_POD 8080:9000 >/dev/null &
