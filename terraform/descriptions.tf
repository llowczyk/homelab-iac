locals {
  vm_descriptions = {
    monitoring = <<-EOT
      ## monitoring

      - zabbix server (server + web + postgres db)
      - uptime kuma
      - managed via homelab-iac (terraform + ansible)
      - playbook: deploy-monitoring.yml
    EOT

    torrentbox = <<-EOT
      ## torrentbox

      - gluetun (wireguard vpn, surfshark)
      - transmission (routed through gluetun)
      - vpn-healthcheck (auto-restarts gluetun on vpn drop)
      - managed via homelab-iac (terraform + ansible)
      - playbook: deploy-torrentbox-apps.yml
    EOT

    mediaserver = <<-EOT
      ## mediaserver

      - jellyfin
      - jellyseerr
      - prowlarr / sonarr / radarr / bazarr
      - nas mounted at /mnt/nas
      - managed via homelab-iac (Terraform + Ansible)
      - playbook: deploy-mediaserver-apps.yml
    EOT

    proxy = <<-EOT
      ## proxy

      - nginx proxy manager
      - Wildcard cert (*.lab)
      - managed via homelab-iac (terraform + ansible)
      - playbook: deploy-proxy-apps.yml
    EOT

    tools = <<-EOT
      ## tools

      - portainer (manager)
      - grafana + loki
      - promtail ships logs here from every vm
      - dbgate
      - managed via homelab-iac (terraform + ansible)
      - playbook: deploy-tools-apps.yml
    EOT

    nas = <<-EOT
      ## nas

      - nfs export (192.168.1.0/24) + samba
      - 2TB disk passed through via scsi1 — MANUAL attach, not terraform-managed
      - Disk UUID: cae72027-5bd7-4091-b187-4c3a8a4bc3e8
      - managed via homelab-iac (terraform + ansible)
      - playbook: deploy-nas.yml
    EOT
 }
}
