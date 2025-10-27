#!/usr/bin/env bash
# Bootstrap Ansible on a fresh machine (Linux / macOS). Meant for interactive use.
# Supports Debian/Ubuntu (apt), Fedora/RHEL (dnf/yum), Arch (pacman), and macOS (brew).
# Windows is outside scope; use WSL for Linux-like environments.
set -euo pipefail

echo "== Ansible bootstrap script =="

# helper
run_cmd(){
  echo "> $*"
  eval "$@"
}

if command -v ansible >/dev/null 2>&1; then
  echo "Ansible already installed: $(ansible --version | head -n1)"
  exit 0
fi

# Detect OS
if [ "$(uname -s)" = "Darwin" ]; then
  PLATFORM=macos
else
  PLATFORM=linux
fi

if [ "$PLATFORM" = "macos" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Add brew to PATH if needed and re-run the script."
    exit 1
  fi
  run_cmd brew update
  run_cmd brew install ansible
  echo "Installed Ansible via Homebrew"
  exit 0
fi

# For Linux, detect package manager
if command -v apt-get >/dev/null 2>&1; then
  PKG=apt
elif command -v dnf >/dev/null 2>&1; then
  PKG=dnf
elif command -v yum >/dev/null 2>&1; then
  PKG=yum
elif command -v pacman >/dev/null 2>&1; then
  PKG=pacman
else
  echo "No supported package manager found (apt, dnf, yum, pacman). Install Ansible manually."
  exit 2
fi

case "$PKG" in
  apt)
    echo "Using apt"
    run_cmd sudo apt-get update
    run_cmd sudo apt-get install -y python3 python3-venv python3-pip sshpass software-properties-common
    # Use pipx or pip to install a recent ansible
    if command -v pipx >/dev/null 2>&1; then
      run_cmd pipx install ansible
    else
      run_cmd python3 -m pip install --user ansible
      echo "Ensure $HOME/.local/bin is on your PATH to use ansible-playbook"
    fi
    ;;
  dnf)
    echo "Using dnf"
    run_cmd sudo dnf install -y python3 python3-virtualenv python3-pip openssh-clients
    run_cmd sudo dnf install -y ansible
    ;;
  yum)
    echo "Using yum"
    run_cmd sudo yum install -y python3 python3-virtualenv python3-pip openssh-clients
    run_cmd sudo yum install -y ansible
    ;;
  pacman)
    echo "Using pacman"
    run_cmd sudo pacman -Sy --noconfirm python python-pip openssh
    run_cmd sudo pacman -Sy --noconfirm ansible
    ;;
esac

if command -v ansible >/dev/null 2>&1; then
  echo "Ansible installed: $(ansible --version | head -n1)"
else
  echo "Ansible install attempted but ansible not found. Try installing pipx and pipx install ansible or check package manager logs."
  exit 3
fi
