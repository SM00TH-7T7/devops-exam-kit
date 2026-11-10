terraform {
  required_version = ">= 1.6.0, < 2.0.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "local" {}

variable "message" {
  type    = string
  default = "Hello from Terraform!"
}

resource "local_file" "exam" {
  filename        = "${path.module}/generated/hello.txt"
  content         = "${var.message}\n"
  file_permission = "0644"
}

output "file_path" {
  value = local_file.exam.filename
}
