#!/usr/bin/env bash
# Render ansible/inventory/10-terraform.yml from the Terraform "ansible_inventory" output.
#
#   render-inventory.sh                  run a quick plan and write the file
#   render-inventory.sh --check          run a quick plan and fail if the file is stale
#   render-inventory.sh --check tfplan   use an existing plan file (CI)
#
# Uses the plan's planned outputs, so no apply is needed and nothing changes in Proxmox.
# Run it where "terraform plan" already works (credentials in env / terraform.tfvars).
set -euo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"   # no git needed (the CI runner has none)
out="$repo/ansible/inventory/10-terraform.yml"

mode="write"
if [[ "${1:-}" == "--check" ]]; then mode="check"; shift; fi
plan="${1:-}"

cd "$repo/terraform"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT   # the plan file holds variable values, never keep it around

if [[ -z "$plan" ]]; then
  plan="$tmp/tfplan"
  terraform plan -refresh=false -input=false -out="$plan" >/dev/null
fi

terraform show -json "$plan" | jq -je '.planned_values.outputs.ansible_inventory.value' > "$tmp/inventory.yml"

if [[ "$mode" == check ]]; then
  if diff -u "$out" "$tmp/inventory.yml"; then
    echo "OK: $(basename "$out") matches terraform/vms.tf"
  else
    echo "::error::ansible/inventory/10-terraform.yml is stale. Run other/scripts/render-inventory.sh and commit the result."
    exit 1
  fi
else
  cp "$tmp/inventory.yml" "$out"
  echo "wrote $out"
fi
