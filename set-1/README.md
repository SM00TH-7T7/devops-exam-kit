# Set 1: Flask, Git, Docker and Deployment

Run commands from the repository root. First follow the [common setup](../README.md)
for Python dependencies and image build/import. Export `IMAGE=exam-flask:v1` in
this terminal. These files reuse `app/app.py`, the root Dockerfile and scripts.

## 1. Run Flask locally

```bash
.venv/bin/python app/app.py
```

In a second terminal: `curl -fsS http://localhost:5000/health` and
`curl -fsS http://localhost:5000/`. Expect `status: ok` and `Hello DevOps!`.
Stop with Ctrl+C. Flask's built-in server is only for local practice.

## 2. Practice Git locally

Replace the identity with your own. Run once from this folder:

```bash
git init -b main
git config user.name 'Exam Student'
git config user.email 'student@example.com'
git add .
git commit -m 'Add six DevOps lab sets'
git status
git log --oneline -1
git switch -c practice
printf '
Practice branch note.
' >> set-1/notes.md
git add set-1/notes.md
git commit -m 'Practice a branch commit'
git switch main
git merge practice
git log --oneline --graph --all
```

`git status` should be clean. `git diff` shows unstaged changes; `git diff --staged`
shows staged changes. `git restore FILE` discards an uncommitted file change.

## 3. Docker

After the root README's build/import commands:

```bash
docker run --rm -d --name exam-flask-local -p 5000:5000 "$IMAGE"
curl -fsS http://localhost:5000/health
docker logs exam-flask-local
docker stop exam-flask-local
```

## 4. Deployment

```bash
bash scripts/deploy.sh 1
kubectl -n exam-set-1 get deployment,pods -o wide
kubectl -n exam-set-1 logs deployment/flask
kubectl -n exam-set-1 port-forward deployment/flask 5000:5000
```

In another terminal: `curl -fsS http://localhost:5000/health`. Expect `ok`.
A Deployment maintains replicas and replaces failed pods. Stop port-forward
with Ctrl+C. Cleanup only this set: `kubectl delete namespace exam-set-1`.
