#!/bin/sh
# gitleaks pre-commit hook: scans only what is staged. Bypass once with: git commit --no-verify
command -v gitleaks >/dev/null 2>&1 || { echo "gitleaks not installed, skipping secret scan"; exit 0; }
exec gitleaks git --pre-commit --staged --redact --no-banner -v .
