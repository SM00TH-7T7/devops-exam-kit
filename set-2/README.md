# Set 2: Dockerized Flask, Service and ConfigMap

Run commands from the repository root. First follow the [common setup](../README.md)
for Python dependencies and image build/import. Export `IMAGE=exam-flask:v1` in
this terminal. These files reuse `app/app.py`, the root Dockerfile and scripts.

## Run and verify

A ConfigMap holds non-secret settings; a Service gives matching pods a stable
cluster address. `port: 80` forwards to the container's `targetPort: 5000`.

```bash
bash scripts/deploy.sh 2
kubectl -n exam-set-2 get deployment,pods,service,configmap
kubectl -n exam-set-2 get endpointslices -l kubernetes.io/service-name=flask
kubectl -n exam-set-2 port-forward service/flask 5000:80
```

In another terminal: `curl -fsS http://localhost:5000/`. Expect
`Hello from Set 2 ConfigMap!` and `secret_configured: false`.

## Change configuration

In another terminal while port-forward runs:

```bash
kubectl -n exam-set-2 patch configmap flask-config --type merge -p '{"data":{"APP_MESSAGE":"Updated in the exam"}}'
kubectl -n exam-set-2 rollout restart deployment/flask
kubectl -n exam-set-2 rollout status deployment/flask --timeout=180s
```

Environment variables are read at pod creation, so restart is required. Restart
the port-forward if its selected pod was replaced. Curl again to see the updated
message. Reapplying `k8s.yaml` resets the ConfigMap to the example value.
Stop port-forward; cleanup: `kubectl delete namespace exam-set-2`.
