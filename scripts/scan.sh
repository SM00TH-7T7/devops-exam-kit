#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
.venv/bin/bandit -q app/app.py
.venv/bin/pip-audit -r app/requirements.txt
# Trivy downloads its vulnerability DB; findings intentionally fail this command.
docker run --rm -v "$PWD:/src:ro" aquasec/trivy:0.58.2 fs --skip-dirs .venv --skip-dirs .jenkins-lab --skip-dirs .git --scanners vuln,secret,misconfig --severity HIGH,CRITICAL --exit-code 1 /src
