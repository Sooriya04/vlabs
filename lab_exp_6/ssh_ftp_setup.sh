#!/bin/bash
# =========================================================
# Shell Script: SSH & FTP Automation Setup
# Grounded in VT LAB 6TH EXCERCISE
# =========================================================

echo "=== Updating System Package Index ==="
sudo apt update

echo "=== Installing OpenSSH, VSFTPD, and FTP Client ==="
sudo apt install openssh-server vsftpd ftp -y

echo "=== Enabling and Starting Services ==="
sudo systemctl enable --now ssh
sudo systemctl enable --now vsftpd

echo "=== Configuring UFW Firewall Ports ==="
sudo ufw allow 22/tcp
sudo ufw allow 21/tcp
sudo ufw allow 20/tcp
sudo ufw reload

echo "=== Adding Current User to vboxsf Group (for VirtualBox Shared Folder access) ==="
sudo usermod -aG vboxsf $USER

echo "=== Verification & Network Interfaces ==="
sudo ufw status
ip a
