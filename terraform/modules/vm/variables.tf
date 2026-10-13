variable "name" {
  type        = string
  description = "VM name"
}

variable "node_name" {
  type        = string
  description = "Proxmox node the VM lives on"
}

variable "vm_id" {
  type        = number
  description = "Proxmox VM ID"
}

variable "tags" {
  type        = list(string)
  description = "Proxmox tags"
}

variable "description" {
  type        = string
  description = "Proxmox VM description"
}

variable "template_vm_id" {
  type        = number
  default     = null
  description = "Template to full-clone from. null = no clone block (VM was not created by cloning)"
}

variable "machine_type" {
  type        = string
  description = "QEMU machine type"
}

variable "cores" {
  type        = number
  description = "vCPU cores"
}

variable "memory" {
  type        = number
  description = "Dedicated memory in MB"
}

variable "memory_floating" {
  type        = number
  description = "Floating (balloon minimum) memory in MB"
}

variable "disk_size" {
  type        = number
  description = "Boot disk size in GB"
}

variable "datastore_id" {
  type        = string
  description = "Datastore for the boot disk"
}

variable "network_bridge" {
  type        = string
  description = "Bridge for the network device"
}

variable "vlan_id" {
  type        = number
  description = "VLAN tag"
}

variable "ip_address" {
  type        = string
  description = "Static IPv4 address in CIDR notation"
}

variable "gateway" {
  type        = string
  description = "IPv4 gateway"
}

variable "dns_server" {
  type        = string
  description = "DNS server"
}

variable "username" {
  type        = string
  description = "Cloud-init user"
}

variable "ssh_public_key" {
  type        = string
  description = "Public key content for the cloud-init user"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "Cloud-init user password (changes ignored after creation)"
}

variable "os_type" {
  type        = string
  description = "Proxmox OS type"
}

variable "agent_enabled" {
  type        = bool
  description = "Enable the QEMU guest agent"
}
