resource "proxmox_virtual_environment_vm" "gameserver" {
  name        = "gameserver"
  node_name   = "pve01"
  vm_id       = 113
  tags        = local.vm_tags["gameserver"]
  machine     = var.machine_type
  description = local.vm_descriptions["gameserver"]

  clone {
    vm_id = 900
    full  = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 12288
    floating  = 8192
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 50
  }

  network_device {
    bridge  = var.network_bridge
    vlan_id = 10
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.10.113/24"
        gateway = var.network_gateway["10"]
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
