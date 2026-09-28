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
echo " 2. Installing Hyper-V Guest Integration Services & SSH"
echo "============================================================"
# Ensures dynamic memory, time sync, heartbeat, and remote access work with Hyper-V host
sudo apt install -y linux-tools-virtual linux-cloud-tools-virtual openssh-server || \
sudo apt install -y "linux-cloud-tools-$(uname -r)" "linux-tools-$(uname -r)" openssh-server 2>/dev/null || true

sudo systemctl enable --now ssh 2>/dev/null || true

echo "============================================================"
echo " 3. Verifying Virtualization & Hyper-V Integration Daemons"
echo "============================================================"
# Correct hypervisor detection logic
if lscpu | grep -i "Hypervisor"; then
    echo "[*] Hypervisor detected successfully."
else
    echo "[!] Notice: 'Hypervisor' tag not found in lscpu (may indicate running on bare metal or nested virt disabled)."
fi

echo ""
echo "[*] Checking Hyper-V Kernel Modules (VMBus, Storage, Network, Utils):"
lsmod | grep hv_ || echo "Notice: Hyper-V kernel modules not detected."

echo ""
echo "[*] Checking Hyper-V Guest Daemons Status:"
for svc in hv-kvp-daemon.service hv-vss-daemon.service hv-fcopy-daemon.service; do
    echo "  - $svc: $(systemctl is-active "$svc" 2>/dev/null || echo 'not active/installed')"
done

echo "============================================================"
echo " 4. Network & IP Address Verification"
echo "============================================================"
echo "[*] Assigned IPv4 Addresses:"
ip -br -4 addr show || ip a

echo ""
echo "[*] Testing Internet Connectivity:"
ping -c 3 google.com || echo "Check Hyper-V Default Switch / Virtual Switch configuration if network fails."

echo "============================================================"
echo " 5. System Resource Utilization"
echo "============================================================"
echo "[*] Memory Usage:"
free -h
echo ""
echo "[*] Disk Usage:"
df -h /

echo "============================================================"
echo " Post-installation setup complete!"
echo "============================================================"
