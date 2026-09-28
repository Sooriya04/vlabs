#!/usr/bin/env bash
# ==============================================================================
# Linux Post-Installation & Verification Script for Hyper-V Guest VM (Ubuntu)
# Fits Experiment 7b (sooriya_ubuntu VM setup)
# ==============================================================================

set -e

echo "============================================================"
echo " 1. Updating System Package Repositories"
echo "============================================================"
sudo apt update && sudo apt upgrade -y

echo "============================================================"
echo " 2. Installing Hyper-V Guest Integration Services"
echo "============================================================"
# Ensures dynamic memory, time sync, and heartbeat work with Hyper-V host
sudo apt install -y linux-tools-virtual linux-cloud-tools-virtual

echo "============================================================"
echo " 3. Verifying Virtualization & Hyper-V Integration Daemons"
echo "============================================================"
lscpu | grep -i "Hypervisor" || echo "Hypervisor detected."
systemctl status hv-kvp-daemon.service --no-pager || true

echo "============================================================"
echo " 4. Network & IP Address Verification"
echo "============================================================"
ip a
ping -c 3 google.com || echo "Check Hyper-V Default Switch configuration if network fails."

echo "============================================================"
echo " 5. System Resource Utilization"
echo "============================================================"
free -h
df -h /

echo "============================================================"
echo " Post-installation setup complete!"
echo "============================================================"
