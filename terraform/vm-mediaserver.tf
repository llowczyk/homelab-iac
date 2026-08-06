resource "proxmox_virtual_environment_vm" "mediaserver" {
  name        = "mediaserver"
  node_name   = "pve02"
  vm_id       = 103
  tags        = local.vm_tags["mediaserver"]
  machine     = var.machine_type
  description = local.vm_descriptions["mediaserver"]

  clone {
    vm_id = 901
    full  = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 6144
    floating  = 4096
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 20
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.1.103/24"
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
