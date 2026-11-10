#!/usr/bin/env bash
# Killercoda alternative to a registry: import into containerd on EVERY node.
set -euo pipefail
image="${1:?Usage: scripts/load-image.sh image:tag}"
archive=$(mktemp --suffix=.tar)
trap 'rm -f "$archive"' EXIT
docker save "$image" -o "$archive"
nodes=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
while IFS= read -r node; do
  echo "Loading $image on $node"
  if [[ "$node" == "$(hostname)" ]]; then
    sudo ctr -n k8s.io images import "$archive"
  else
    ssh -o BatchMode=yes "root@$node" 'ctr -n k8s.io images import -' < "$archive"
  fi
done <<< "$nodes"
