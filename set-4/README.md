# Set 4: Scaling, monitoring and Jenkins

Run commands from the repository root. First follow the [common setup](../README.md)
for Python dependencies and image build/import. Export `IMAGE=exam-flask:v1` in
this terminal. These files reuse `app/app.py`, the root Dockerfile and scripts.

## Deploy and scale

```bash
bash scripts/deploy.sh 4
kubectl -n exam-set-4 scale deployment/flask --replicas=3
kubectl -n exam-set-4 rollout status deployment/flask --timeout=180s
kubectl -n exam-set-4 get pods -l app=flask -o wide
kubectl -n exam-set-4 get deployment flask
```

Expect READY `3/3`. Reapplying the app manifest resets replicas to one.

## Install the small monitoring examples when practicing

No Helm or Operator is needed. This creates only resources in this set's namespace.

```bash
kubectl apply -f set-4/monitoring.yaml
kubectl -n exam-set-4 rollout status deployment/prometheus --timeout=180s
kubectl -n exam-set-4 rollout status deployment/grafana --timeout=180s
kubectl -n exam-set-4 port-forward service/flask 5000:80
```

In another terminal, generate traffic:

```bash
for i in $(seq 1 30); do curl -fsS http://localhost:5000/; done
curl -fsS http://localhost:5000/metrics | grep exam_requests_total
kubectl -n exam-set-4 port-forward service/prometheus 9090:9090
```

In another terminal after about 15 seconds:

```bash
curl -fsSG http://localhost:9090/api/v1/query --data-urlencode 'query=up{job="flask"}'
curl -fsSG http://localhost:9090/api/v1/query --data-urlencode 'query=sum(exam_requests_total)'
kubectl -n exam-set-4 port-forward service/grafana 3000:3000
```

Expect three `up` series with value `1` (DNS discovery refresh can take ~30s),
and a request count. A headless Service allows Prometheus to discover each pod
rather than repeatedly scrape a load-balanced Service. A port-forward sends its
traffic to one selected pod; a counter of zero on other pods is normal.

Open port 3000 in Killercoda Traffic/Ports. Log in `admin` / `admin` and change
the lab password. Prometheus is automatically provisioned as the data source.
Choose Dashboards → New → New dashboard → Add visualization → Prometheus.
Enter `sum(exam_requests_total)` in Code query mode, select Stat visualization,
Apply, and save as `Exam requests`. For rate use `sum(rate(exam_requests_total[1m]))`.
Prometheus at port 9090 → Status → Targets also shows pod health. This measures
app requests; it does not collect node CPU/memory. Data is ephemeral on pod replacement.

## Jenkins automation

Follow root Jenkins installation and Set 3's Pipeline creation steps, changing
Script Path to `set-4/Jenkinsfile`. The host agent needs label `killercoda`, Docker,
Python, kubectl with the lab kubeconfig, sudo/ctr and worker SSH as the root helper
requires. Build with Parameters → IMAGE_REPOSITORY `exam-flask` → Build. The pipeline tests,
builds a unique tag, loads all nodes and deploys the app; monitoring is installed
with the commands above. Verify the green stages and `kubectl -n exam-set-4 get pods`.

Stop port-forwards with Ctrl+C. Cleanup: `kubectl delete namespace exam-set-4`.
