resource "proxmox_virtual_environment_vm" "tools" {
  name        = "tools"
  node_name   = "pve01"
  vm_id       = 108
  tags        = local.vm_tags["tools"]
  machine     = var.machine_type
  description = local.vm_descriptions["tools"]

  clone {
    vm_id = 900
    full  = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 6144
    floating  = 2048
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 40
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.108/24"
        gateway = var.network_gateway
      }
    }

    user_account {
      username = var.default_username
      keys     = [trimspace(file(var.ssh_public_key_path))]
      password = var.vm_user_password
    }

    dns {
      servers = [var.dns_server]
    }
  }

  operating_system {
    type = var.os_type
  }

  agent {
    enabled = var.agent_enabled
  }
}
