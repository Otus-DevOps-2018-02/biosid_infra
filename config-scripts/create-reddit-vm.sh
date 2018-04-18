#!/bin/bash
if [[ "$1" != "" ]]; then
gcloud compute instances create reddit-app-full-$1 \
  --image-family reddit-full \
  --image-project=otus-infra-199514 \
  --machine-type=f1-micro \
  --tags puma-server \
  --restart-on-failure
else
echo "Invalid argument. Usage: create-reddit-vm.sh {i}"
fi
