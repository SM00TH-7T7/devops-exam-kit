#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p reports
.venv/bin/python -m pytest app -q --junitxml=reports/pytest.xml
