Param(
  [string]$Namespace = "monitoring"
)

$ErrorActionPreference = "Stop"

if (-not (kubectl get ns $Namespace -o name 2>$null)) {
  kubectl create ns $Namespace | Out-Null
}

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts | Out-Null
helm repo add grafana https://grafana.github.io/helm-charts | Out-Null
helm repo update | Out-Null

# kube-prometheus-stack (Prometheus + Grafana)
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack `
  -n $Namespace `
  -f values-kube-prometheus-stack.yaml

# Loki
helm upgrade --install loki grafana/loki `
  -n $Namespace `
  -f values-loki.yaml

# Promtail
helm upgrade --install promtail grafana/promtail `
  -n $Namespace `
  -f values-promtail.yaml

Write-Host "`nInstalled monitoring stack in namespace '$Namespace'."
Write-Host "Grafana admin password: 'admin' (change in values-kube-prometheus-stack.yaml)."
Write-Host "To port-forward Grafana: kubectl -n $Namespace port-forward svc/kube-prometheus-stack-grafana 3000:80"

