#!/usr/bin/env bash
# Pins one image to a new tag by digest, everywhere it is used (or only in the files given).
#
# USAGE (from the repo root):
#   other/scripts/bump-image.sh IMAGE TAG [FILE...]
#   other/scripts/bump-image.sh lscr.io/linuxserver/sonarr 4.0.20.3014-ls329
#   other/scripts/bump-image.sh postgres 15.19-alpine ansible/playbooks/templates/tools-wikijs-compose.yml.j2
#
# Resolves IMAGE:TAG to its multi-arch index digest with docker buildx and rewrites
#   image: IMAGE@sha256:<old> / image: IMAGE:<tag>   ->   image: IMAGE@sha256:<new>  # TAG
# Refuses if IMAGE is pinned to different versions in different files and no FILE is given
# (e.g. postgres for Wiki.js vs Zabbix). Prints the git diff at the end. Nothing is committed.

set -euo pipefail
[ $# -ge 2 ] || { sed -n '2,12p' "$0"; exit 2; }
img=$1 tag=$2; shift 2
cd "$(git rev-parse --show-toplevel)"

esc=$(sed 's/[.[\*^$/]/\\&/g' <<<"$img")
pat="^\s*image:\s*${esc}[@:]"
if [ $# -gt 0 ]; then files=("$@"); else
  mapfile -t files < <(grep -lE "$pat" ansible/playbooks/templates/*.j2 other/compose/*.y*ml 2>/dev/null || true)
fi
[ ${#files[@]} -gt 0 ] || { echo "no 'image: $img' found" >&2; exit 1; }

current=$(grep -hE "$pat" "${files[@]}" | sed -E 's/^\s*image:\s*([^ #]+).*/\1/' | sort -u)
if [ $# -eq 0 ] && [ "$(wc -l <<<"$current")" -gt 1 ]; then
  echo "'$img' is pinned to different versions; name the file(s) to bump:" >&2
  grep -nE "$pat" "${files[@]}" >&2; exit 1
fi

new=$(docker buildx imagetools inspect "$img:$tag" | awk '/^Digest:/{print $2; exit}')
[[ $new == sha256:* ]] || { echo "could not resolve $img:$tag" >&2; exit 1; }

for f in "${files[@]}"; do
  sed -i -E "s|^(\s*image:\s*)${esc}[@:][^ #]*\s*(#.*)?$|\1${img}@${new}  # ${tag}|" "$f"
  echo "pinned $img:$tag ($new) in $f"
done
git --no-pager diff --stat -- "${files[@]}"
