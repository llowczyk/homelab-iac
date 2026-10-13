output "vm_ips" {
  description = "Static IPv4 address of every Terraform-managed VM"
  value       = { for name, vm in local.vms : name => "192.168.${vm.vlan}.${vm.id}" }
}
