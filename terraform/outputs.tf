output "vm_ips" {
  description = "Static IPv4 address of every Terraform-managed VM"
  value       = { for name, vm in local.vms : name => "192.168.${vm.vlan}.${vm.id}" }
}

output "ansible_inventory" {
  description = "Ansible inventory for the Terraform-managed VMs, committed as ansible/inventory/10-terraform.yml"
  value       = templatefile("${path.module}/templates/ansible-inventory.yml.tftpl", { vms = local.vms })
}
