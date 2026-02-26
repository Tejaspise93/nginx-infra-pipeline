#!/bin/bash
# ============================================================
# Jenkins Server Setup Script
# OS      : Amazon Linux 2023
# Installs: Git, Ansible, Terraform
# Usage   : bash jenkins_server_setup.sh
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

# Install ansible for root user
pip3 install ansible --user

# Amazon Linux uses .bash_profile for login shells (not .bashrc)
if ! grep -q '.local/bin' ~/.bash_profile; then
    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bash_profile
fi
export PATH=$HOME/.local/bin:$PATH

ansible --version | head -1

# Install ansible for jenkins user
echo "  → Installing Ansible for jenkins user..."
if id "jenkins" &>/dev/null; then
    sudo su - jenkins -c "pip3 install ansible --user"
    sudo su - jenkins -c "grep -q '.local/bin' ~/.bash_profile || echo 'export PATH=\$HOME/.local/bin:\$PATH' >> ~/.bash_profile"
    sudo su - jenkins -c "source ~/.bash_profile && ansible --version | head -1"
else
    echo "  ⚠ Jenkins user not found yet, skipping. Re-run after Jenkins is installed."
fi

# ------------------------------------------------------------
# 4. Install Terraform
# ------------------------------------------------------------
echo ""
echo "[4/4] Installing Terraform..."
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform

terraform -version | head -1

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
echo -n "Ansible (jenkins user) : " && sudo su - jenkins -c "source ~/.bash_profile && ansible --version | head -1" 2>/dev/null || echo "jenkins user not found"
echo "============================================"
echo "  Setup Complete! ✓"
echo "============================================"
echo ""
echo "Next Steps:"
echo "  1. Generate SSH key for jenkins user:"
echo "     sudo su - jenkins"
echo "     ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''"
echo "     cat ~/.ssh/id_rsa.pub   ← save this for Terraform"
echo ""
echo "  2. Open Jenkins UI at: http://<this-server-ip>:8080"
echo "  3. Get admin password:"
echo "     sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo "============================================"