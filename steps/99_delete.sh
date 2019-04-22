#!/bin/bash

gcloud config set project $GOOGLE_CLOUD_PROJECT
gcloud config set compute/zone us-central1-f
gcloud container clusters delete canary-tutorial
