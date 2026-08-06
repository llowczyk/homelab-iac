# --- proxmox provider ---
variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint URL"
}

variable "proxmox_api_token" {
  type        = string
  description = "proxmox api"
  sensitive   = true
}

variable "proxmox_ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key for Proxmox provider"
  default     = "~/.ssh/id_ed25519"
}

variable "vm_user_password" {
  type        = string
  description = "Password for the default user account on cloned VMs"
  sensitive   = true
}

# --- vm setup defaults ---
variable "network_gateway" {
  type    = string
  default = "192.168.1.1"
}

variable "dns_server" {
  type    = string
  default = "192.168.1.10"
}

variable "default_username" {
  type    = string
  default = "lukasz"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "network_bridge" {
  type    = string
  default = "vmbr0"
}

variable "datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "os_type" {
  type    = string
  default = "l26"
}

variable "agent_enabled" {
  type    = bool
  default = true
}

variable "machine_type" {
  type    = string
  default = "q35"
}
