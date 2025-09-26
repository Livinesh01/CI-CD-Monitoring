## CI-CD Monitoring Microservices

<p align="center" style="font-family:Segoe UI, Roboto, Helvetica, Arial, sans-serif; font-weight:700; font-size:28px; letter-spacing:0.5px; margin: 12px 0;">
  Build · Test · Deploy · Monitor · Rollback
</p>

### What this project does
- Implements a microservices-based app with three services: `User`, `Product`, and `Order` (FastAPI/uvicorn images provided).
- End-to-end CI/CD:
  - Lint + unit test each service on every push/PR.
  - Build and push Docker images per service.
  - Optionally deploy to EKS; verifies rollout and rolls back on failure.
- Production-ready monitoring:
  - Kubernetes: Prometheus + Grafana (kube-prometheus-stack), Loki + Promtail, Alertmanager (Slack/Email).
  - Docker local stack for Prometheus/Grafana/Loki/Promtail/Alertmanager.

### Tech Stack

<p align="center">
  <a href="https://www.python.org/" title="Python: Primary language for services"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" alt="Python" width="48" height="48" /></a>
  &nbsp;&nbsp;
  <a href="https://fastapi.tiangolo.com/" title="FastAPI: Web framework for APIs"><img src="https://fastapi.tiangolo.com/img/logo-margin/logo-teal.png" alt="FastAPI" height="48" /></a>
  &nbsp;&nbsp;
  <a href="https://www.docker.com/" title="Docker: Containerization for all services"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg" alt="Docker" width="48" height="48" /></a>
  &nbsp;&nbsp;
  <a href="https://kubernetes.io/" title="Kubernetes: Orchestrates and scales services"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/kubernetes/kubernetes-plain.svg" alt="Kubernetes" width="48" height="48" /></a>
  &nbsp;&nbsp;
  <a href="https://aws.amazon.com/" title="AWS ECR/EKS: Image registry and managed K8s"><img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/amazonwebservices/amazonwebservices-original.svg" alt="AWS" width="48" height="48" /></a>
  &nbsp;&nbsp;
  <a href="https://github.com/features/actions" title="GitHub Actions: CI/CD pipelines"><img src="https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/githubactions.svg" alt="GitHub Actions" width="48" height="48" /></a>
  &nbsp;&nbsp;
  <a href="https://grafana.com/" title="Grafana: Dashboards and visualization"><img src="https://raw.githubusercontent.com/grafana/grafana/main/public/img/grafana_icon.svg" alt="Grafana" width="48" height="48" /></a>
  &nbsp;&nbsp;
  <a href="https://prometheus.io/" title="Prometheus: Metrics collection and alerting rules"><img src="https://raw.githubusercontent.com/prometheus/prometheus/main/documentation/images/prometheus-logo.svg" alt="Prometheus" height="48" /></a>
  &nbsp;&nbsp;
  <a href="https://grafana.com/oss/loki/" title="Loki: Log aggregation backend"><img src="https://raw.githubusercontent.com/grafana/loki/main/docs/sources/logo.png" alt="Loki" height="48" /></a>
</p>

### Rising Tech (roadmap)
<p align="center">
  <a href="https://argo-cd.readthedocs.io/" title="Argo CD: GitOps continuous delivery">
    <img src="https://raw.githubusercontent.com/argoproj/argo-cd/master/docs/assets/argo.png" alt="Argo CD" height="40" />
  </a>
  &nbsp;&nbsp;
  <a href="https://opentelemetry.io/" title="OpenTelemetry: Traces/Metrics/Logs instrumentation">
    <img src="https://raw.githubusercontent.com/open-telemetry/opentelemetry-specification/main/img/logos/opentelemetry-logo.png" alt="OpenTelemetry" height="40" />
  </a>
  &nbsp;&nbsp;
  <a href="https://keda.sh/" title="KEDA: Event-driven autoscaling on Kubernetes">
    <img src="https://raw.githubusercontent.com/kedacore/keda/main/images/keda-logo-transparent.png" alt="KEDA" height="40" />
  </a>
</p>

### Quick links
- Actions workflow: `.github/workflows/ci-cd.yml`
- Kubernetes manifests: `k8s/`
- Monitoring (K8s): `monitoring/values-*.yaml`, `monitoring/install.sh`, `monitoring/install.ps1`
- Monitoring (Docker): `monitoring/docker/`

---

## Monitoring (Prometheus, Grafana, Loki)
## Kubernetes RBAC & Secrets

Namespace and RBAC are defined under `k8s/`:
- `namespace.yaml` creates namespace `micro`
- `rbac.yaml` adds ServiceAccounts and Role/RoleBindings for reading ConfigMaps/Secrets
- `secrets.yaml` holds placeholder values (DB_URL, JWT_SECRET, SMTP_*). Edit before apply.

Apply:
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/user-service.yaml
kubectl apply -f k8s/product-service.yaml
kubectl apply -f k8s/order-service.yaml
```

Replace the image URIs in service manifests with your ECR URLs (the CI workflow pushes tags `latest` and commit SHA).

This repo includes a ready-to-install monitoring stack using Helm charts:

- Prometheus and Grafana via `kube-prometheus-stack`
- Loki for logs and Promtail as the log agent

Files are under `monitoring/`:
- `values-kube-prometheus-stack.yaml`
- `values-loki.yaml`
- `values-promtail.yaml`
- Install scripts: `install.sh` (bash) and `install.ps1` (PowerShell)

### Prerequisites
- A working kubeconfig pointing to your cluster (`kubectl get nodes` works)
- Helm v3 installed

### Install (Linux/macOS)
```bash
cd monitoring
bash install.sh
```

### Install (Windows PowerShell)
```powershell
cd monitoring
./install.ps1
```

### Access Grafana
Port-forward Grafana service:
```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
```
Then open `http://localhost:3000`. Default credentials:
- user: `admin`
- pass: `admin` (change in `values-kube-prometheus-stack.yaml`)

Grafana datasources are preconfigured:
- Prometheus (from kube-prometheus-stack)
- Loki at `http://loki.monitoring:3100`

### Logs with Loki
- Promtail is deployed as a DaemonSet and ships container logs to Loki
- In Grafana, go to Explore → Select Loki to query logs

### Uninstall
```bash
helm -n monitoring uninstall promtail || true
helm -n monitoring uninstall loki || true
helm -n monitoring uninstall kube-prometheus-stack || true
kubectl delete ns monitoring
```

### Docker-based Monitoring (no Kubernetes required)

Files under `monitoring/docker/` provide a local stack.

Run:
```bash
cd monitoring/docker
docker compose up -d
```

Open Grafana: `http://localhost:3000` (admin/admin)

Services:
- Prometheus: `http://localhost:9090`
- Loki: `http://localhost:3100`
- Grafana: `http://localhost:3000`
 - Alertmanager: `http://localhost:9093`

Stop:
```bash
docker compose down -v
```

### Alerts (Slack/Email)

- Kubernetes (Helm): edit `monitoring/values-kube-prometheus-stack.yaml` under `alertmanager.config`.
- Docker: edit `monitoring/docker/alertmanager/config.yml`.
- Replace Slack `api_url`, `channel`, and SMTP fields. Then restart:
  - `cd monitoring/docker && docker compose up -d`
