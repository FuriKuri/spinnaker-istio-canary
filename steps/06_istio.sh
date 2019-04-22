#!/bin/bash

kubectl apply -f ${BASH_SOURCE%/*}/../k8s/destionation.yaml
kubectl apply -f ${BASH_SOURCE%/*}/../k8s/gateway.yaml
kubectl apply -f ${BASH_SOURCE%/*}/../k8s/virutalservice.yaml