#!/bin/bash
# ============================================================
# Jenkins Server Setup Script
# OS      : Amazon Linux 2023
# Installs: Git, Ansible, Terraform
# Also    : Generates SSH key for jenkins user
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
echo "[1/5] Updating system..."
sudo dnf update -y

# ------------------------------------------------------------
# 2. Install Git
# ------------------------------------------------------------
echo ""
echo "[2/5] Installing Git..."
sudo dnf install -y git
git --version

# ------------------------------------------------------------
# 3. Install Ansible
# ------------------------------------------------------------
echo ""
echo "[3/5] Installing Ansible..."
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
echo "[4/5] Installing Terraform..."
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform

terraform -version | head -1

# ------------------------------------------------------------
# 5. Generate SSH Key for Jenkins User
# ------------------------------------------------------------
echo ""
echo "[5/5] Generating SSH key for jenkins user..."

if id "jenkins" &>/dev/null; then
    # Create .ssh directory if it doesn't exist
    sudo mkdir -p /var/lib/jenkins/.ssh
    sudo chown jenkins:jenkins /var/lib/jenkins/.ssh
    sudo chmod 700 /var/lib/jenkins/.ssh

    # Generate key only if it doesn't already exist
    if [ ! -f /var/lib/jenkins/.ssh/id_rsa ]; then
        sudo su - jenkins -c "ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''"
        echo "  ✓ SSH key generated"
    else
        echo "  ⚠ SSH key already exists, skipping generation"
    fi

    echo ""
    echo "  → Jenkins user public key (save this for Terraform):"
    echo "  -------------------------------------------------------"
    sudo cat /var/lib/jenkins/.ssh/id_rsa.pub
    echo "  -------------------------------------------------------"
else
    echo "  ⚠ Jenkins user not found. Re-run this script after Jenkins is installed."
fi

# ------------------------------------------------------------
# Final Verification
# ------------------------------------------------------------
echo ""
echo "============================================"
echo "  Verification Summary"
echo "============================================"
echo -n "Git           : " && git --version
echo -n "Ansible       : " && ansible --version | head -1
echo -n "Terraform     : " && terraform -version | head -1
echo -n "Java          : " && java -version 2>&1 | head -1
echo -n "Ansible (jenkins) : " && sudo su - jenkins -c "source ~/.bash_profile && ansible --version | head -1" 2>/dev/null || echo "jenkins user not found"
echo -n "SSH Key       : " && sudo test -f /var/lib/jenkins/.ssh/id_rsa && echo "exists ✓" || echo "not found ✗"
echo "============================================"
echo "  Setup Complete! ✓"
echo "============================================"
echo ""
echo "Next Steps:"
echo "  1. Open Jenkins UI at: http://<this-server-ip>:8080"
echo "  2. Get admin password:"
echo "     sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo "  3. Public key is at: /var/lib/jenkins/.ssh/id_rsa.pub"
echo "     This will be used by Terraform to create AWS key pair"
echo "============================================"