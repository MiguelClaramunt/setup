#!/usr/bin/env bash
# Helper: read SSH_KEY_GITHUB env var and write key locally (for manual use outside Ansible)
set -euo pipefail

if [ -z "${SSH_KEY_GITHUB:-}" ]; then
  echo "Please set SSH_KEY_GITHUB environment variable containing your private key PEM/text."
  exit 2
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

echo "$SSH_KEY_GITHUB" > "$HOME/.ssh/id_ed25519"
chmod 600 "$HOME/.ssh/id_ed25519"

if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
  ssh-keygen -y -f "$HOME/.ssh/id_ed25519" > "$HOME/.ssh/id_ed25519.pub"
fi

cat "$HOME/.ssh/id_ed25519.pub"

eval "$(ssh-agent -s)" >/dev/null || true
ssh-add "$HOME/.ssh/id_ed25519" || true

echo "Installed SSH key and added to ssh-agent. To configure Git commit signing (ssh), run:" \
     "\n  git config --global gpg.format ssh\n  git config --global gpg.ssh.program ssh-keygen\n  git config --global user.signingKey \"key::$(cat $HOME/.ssh/id_ed25519.pub)\""
