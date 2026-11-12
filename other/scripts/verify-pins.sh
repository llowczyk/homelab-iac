#!/usr/bin/env bash
# Checks every image pin against its registry.
#
#   image: repo@sha256:<digest>  # <tag>   -> asks the registry what <tag> points to now
#                                             OK       digest matches the tag
#                                             MOVED    tag was rebuilt since pinning (pin still valid, just older)
#                                             MISSING  digest no longer exists in the registry
#   image: repo@sha256:<digest>            -> NO TAG   cannot tell the version; add a "# <tag>" comment
#   image: repo:<tag>                      -> FLOATING not pinned by digest
#
# USAGE (from the repo root):
#   other/scripts/verify-pins.sh            # templates + other/compose
#   other/scripts/verify-pins.sh FILE...    # only these files
# Exit code 1 if anything is MISSING. Needs docker buildx (no daemon needed).

set -uo pipefail
cd "$(git rev-parse --show-toplevel)"
files=("$@")
[ ${#files[@]} -eq 0 ] && mapfile -t files < <(ls ansible/playbooks/templates/*.j2 other/compose/*.y*ml 2>/dev/null)

digest_of() { docker buildx imagetools inspect "$1" 2>/dev/null | awk '/^Digest:/{print $2; exit}'; }

out=$(mktemp); trap 'rm -f "$out"' EXIT
for f in "${files[@]}"; do
  grep -nE '^\s*image:' "$f" | while IFS= read -r line; do
    n=${line%%:*}
    ref=$(sed -E 's/^[0-9]+:\s*image:\s*([^ #]+).*/\1/' <<<"$line")
    tag=$(sed -nE 's/.*#\s*([^ ]+)\s*$/\1/p' <<<"$line")
    where="$f:$n"
    if [[ $ref != *@sha256:* ]]; then
      printf 'FLOATING  %-45s %s\n' "$ref" "$where"; continue
    fi
    img=${ref%@*}; want=${ref#*@}
    if [ -z "$tag" ]; then
      if [ -n "$(digest_of "$ref")" ]; then printf 'NO TAG    %-45s %s\n' "$img" "$where"
      else printf 'MISSING   %-45s %s (digest gone, no tag)\n' "$img" "$where"; fi
      continue
    fi
    got=$(digest_of "$img:$tag")
    if [ "$got" = "$want" ]; then printf 'OK        %-45s %s\n' "$img:$tag" "$where"
    elif [ -n "$(digest_of "$ref")" ]; then printf 'MOVED     %-45s %s (tag now %s)\n' "$img:$tag" "$where" "${got:0:19}"
    else printf 'MISSING   %-45s %s\n' "$img:$tag" "$where"; fi
  done
done | tee "$out"
! grep -q '^MISSING' "$out"
