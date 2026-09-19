resource "proxmox_virtual_environment_vm" "nas" {
  name        = "nas"
  node_name   = "pve02"
  vm_id       = 102
  tags        = local.vm_tags["nas"]
  machine     = var.machine_type
  description = local.vm_descriptions["nas"]

  clone {
    vm_id = 901
    full  = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
    floating  = 2048
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 15
  }

  network_device {
    bridge = var.network_bridge
    vlan_id = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.20.102/24"
        gateway = var.network_gateway["20"]
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

  lifecycle {
    ignore_changes = [initialization[0].user_account[0].password]
  }
}
