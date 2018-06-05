#!/bin/bash

if [[ $1 == "--list" ]]
then
app_external_ip=$(gcloud compute instances describe reddit-app --zone="europe-west1-d" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
db_external_ip=$(gcloud compute instances describe reddit-db --zone="europe-west1-d" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
db_internal_ip=$(gcloud compute instances describe reddit-db --zone="europe-west1-d" --format="value(networkInterfaces[0].networkIP)")

cat << EndOfJSON
{
    "app": {
        "hosts": [
            "appserver"
        ]
    },
    "db": {
        "hosts": [
            "dbserver"
        ]
    },
    "_meta": {
        "hostvars": {
            "appserver": {
                "ansible_host": "${app_external_ip}"
            },
            "dbserver": {
                "ansible_host": "${db_external_ip}",
                "internal_ip": "${db_internal_ip}"
            }
        }
    }
}
EndOfJSON
elif [[ $1 == "--host" ]]
then
  echo "{ }"
fi
