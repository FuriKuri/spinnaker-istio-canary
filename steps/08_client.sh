#!/bin/bash

 kubectl -n canary run injector --image=furikuri/curl -- \
    /bin/sh -c "while true; do curl -sS --max-time 3 \
    http://canaryapp:8080/; done"

kubectl -n default run injector --image=furikuri/curl -- \
    /bin/sh -c "while true; do curl -sS --max-time 3 \
    http://canaryapp:8080/; done"