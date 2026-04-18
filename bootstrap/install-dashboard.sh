#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --create-namespace

kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: admin-user
    namespace: kubernetes-dashboard
EOF

DASHBOARD_SERVICE="$(
  kubectl -n kubernetes-dashboard get svc kubernetes-dashboard-kong-proxy \
    -o jsonpath='{.metadata.name}' 2>/dev/null || true
)"

if [ -z "${DASHBOARD_SERVICE}" ]; then
  DASHBOARD_SERVICE="$(
    kubectl -n kubernetes-dashboard get svc -o jsonpath='{.items[0].metadata.name}'
  )"
fi

cat <<EOF
Dashboard installed.

Next commands:
  kubectl -n kubernetes-dashboard create token admin-user
  kubectl -n kubernetes-dashboard port-forward svc/${DASHBOARD_SERVICE} 8443:443

Namespace bootstrap:
  ${ROOT_DIR}/bootstrap/apply-namespaces.sh
EOF
