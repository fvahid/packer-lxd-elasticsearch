packer {
  required_plugins {
    lxd = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/lxd"
    }
  }
}

source "lxd" "ubuntu" {
  image  = "ubuntu:22.04"
  virtual_machine = true
}

build {
  name    = "lxd-k3s"
  source "source.lxd.ubuntu" {
      name = "ubuntu-22.04-k3s"
      output_image = "ubuntu-22.04-k3s"
  }
  provisioner "shell" {
      inline = [
        "mkdir -p /var/lib/rancher/k3s/agent/images/",
      ]
  }
  provisioner "file" {
      source = "k3s-airgap-images-amd64.tar.gz"
      destination = "/var/lib/rancher/k3s/agent/images/"
  }
  provisioner "file" {
      source = "k3s"
      destination = "/usr/local/bin/"
  }
  provisioner "shell" {
      inline = [
        "chmod +x /usr/local/bin/k3s",
      ]
  } 
  provisioner "file" {
      source = "install.sh"
      destination = "/usr/local/bin/"
  }
  provisioner "shell" {
      inline = [
        "chmod +x /usr/local/bin/install.sh",
      ]
  }
  provisioner "shell" {
      inline = [
        "INSTALL_K3S_VERSION='v1.25.3+k3s1' INSTALL_K3S_EXEC='--disable=traefik' K3S_NODE_NAME=kuber INSTALL_K3S_SKIP_DOWNLOAD=true /usr/local/bin/install.sh",
      ]
      max_retries = 3
      timeout = "5m"
  }
  provisioner "file" {
      pause_before = "60s"
      source = "elastic/crds.yaml"
      destination = "/var/lib/rancher/k3s/server/manifests/"
  }
  provisioner "file" {
      source = "elastic/operator.yaml"
      destination = "/var/lib/rancher/k3s/server/manifests/"
  }
  provisioner "file" {
      source = "elastic/secret.yaml"
      destination = "/var/lib/rancher/k3s/server/manifests/"
  }
}

