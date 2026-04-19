#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HEADLAMP_NAMESPACE="headlamp"
HEADLAMP_RELEASE="headlamp"
HEADLAMP_REPO_NAME="headlamp"
HEADLAMP_REPO_URL="https://kubernetes-sigs.github.io/headlamp/"

helm repo add "${HEADLAMP_REPO_NAME}" "${HEADLAMP_REPO_URL}"
helm repo update

helm upgrade --install "${HEADLAMP_RELEASE}" "${HEADLAMP_REPO_NAME}/headlamp" \
  --namespace "${HEADLAMP_NAMESPACE}" \
  --create-namespace

kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: ${HEADLAMP_NAMESPACE}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: headlamp-admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: admin-user
    namespace: ${HEADLAMP_NAMESPACE}
EOF

HEADLAMP_SERVICE="$(
  kubectl -n "${HEADLAMP_NAMESPACE}" get svc "${HEADLAMP_RELEASE}" \
    -o jsonpath='{.metadata.name}' 2>/dev/null || true
)"

if [ -z "${HEADLAMP_SERVICE}" ]; then
  HEADLAMP_SERVICE="$(
    kubectl -n "${HEADLAMP_NAMESPACE}" get svc -o jsonpath='{.items[0].metadata.name}'
  )"
fi

HEADLAMP_SERVICE_PORT="$(
  kubectl -n "${HEADLAMP_NAMESPACE}" get svc "${HEADLAMP_SERVICE}" \
    -o jsonpath='{.spec.ports[0].port}'
)"

cat <<EOF
Headlamp installed.

Next commands:
  kubectl -n ${HEADLAMP_NAMESPACE} create token admin-user
  kubectl -n ${HEADLAMP_NAMESPACE} port-forward svc/${HEADLAMP_SERVICE} 4466:${HEADLAMP_SERVICE_PORT}

Then open:
  http://localhost:4466

Namespace bootstrap:
  ${ROOT_DIR}/bootstrap/apply-namespaces.sh
EOF
