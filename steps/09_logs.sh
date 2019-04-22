#!/bin/bash

kubectl -n default logs -f \
    $(kubectl -n default get pods -l run=injector \
    -o=jsonpath='{.items[0].metadata.name}')
