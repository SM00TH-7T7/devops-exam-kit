# Set 6: Flask delivery, Secrets, troubleshooting and security

Run commands from the repository root. First follow the [common setup](../README.md)
for Python dependencies and image build/import. Export `IMAGE=exam-flask:v1` in
this terminal. These files reuse `app/app.py`, the root Dockerfile and scripts.

## Secret and deployment

A Secret holds sensitive values separately from the Deployment. It is base64
encoded in API output, not encrypted by base64. Never commit a real token.
The app only returns whether a token exists, never its value.

```bash
kubectl create namespace exam-set-6 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n exam-set-6 create secret generic flask-secret --from-literal=API_TOKEN=exam-demo-only --dry-run=client -o yaml | kubectl apply -f -
bash scripts/deploy.sh 6
kubectl -n exam-set-6 get secret flask-secret
kubectl -n exam-set-6 port-forward service/flask 5000:80
```

In another terminal: `curl -fsS http://localhost:5000/`. Expect
`secret_configured: true`. Secret changes used as environment variables need
`kubectl -n exam-set-6 rollout restart deployment/flask` and a new port-forward.

## CI/CD and scans

```bash
bash scripts/setup-python.sh
bash scripts/test.sh
bash scripts/scan.sh
```

Bandit checks Python source; pip-audit checks dependency advisories; Trivy scans
repo files for vulnerabilities, secrets and misconfigurations. These commands can
fail on findings: read the package/advisory or rule, update or fix it, then repeat.
Do not suppress findings simply to get a green build. Trivy pulls an image/DB only
when you run it. To scan a built image too (after `docker build`):

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.58.2 image --severity HIGH,CRITICAL --exit-code 1 "$IMAGE"
```

The socket gives the scanner Docker daemon access; use the trusted image in this
lab. Image scanning includes base OS packages, which source dependency scans omit.
The Deployment also runs non-root, drops Linux capabilities, disables privilege
escalation, and uses health probes and resource limits.

For Jenkins, follow the root installation and Set 3 Pipeline instructions with
Script Path `set-6/Jenkinsfile`, label `killercoda`, IMAGE_REPOSITORY parameter `exam-flask`.
Create the namespace and demo Secret above first. Tests and scans gate build,
load and deploy; verify successful stages and the rollout.

For GitHub Actions, `.github/workflows/delivery.yml` provides the same sequence.
In your own repository → Settings → Actions → Runners → New self-hosted runner →
Linux x64, follow GitHub's generated download/configuration commands on the
Killercoda control-plane host. They include a short-lived registration token;
use those exact generated commands, never commit the token. Add custom label
`killercoda`, run `./run.sh`, and keep the runner alive. It must have the same
Docker, sudo/ctr, Python, kubeconfig and worker SSH access as your shell.
Then Actions → Flask delivery (manual lab) → Run workflow. Hosted runners cannot
reach this ephemeral playground. Use a trusted private lab repo and remove the
runner in Settings when done. The tests workflow needs no self-hosted runner.

## Troubleshooting sequence

```bash
kubectl -n exam-set-6 get pods -o wide
kubectl -n exam-set-6 describe deployment flask
kubectl -n exam-set-6 describe pods -l app=flask
kubectl -n exam-set-6 logs deployment/flask --tail=50
kubectl -n exam-set-6 get events --sort-by=.metadata.creationTimestamp
kubectl -n exam-set-6 get service flask -o yaml
kubectl -n exam-set-6 get endpointslices -l kubernetes.io/service-name=flask
kubectl -n exam-set-6 get configmap flask-config
kubectl -n exam-set-6 get secret flask-secret
```

| Symptom | Inspect | Fix |
| --- | --- | --- |
| ImagePullBackOff | Pod events and image name | Import on every node or use a reachable public image |
| Pending | Pod events | Check resources and node scheduling |
| CrashLoopBackOff | Pod logs; `kubectl logs POD --previous -n exam-set-6` | Fix startup command or missing dependency |
| CreateContainerConfigError | Pod events | Create the referenced Secret/ConfigMap/key |
| Service has no endpoints | Labels, selectors, readiness | Match `app: flask`; make `/health` pass |
| Connection refused | Container/Service ports | Container 5000, Service 80, correct port-forward |

Optional controlled failure, affecting only this kit's Deployment:

```bash
kubectl -n exam-set-6 set image deployment/flask flask=exam-flask:missing-tag
kubectl -n exam-set-6 get pods
kubectl -n exam-set-6 describe pods -l app=flask
kubectl -n exam-set-6 rollout undo deployment/flask
kubectl -n exam-set-6 rollout status deployment/flask --timeout=180s
```

Wait for pod events if the pull failure has not appeared yet. Rollout undo restores
the prior pod template, not ConfigMap/Secret data. Stop port-forward processes.
Cleanup this set only: `kubectl delete namespace exam-set-6`.
