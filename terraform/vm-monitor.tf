resource "proxmox_virtual_environment_vm" "monitoring" {
  name        = "monitor"
  node_name   = "pve02"
  migrate     = true
  vm_id       = 102
  tags        = local.vm_tags["monitoring"]
  machine     = var.machine_type
  description = local.vm_descriptions["monitoring"]

  clone {
    vm_id = 900
    full  = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
    floating  = 5120
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 50
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.102/24"
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
