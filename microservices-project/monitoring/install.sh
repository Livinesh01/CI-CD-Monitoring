#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="monitoring"

kubectl get ns "$NAMESPACE" >/dev/null 2>&1 || kubectl create ns "$NAMESPACE"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null
helm repo update >/dev/null

# kube-prometheus-stack (Prometheus + Grafana)
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n "$NAMESPACE" \
  -f values-kube-prometheus-stack.yaml

# Loki
helm upgrade --install loki grafana/loki \
  -n "$NAMESPACE" \
  -f values-loki.yaml

# Promtail
helm upgrade --install promtail grafana/promtail \
  -n "$NAMESPACE" \
  -f values-promtail.yaml

echo "\nInstalled monitoring stack in namespace '$NAMESPACE'."
echo "Grafana admin password: 'admin' (change in values-kube-prometheus-stack.yaml)."
echo "To port-forward Grafana: kubectl -n $NAMESPACE port-forward svc/kube-prometheus-stack-grafana 3000:80"

