#!/bin/bash
SCRIPT_DIR=$(dirname "$0")

REPOSITORY="oci://ghcr.io/weaveworks/charts"
VERSION="4.0.36"

NAMESPACE="weave"
CHART_NAME="weave-gitops"

# Create Namespace
if ! kubectl get namespace ${NAMESPACE} ; then
  kubectl create namespace ${NAMESPACE}
fi

if ! kubectl get secret -n ${NAMESPACE} ${TLS_STORE_NAME} ; then
  kubectl create secret tls ${TLS_STORE_NAME} \
          -n ${NAMESPACE} \
          --cert="${SCRIPT_DIR}"/cert/gitops.jwausle.de.pem \
          --key="${SCRIPT_DIR}"/cert/gitops.jwausle.de.key
fi


# Create docker secret as imagePullSecrets
TMP_FILE=$(mktemp -t weave-values-XXX)
cat <<EOF > "${TMP_FILE}"
adminUser:
  create: true
  username: admin
  passwordHash: \$2a\$10\$aYpLw4FLO4PUBQ41WvH4r.4zikdt41ZlbwpTV1m6G.oZk6sNBP3aq
# flux >v0.32
listOCIRepositories: true
EOF

helm upgrade --install weave ${REPOSITORY}/$CHART_NAME \
     -n $NAMESPACE \
     --version ${VERSION} \
     --values "${TMP_FILE}"

TMP_FILE=$(mktemp -t workpload-XXX)
cat <<EOF > "$TMP_FILE"
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: weave-tls
  namespace: $NAMESPACE
spec:
  entryPoints:
    - websecure
  routes:
    - match: PathPrefix(\`/\`)
      kind: Rule
      services:
        - name: weave-weave-gitops
          port: http
  tls: {}
EOF

kubectl apply -f "$TMP_FILE"