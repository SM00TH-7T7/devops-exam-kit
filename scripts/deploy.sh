#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
set_number="${1:?Usage: IMAGE=registry/user/image:tag scripts/deploy.sh 1|2|4|6}"
case "$set_number" in 1|2|4|6) ;; *) echo 'Choose 1, 2, 4 or 6' >&2; exit 1 ;; esac
: "${IMAGE:?Set IMAGE to a public registry image, or an image imported on every node}"
export SET_NUMBER="$set_number"
# Emit to a temporary file before applying, so render failures cannot be hidden.
manifest=$(mktemp)
trap 'rm -f "$manifest"' EXIT
python3 - <<'RENDER' > "$manifest"
import os
from pathlib import Path
text = Path(f"set-{os.environ['SET_NUMBER']}/k8s.yaml").read_text()
print(text.replace("EXAM_IMAGE", os.environ["IMAGE"]))
RENDER
kubectl apply -f "$manifest"
kubectl -n "exam-set-$set_number" rollout status deployment/flask --timeout=180s
