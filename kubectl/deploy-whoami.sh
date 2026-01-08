#!/bin/bash
SCRIPT_DIR=$(dirname "$0")

NAMESPACE="example"

# Create Namespace
if ! kubectl get namespace ${NAMESPACE} ; then
  kubectl create namespace ${NAMESPACE}
fi

kubectl apply -n $NAMESPACE -f "$SCRIPT_DIR"/whoami.yaml