resource "proxmox_virtual_environment_vm" "jumpbox" {
  name        = "jumpbox"
  node_name   = "pve01"
  vm_id       = 108
  tags        = local.vm_tags["jumpbox"]
  machine     = var.machine_type
  description = local.vm_descriptions["jumpbox"]

  clone {
    vm_id = 900
    full  = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
    floating  = 1024
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = 15
  }

  network_device {
    bridge = var.network_bridge
    vlan_id = 10
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.10.108/24"
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
