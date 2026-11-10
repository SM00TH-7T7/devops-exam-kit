# Set 5: Terraform with a local provider

No cloud account or credentials. Terraform downloads the `hashicorp/local` provider
and manages a text file on this machine. Internet is needed for installation/init.
Start in the repository root.

## Install Terraform if missing (official Ubuntu apt repository)

```bash
sudo apt-get update
sudo apt-get install -y curl gnupg lsb-release
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /tmp/hashicorp-archive-keyring.gpg
sudo install -m 0644 /tmp/hashicorp-archive-keyring.gpg /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install -y terraform
terraform version
```

## Exact lifecycle

```bash
cd set-5
terraform init
terraform fmt -check
terraform validate
terraform plan -out=exam.tfplan
terraform show exam.tfplan
terraform apply exam.tfplan
cat generated/hello.txt
terraform output file_path
terraform state list
terraform plan
```

`init` downloads the provider; `plan` previews; `apply` executes the saved plan.
Expect `Hello from Terraform!`, `local_file.exam` in state, then `No changes`.
A saved plan applies without a second yes prompt. Commit `.terraform.lock.hcl`
after init to preserve the selected provider version; do not commit state or plans.

Change a variable and verify:

```bash
terraform plan -var='message=Updated for exam' -out=exam.tfplan
terraform apply exam.tfplan
cat generated/hello.txt
```

## Destroy

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
test ! -e generated/hello.txt && echo 'Managed file removed'
terraform state list
```

The state list is now empty. To demonstrate the literal destroy command as well:

```bash
terraform apply -auto-approve
terraform destroy -auto-approve
test ! -e generated/hello.txt && echo 'Destroy verified'
cd ..
```

Auto-approve skips the interactive `yes`; use it only in this disposable exercise.
Destroy removes the managed file, but may leave an empty directory and state files.
State is Terraform's record of what it owns; deleting state is not a replacement
for destroy. `local_file` content is stored in state, so use non-secret data here.
