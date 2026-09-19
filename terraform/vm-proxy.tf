resource "proxmox_virtual_environment_vm" "proxy" {
  name        = "proxy"
  node_name   = "pve01"
  vm_id       = 103
  tags        = local.vm_tags["proxy"]
  machine     = var.machine_type
  description = local.vm_descriptions["proxy"]

  clone {
    vm_id = 900
    full  = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 3072
    floating  = 2048
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
        address = "192.168.10.103/24"
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
