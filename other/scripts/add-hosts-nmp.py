#!/usr/bin/env python3
"""
recreate npm proxy hosts on a fresh instance via rest api, using a wildcard certificate (*.lab).

USAGE:
  1. put three files in a directory:
       wildcard_lab.crt   - the *.lab certificate
       wildcard_lab.key   - private key
       ca.crt             - root CA
  2. edit the CONFIG block below: NPM_URL, ADMIN_EMAIL, ADMIN_PASSWORD.
  3. review/edit the HOSTS list.
  4. run "python3 recreate_npm_hosts.py"

requires: pip install requests
"""

import argparse
import os
import requests

# ============================================================
# CONFIG — edit these before running
# ============================================================

NPM_URL = "http://<ip>:81"   # npm instance
ADMIN_EMAIL = ""             # login
ADMIN_PASSWORD = ""          # password

CERT_DIR = "."               # folder containing the 3 files below
WILDCARD_CRT = os.path.join(CERT_DIR, "wildcard_lab.crt")
WILDCARD_KEY = os.path.join(CERT_DIR, "wildcard_lab.key")
CA_CRT = os.path.join(CERT_DIR, "ca.crt") # set None to skip

HOSTS = [
    ("hostname1.lab",   "http",  "<ip>", 4444),
    ("hostname2.lab",   "https", "<ip>", 6666),
]

# ============================================================
# Script logic — shouldn't need to edit below this line
# ============================================================


def get_token():
    resp = requests.post(
        f"{NPM_URL}/api/tokens",
        json={"identity": ADMIN_EMAIL, "secret": ADMIN_PASSWORD},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()["token"]


def upload_wildcard_certificate(token, dry_run):
    """Uploads *.lab wildcard cert; returns its certificate_id."""
    if dry_run:
        print(f"[dry-run] would upload wildcard cert from {WILDCARD_CRT}")
        return -1

    for path in (WILDCARD_CRT, WILDCARD_KEY):
        if not os.path.isfile(path):
            raise FileNotFoundError(f"Required cert file not found: {path}")

    headers = {"Authorization": f"Bearer {token}"}

    resp = requests.post(
        f"{NPM_URL}/api/nginx/certificates",
        headers=headers,
        json={"provider": "other", "nice_name": "wildcard.lab"},
        timeout=10,
    )
    resp.raise_for_status()
    cert_id = resp.json()["id"]

    files = {
        "certificate": ("wildcard_lab.crt", open(WILDCARD_CRT, "rb"), "application/x-pem-file"),
        "certificate_key": ("wildcard_lab.key", open(WILDCARD_KEY, "rb"), "application/x-pem-file"),
    }
    if CA_CRT and os.path.isfile(CA_CRT):
        files["intermediate_certificate"] = ("ca.crt", open(CA_CRT, "rb"), "application/x-pem-file")

    try:
        resp = requests.post(
            f"{NPM_URL}/api/nginx/certificates/{cert_id}/upload",
            headers=headers,
            files=files,
            timeout=30,
        )
        resp.raise_for_status()
    finally:
        for f in files.values():
            f[1].close()

    print(f"[+] uploaded wildcard *.lab certificate (cert id {cert_id})")
    return cert_id


def create_proxy_host(token, domain, scheme, host, port, cert_id, dry_run):
    if dry_run:
        print(f"[dry-run] would create proxy host: {domain} -> "
              f"{scheme}://{host}:{port} (cert_id={cert_id})")
        return

    headers = {"Authorization": f"Bearer {token}"}
    payload = {
        "domain_names": [domain],
        "forward_scheme": scheme,
        "forward_host": host,
        "forward_port": port,
        "access_list_id": 0,
        "certificate_id": cert_id,
        "ssl_forced": True,
        "caching_enabled": False,
        "block_exploits": True,
        "allow_websocket_upgrade": True,
        "http2_support": True,
        "hsts_enabled": False,
        "hsts_subdomains": False,
    }
    resp = requests.post(
        f"{NPM_URL}/api/nginx/proxy-hosts",
        headers=headers,
        json=payload,
        timeout=15,
    )
    if resp.status_code >= 400:
        print(f"  [X] FAILED to create {domain}: {resp.status_code} {resp.text}")
        return
    print(f"  [+] created proxy host: {domain} -> {scheme}://{host}:{port}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true",
                         help="Preview actions without calling the API's write endpoints")
    args = parser.parse_args()

    if args.dry_run:
        print("=== DRY RUN — no changes will be made ===\n")
        token = None
    else:
        print(f"Authenticating to {NPM_URL} ...")
        token = get_token()
        print("Authenticated.\n")

    cert_id = upload_wildcard_certificate(token, args.dry_run)
    print()

    for domain, scheme, host, port in HOSTS:
        create_proxy_host(token, domain, scheme, host, port, cert_id, args.dry_run)

    print("\nDone. Review results in the NPM UI at", f"{NPM_URL}")


if __name__ == "__main__":
    main()
