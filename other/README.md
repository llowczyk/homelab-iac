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
- `bump-image.sh IMAGE TAG [FILE...]` - resolves a tag to its multi-arch
  digest and rewrites the pin as `IMAGE@sha256:...  # TAG` in templates and
  `other/compose/`. Refuses when the image is pinned to different versions
  in different files unless the files are named.
- `verify-pins.sh [FILE...]` - checks every pin against the registry:
  OK, MOVED (tag rebuilt since), MISSING (digest gone, exit 1), NO TAG,
  FLOATING. Needs `docker buildx`, no daemon.
