WSL Ansible starter

This repository provides a small Ansible scaffold to configure WSL developer environments.

What it does
- Installs zsh, git, curl, wget and dependencies
- Clones Oh My Zsh into the user's home and deploys a template .zshrc
- Helper script to create an SSH key and add it as a deploy key using GitHub CLI (see scripts/github_secrets.sh)

Usage
1. From WSL, install Ansible (e.g., python3 -m pip install --user ansible) or use your distro package manager.
2. Run the playbook locally:

   ansible-playbook -i ansible/hosts ansible/playbook.yml

Notes & next steps
- The playbook assumes an apt-based distro (Debian/Ubuntu). Adapt the tasks for other distros.
- I saw your note about "astral's uv" — I wasn't sure what package/project you meant. Please confirm the exact name or link and I will add installation steps.
- I can also add GitHub Actions, more plugins/themes, or install "uv" if you clarify the source.
 - I added installation for Astral's `uv` using their standalone installer. The role will run the installer if `uv` is not present in `~/.local/bin` for the target user.
 - To keep one SSH private key across systems: store your private key encrypted (Ansible Vault, HashiCorp Vault, cloud secrets), add the `id_ed25519` and `id_ed25519.pub` (encrypted) to `roles/wsl-setup/files/` and decrypt at deployment time. The role will deploy those files if present; otherwise it will generate a new keypair.
 - Codespaces / Secrets: If you set an environment variable or Codespace secret named `SSH_KEY_GITHUB` containing your OpenSSH private key (PEM) the role will deploy it to `~/.ssh/id_ed25519`, generate the public key, add it to ssh-agent, and configure Git to use SSH commit signing. You can also run `scripts/use_repo_ssh_key.sh` locally to do the same thing.

Security note: storing private keys in repository secrets is sensitive. Prefer encrypted storage (Ansible Vault, cloud secret manager) and rotate keys periodically.

Bootstrapping Ansible
---------------------

If you don't have Ansible on a fresh system, run the provided bootstrap script which detects common distros and installs Ansible (macOS/linux). Example:

```bash
./scripts/bootstrap_ansible.sh
```

Notes:
- The script supports `apt`, `dnf`/`yum`, `pacman`, and Homebrew on macOS.
- On Debian/Ubuntu the script will attempt to install Ansible via `pipx` if available or `pip --user` as a fallback — ensure `~/.local/bin` is on your PATH.
- Windows users should run the playbook inside WSL or a Linux environment.

