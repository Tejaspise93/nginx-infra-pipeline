#!/bin/bash
# ============================================================
# Jenkins Server Setup Script
# OS      : Amazon Linux 2023
# Installs: Git, Ansible, Terraform
# Usage   : bash setup-jenkins-server.sh
# ============================================================

set -e  # Exit immediately if any command fails

echo "============================================"
echo "  Starting Jenkins Server Setup"
echo "============================================"

# ------------------------------------------------------------
# 1. System Update
# ------------------------------------------------------------
echo ""
echo "[1/4] Updating system..."
sudo dnf update -y

# ------------------------------------------------------------
# 2. Install Git
# ------------------------------------------------------------
echo ""
echo "[2/4] Installing Git..."
sudo dnf install -y git
git --version

# ------------------------------------------------------------
# 3. Install Ansible
# ------------------------------------------------------------
echo ""
echo "[3/4] Installing Ansible..."
sudo dnf install -y python3-pip

pip3 install ansible --user

# Add to PATH for current user
if ! grep -q '.local/bin' ~/.bashrc; then
    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
fi
export PATH=$HOME/.local/bin:$PATH

ansible --version

# Install ansible for jenkins user as well (needed for pipeline)
echo "  → Installing Ansible for jenkins user..."
sudo su - jenkins -c "pip3 install ansible --user" 2>/dev/null || echo "  ⚠ Jenkins user not found yet, skipping. Re-run after Jenkins is installed."
sudo su - jenkins -c "echo 'export PATH=\$HOME/.local/bin:\$PATH' >> ~/.bashrc" 2>/dev/null || true

# ------------------------------------------------------------
# 4. Install Terraform
# ------------------------------------------------------------
echo ""
echo "[4/4] Installing Terraform..."
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform

terraform -version

# ------------------------------------------------------------
# Final Verification
# ------------------------------------------------------------
echo ""
echo "============================================"
echo "  Verification Summary"
echo "============================================"
echo -n "Git       : " && git --version
echo -n "Ansible   : " && ansible --version | head -1
echo -n "Terraform : " && terraform -version | head -1
echo -n "Java      : " && java -version 2>&1 | head -1
echo "============================================"
echo "  Setup Complete! ✓"
echo "============================================"