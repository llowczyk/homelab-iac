# other/

Scripts and reference files that are outside of Terraform/Ansible
automation.

## compose/

Reference copies of compose files running on manually-managed hosts.

## scripts/

Standalone scripts, run ad-hoc:

- `add-hosts-nmp.py` - adds NPM proxy hosts and wildcard cert via
  REST API. Used during the Pi to proxy-VM NPM migration.
- `pin_image.sh` - one-time bash script that pins the currently running
  image for existing Docker containers.
