# Set 3: Jenkins Freestyle/Pipeline, GitHub Actions, Python testing

Work from the repository root. Follow the [common setup](../README.md) to create
`.venv` and optionally install Jenkins. Requirements are in `app/requirements-dev.txt`.

## Test locally

```bash
bash scripts/setup-python.sh
bash scripts/test.sh
cat reports/pytest.xml
```

Expect three passing tests: health endpoint, environment configuration without
leaking a token, and Prometheus output. Pytest returns nonzero on failure; Jenkins
and Actions therefore fail too. `reports/pytest.xml` is the JUnit-format result.

## Jenkins Freestyle

1. Make the kit available in your own Git repository (Set 1). In Jenkins choose
   New Item → Freestyle project → name `exam-freestyle`.
2. Source Code Management → Git → your repository URL; branch `*/main`.
   For a private repository select Jenkins credentials, never put tokens in a file.
3. Add Build Step → Execute shell → `bash set-3/freestyle.sh`.
4. Add Post-build Action → Publish JUnit test result report → `reports/pytest.xml`.
5. Save → Build Now. Open Console Output and Test Result. Expect SUCCESS and 3 tests.

To reproduce its exact shell step locally: `bash set-3/freestyle.sh`.

## Jenkins Pipeline

New Item → Pipeline → Definition: Pipeline script from SCM → SCM Git → repository
URL → branch `*/main` → Script Path `set-3/Jenkinsfile`. Save → Build Now.
The pipeline checks out, installs dependencies and tests; the post step publishes XML.
Console Output must show successful stages and a test report. A failed checkout or
install may leave no XML, hence `allowEmptyResults`; the failed stage still fails the job.

## GitHub Actions

`.github/workflows/tests.yml` is already in the correct location. After you choose
to publish the whole kit as the root of a GitHub repository, open Actions → Python CI.
It runs on push/PR or via Run workflow. Expect a green test job and downloadable
`test-report` artifact. `delivery.yml` is separately manual and is covered in Set 6.
No GitHub upload or service install is required to study or run the local tests.

Cleanup local generated files if desired: `rm -rf .venv reports`.
