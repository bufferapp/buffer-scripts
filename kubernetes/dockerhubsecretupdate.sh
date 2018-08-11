#!/bin/bash

# This will replace all matching Docker Registry secrets with new values
# This is useful if you need to quickly update a password for your Docker Hub
# account to pull images

USERNAME="<docker-hub-username>"
PASSWORD="<password>"
EMAIL="<account-email>"

SECRET_NAME="dhbufferapp"
DOCKER_SERVER="https://index.docker.io/v1/"

NSS=($(kubectl get ns --output=jsonpath={.items..metadata.name}))

for NS in "${NSS[@]}"
do
  O="$(kubectl -n $NS get secrets $SECRET_NAME)"
  code=$?
  if [[ "$code" == "0" ]]; then
    kubectl -n $NS delete secret $SECRET_NAME
    kubectl -n $NS create secret docker-registry $SECRET_NAME \
      --docker-server=$DOCKER_SERVER \
      --docker-username=$USERNAME \
      --docker-password=$PASSWORD \
      --docker-email=$EMAIL
    echo "$NS done"
  else
    echo "$NS skipped"
  fi
done

echo "New secrets applied"
