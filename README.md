# DevOps exam kit

Six short labs for Killercoda Kubernetes Playground, Ubuntu 24.04. All commands
start in the repository root (`cd /root/devops-exam-kit` if copied there).
Use a fresh playground. Each Kubernetes set uses its own `exam-set-N` namespace.
These are lab examples, with ephemeral monitoring storage and demo credentials.
Nothing has been deployed, installed, initialized with Git, or pushed by kit creation.

| Set | Open | Practice |
| --- | --- | --- |
| 1 | [README](set-1/README.md) | Flask, Git, Docker, Deployment |
| 2 | [README](set-2/README.md) | Service, ConfigMap |
| 3 | [README](set-3/README.md) | pytest, Jenkins, GitHub Actions |
| 4 | [README](set-4/README.md) | scaling, Prometheus, Grafana, Jenkins |
| 5 | [README](set-5/README.md) | Terraform local file lifecycle |
| 6 | [README](set-6/README.md) | delivery, troubleshooting, Secrets, scans |

## Common prerequisites and Python setup

Python, Git, Docker, kubectl are already installed in the target playground.
Run the following yourself when practicing; apt is only needed for missing extras.
Internet access is required for dependencies and image downloads.

```bash
python3 --version
git --version
docker version
kubectl version --client
kubectl get nodes
sudo apt-get update
sudo apt-get install -y python3-venv curl openssh-client
bash scripts/setup-python.sh
bash scripts/test.sh
```

Use `.venv/bin/python` rather than system pip (Ubuntu protects system Python).
The dependencies are in `app/requirements*.txt`. One Flask app serves `/`,
`/health`, `/metrics`. Gunicorn uses one worker so counters stay in one process.

## Build an image Kubernetes can actually run

Run this before Sets 1, 2, 4 or 6:

```bash
export IMAGE=exam-flask:v1
docker build -t "$IMAGE" .
bash scripts/load-image.sh "$IMAGE"
```

The helper saves Docker's image, then imports it into **each node's containerd**
namespace `k8s.io`. It assumes Killercoda's root SSH access from the control plane
to worker hostnames, sudo on the local node, and containerd's `ctr` on each node.
Run from the control-plane terminal. If SSH fails, use Killercoda's node terminals:
copy the archive below to each node (the platform's file-copy method or `scp`) and
run the import on **every** node. Keep the image name/tag identical.

```bash
docker save "$IMAGE" -o /tmp/exam-flask.tar
# On each node after copying the tar there:
sudo ctr -n k8s.io images import /tmp/exam-flask.tar
sudo ctr -n k8s.io images list | grep exam-flask
```

Alternatively use your public Docker Hub repository (replace YOUR_USER):

```bash
export IMAGE=docker.io/YOUR_USER/exam-flask:v1
docker login
docker build -t "$IMAGE" .
docker push "$IMAGE"
```

Then skip the import helper. Never leave `EXAM_IMAGE` unrendered: use
`scripts/deploy.sh N`, which substitutes `$IMAGE`. Use a new tag after code changes;
`IfNotPresent` can reuse old node images. No registry account is required for the
local import route. Docker image lists and Kubernetes containerd image lists differ.

## Optional Jenkins installation (Sets 3, 4, 6)

This runs Jenkins as the current lab user on the host so it can use the host's
Python, Docker, kubeconfig and SSH configuration. It is for this disposable lab.
Do not run an untrusted repository on this agent.

```bash
sudo apt-get update
sudo apt-get install -y fontconfig openjdk-21-jre curl
mkdir -p /tmp/exam-jenkins
curl -fL https://get.jenkins.io/war-stable/latest/jenkins.war -o /tmp/exam-jenkins/jenkins.war
export JENKINS_HOME="$PWD/.jenkins-lab"
java -jar /tmp/exam-jenkins/jenkins.war --httpPort=8081
```

Keep that terminal running. In another root terminal:

```bash
cat .jenkins-lab/secrets/initialAdminPassword
curl -I http://localhost:8081/login
```

Open port 8081 using Killercoda's Traffic/Ports browser. Unlock, install suggested
plugins, create a lab admin. Ensure **Git**, **Pipeline**, **JUnit** plugins are
installed under Manage Jenkins → Plugins. Under Manage Jenkins → Nodes → Built-In
Node → Configure, set label `killercoda` and at least one executor. This single-host
controller/executor arrangement is only for the lab. Jenkins does not bundle
Docker, Python or kubectl: the host must provide them. A separate Jenkins agent
must have the same tools, cluster access and image import access.
Stop with Ctrl+C. `.jenkins-lab/` is ignored by Git.

## Optional GitHub setup

The kit is ready to become the **root** of a repository. Set 1 explains local Git.
If you later choose to publish, create an empty GitHub repository, add its URL as
`origin`, then push `main`. No push has been performed. The tests workflow runs
on pushes/PRs; delivery is manual and requires a trusted self-hosted lab runner.

## Verification scope

Kit creation performs syntax checks only. It does not execute pytest, download
packages/images, build containers, contact a Kubernetes API, run Terraform, or
validate Jenkins with a live controller. Read `CHECKS.md` for the actual results.
Pinned teaching dependencies/images are reproducible starting points; security
scanners may report findings. Investigate and update affected pins, rebuild and
rescan before treating a delivery as successful. Scans intentionally fail on findings.

## References

- [Kubernetes ConfigMaps](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
- [Jenkins Pipeline syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [GitHub Python CI](https://docs.github.com/en/actions/tutorials/build-and-test-code/python)
- [Terraform local provider](https://registry.terraform.io/providers/hashicorp/local/latest/docs)
- [Prometheus configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
- [Grafana provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/)
