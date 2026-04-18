#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "${ROOT_DIR}/k8s/namespaces/demo-services.yaml"
kubectl apply -f "${ROOT_DIR}/k8s/namespaces/legacy-services.yaml"
