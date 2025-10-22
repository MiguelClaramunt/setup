#!/usr/bin/env bash
# Helper to create SSH key and set GitHub repo secrets using gh CLI
set -euo pipefail

REPO="${1:-}" # optional: owner/repo

if ! command -v gh >/dev/null 2>&1; then
  echo "Please install GitHub CLI (gh) first: https://cli.github.com/"
  exit 2
fi

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo "Generating SSH key at ~/.ssh/id_ed25519"
  ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$HOME/.ssh/id_ed25519" -N ""
fi

eval "$(ssh-agent -s)" >/dev/null
ssh-add "$HOME/.ssh/id_ed25519" || true

echo "Public key (~/.ssh/id_ed25519.pub):"
cat "$HOME/.ssh/id_ed25519.pub"

echo
if [ -n "$REPO" ]; then
  echo "Uploading public key as a deploy key to $REPO (requires gh auth)
"
  gh auth status || { echo "Run 'gh auth login' to authenticate."; exit 1; }
  gh repo deploy-key add "$HOME/.ssh/id_ed25519.pub" --repo "$REPO" --title "wsl-deploy-key-$(hostname)" --read-only || echo "deploy key might already exist"
  echo "Done."
else
  echo "No repo supplied. To upload the key to a repo:"
  echo "  ./scripts/github_secrets.sh owner/repo"
fi

# Example: set a repo secret
# gh secret set MY_SECRET --body "value" --repo owner/repo
 
# Notes:
# - Storing a private SSH key in GitHub Secrets is possible but not recommended for general use because secrets can be exposed to workflows with write permissions. Prefer using a dedicated deploy key (read-only) attached to each repo.
# - If you want the exact same private key on multiple systems, consider storing the private key encrypted in a secure vault (Ansible Vault, HashiCorp Vault, AWS Secrets Manager), and deploy it to hosts during provisioning. The Ansible role supports placing an `id_ed25519` and `id_ed25519.pub` file into `roles/wsl-setup/files/` (these should be encrypted or excluded from VCS).

