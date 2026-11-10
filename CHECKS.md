# Creation-time checks

Passed lightweight checks:

- Python AST parsing: 2 files (application and tests).
- `bash -n`: all 6 shell scripts.
- YAML parsing: 7 Kubernetes/workflow files, including the embedded Prometheus
  and Grafana YAML strings inside ConfigMaps.
- `bash -n`: every Bash command block in all 7 READMEs.
- JSON parsing of the Dockerfile CMD array.
- Requirements line format checks.

These checks validate syntax, not application behavior or external compatibility.
Terraform and Groovy/Jenkins tooling were not installed, so `terraform fmt`,
`terraform validate`, and Jenkins controller validation were not run. Dockerfile
build validation, Kubernetes API schema validation, GitHub workflow execution,
pytest, dependency installation, vulnerability scans and cluster deployment were
not run. Commands for those practice-time checks are in the READMEs.

No services were installed, no images were built/pulled, no GitHub push was made,
and no Kubernetes resources were created or modified during kit creation.
