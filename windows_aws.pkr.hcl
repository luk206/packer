packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" { default = "us-east-1" }

source "amazon-ebs" "windows" {
  ami_name       = "Windows {{timestamp}}"
  communicator   = "winrm"
  instance_type  = "t2.medium"
  region         = var.region
  user_data_file = "windows_bootstrap.ps1"
  winrm_insecure = true
  winrm_port     = "5986"
  winrm_timeout  = "15m"
  winrm_use_ssl  = true
  winrm_username = "Administrator"

  source_ami_filter {
    filters = {
      name                = "*Windows_Server-2012*English-64Bit-Base*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["801119661308"]
  }
}

build {
  sources = [
    "source.amazon-ebs.windows",
  ]

  provisioner "ansible" {
    playbook_file    = "./windows_playbook.yml"
    user             = "Administrator"
    use_proxy        = false
    ansible_env_vars = ["no_proxy=\"*\""]
    extra_arguments = [
      "-e",
      "ansible_winrm_server_cert_validation=ignore"
    ]
  }
}
