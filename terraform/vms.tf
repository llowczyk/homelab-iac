locals {
  # Templates are node-local: 900 lives on pve01, 901 on pve02.
  template_by_node = {
    pve01 = 900
    pve02 = 901
  }

  # One entry per Terraform-managed VM. The map key is the VM name.
  # IP convention: 192.168.<vlan>.<id>/24, gateway taken from var.network_gateway.
  # clone = false -> VM was not created by cloning, so no clone block is declared.
  vms = {
    nas         = { node = "pve02", id = 102, vlan = 20, cores = 2, memory = 4096, floating = 2048, disk = 15, clone = true }
    proxy       = { node = "pve01", id = 103, vlan = 10, cores = 4, memory = 3072, floating = 2048, disk = 15, clone = true }
    monitor     = { node = "pve02", id = 104, vlan = 10, cores = 4, memory = 8192, floating = 5120, disk = 50, clone = true }
    tools       = { node = "pve01", id = 105, vlan = 10, cores = 4, memory = 4096, floating = 2048, disk = 40, clone = true }
    torrentbox  = { node = "pve02", id = 106, vlan = 30, cores = 2, memory = 4096, floating = 2048, disk = 15, clone = true }
    mediaserver = { node = "pve02", id = 107, vlan = 20, cores = 2, memory = 6144, floating = 4096, disk = 20, clone = true }
    jumpbox     = { node = "pve01", id = 108, vlan = 10, cores = 2, memory = 2048, floating = 1024, disk = 15, clone = true }
    gameserver  = { node = "pve01", id = 113, vlan = 10, cores = 2, memory = 6144, floating = 4096, disk = 50, clone = true }
  }
}

module "vm" {
  source   = "./modules/vm"
  for_each = local.vms

  name        = each.key
  node_name   = each.value.node
  vm_id       = each.value.id
  tags        = local.vm_tags[each.key]
  description = local.vm_descriptions[each.key]

  template_vm_id  = each.value.clone ? local.template_by_node[each.value.node] : null
  cores           = each.value.cores
  memory          = each.value.memory
  memory_floating = each.value.floating
  disk_size       = each.value.disk

  vlan_id    = each.value.vlan
  ip_address = "192.168.${each.value.vlan}.${each.value.id}/24"
  gateway    = var.network_gateway[tostring(each.value.vlan)]

  machine_type   = var.machine_type
  datastore_id   = var.datastore_id
  network_bridge = var.network_bridge
  dns_server     = var.dns_server
  username       = var.default_username
  ssh_public_key = trimspace(file(var.ssh_public_key_path))
  password       = var.vm_user_password
  os_type        = var.os_type
  agent_enabled  = var.agent_enabled
}
