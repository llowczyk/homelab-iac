resource "proxmox_virtual_environment_vm" "monitoring" {
  name        = "monitor"
  node_name   = "pve02"
  vm_id       = 104
  tags        = local.vm_tags["monitoring"]
  machine     = var.machine_type
  description = local.vm_descriptions["monitoring"]

  clone {
    vm_id = 901
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
    vlan_id = 10
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.10.104/24"
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
