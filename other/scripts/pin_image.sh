#!/bin/bash
# pin every image in ansible/playbooks/templates/ to its currently-running version.
#
# USAGE:
#   cd /opt/terraform/homelab-iac/ansible/playbooks/templates
#   bash pin_images.sh

set -e

echo "=== zabbix-agent-compose.yml.j2 (VMs) ==="
sed -i 's|image: zabbix/zabbix-agent2:alpine-7.0-latest|image: zabbix/zabbix-agent2@sha256:|' zabbix-agent-compose.yml.j2

echo "=== tools-portainer-compose.yml.j2 ==="
sed -i 's|image: portainer/portainer-ce:latest|image: portainer/portainer-ce@sha256:|' tools-portainer-compose.yml.j2

