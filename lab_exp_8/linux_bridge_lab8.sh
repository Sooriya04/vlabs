#!/usr/bin/env bash
# ==============================================================================
# Script Name: linux_bridge_lab8.sh
# Lab Title: Virtualization Lab 8 - Network Virtualization (Linux Bridge)
# Description: Shell script to automate and execute Linux Bridge configuration,
#              kernel module loading, netplan/cli configuration, and verification.
# ==============================================================================

set -e

echo "=== [Step 1] Checking Current Network Configuration ==="
ip addr show
echo ""

echo "=== [Step 2] Installing Bridge Utilities and Loading Kernel Modules ==="
sudo apt-get update -qq
sudo apt-get install -y bridge-utils

# Load required kernel modules for bridge functionality and firewall filtering
sudo modprobe bridge
sudo modprobe br_netfilter

# Verify loaded modules
lsmod | grep -E 'bridge|br_netfilter'
echo ""

echo "=== [Step 3] Manual Linux Bridge Configuration (CLI Method) ==="
# Creating bridge 'br0'
if ! ip link show br0 &>/dev/null; then
    sudo brctl addbr br0
    echo "Created bridge br0"
else
    echo "Bridge br0 already exists"
fi

# Bring bridge interface up
sudo ip link set dev br0 up

# Assign IP address to bridge br0 (Adjust IP according to environment)
sudo ip addr add 192.168.50.1/24 dev br0 2>/dev/null || echo "IP already assigned to br0"

echo ""
echo "=== [Step 4] Verifying Bridge Configuration and Interfaces ==="
brctl show
ip link show type bridge
ip addr show br0
echo ""

echo "=== [Step 5] Checking Routing Table ==="
ip route show
echo ""

echo "=== Linux Bridge Setup Completed Successfully ==="
