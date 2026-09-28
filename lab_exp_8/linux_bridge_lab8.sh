#!/usr/bin/env bash
# ==============================================================================
# Script Name: linux_bridge_lab8.sh
# Lab Title: Virtualization Lab 8 - Network Virtualization (Linux Bridge)
# Description: Shell script to automate and execute Linux Bridge configuration,
#              kernel module loading, netplan/cli configuration, and verification.
# ==============================================================================

set -e

# Handle cleanup option
if [ "$1" = "--cleanup" ] || [ "$1" = "clean" ]; then
    echo "=== Cleaning up Linux Bridge (br0) ==="
    sudo ip link set dev br0 down 2>/dev/null || true
    sudo ip link del dev br0 2>/dev/null || sudo brctl delbr br0 2>/dev/null || true
    echo "Bridge br0 removed successfully."
    exit 0
fi

PHYS_IFACE="${1:-}"

echo "=== [Step 1] Checking Current Network Configuration ==="
ip -br addr show 2>/dev/null || ip addr show
echo ""

echo "=== [Step 2] Installing Bridge Utilities and Loading Kernel Modules ==="
if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y bridge-utils 2>/dev/null || true
fi

# Load required kernel modules for bridge functionality and firewall filtering
sudo modprobe bridge 2>/dev/null || true
sudo modprobe br_netfilter 2>/dev/null || true

# Verify loaded modules (safely without aborting under set -e)
echo "[*] Kernel Bridge Modules:"
lsmod | grep -E 'bridge|br_netfilter' || echo "Bridge modules loaded or built into kernel."
echo ""

echo "=== [Step 3] Manual Linux Bridge Configuration ==="
# Creating bridge 'br0' using ip (modern) or brctl (legacy)
if ! ip link show br0 &>/dev/null; then
    if ! sudo ip link add name br0 type bridge 2>/dev/null; then
        sudo brctl addbr br0
    fi
    echo "Created bridge br0"
else
    echo "Bridge br0 already exists"
fi

# Attach interface to br0 if provided (Lab 8 Step 4)
if [ -n "$PHYS_IFACE" ]; then
    echo "[*] Attaching interface $PHYS_IFACE to br0..."
    sudo ip link set "$PHYS_IFACE" master br0 2>/dev/null || sudo brctl addif br0 "$PHYS_IFACE"
fi

# Bring bridge interface up
sudo ip link set dev br0 up

# Assign IP address to bridge br0 (Adjust IP according to environment)
sudo ip addr add 192.168.50.1/24 dev br0 2>/dev/null || echo "IP already assigned to br0"

echo ""
echo "=== [Step 4] Verifying Bridge Configuration and Interfaces ==="
if command -v brctl &>/dev/null; then
    brctl show
fi
ip link show type bridge
ip addr show br0
echo ""

echo "=== [Step 5] Checking Routing Table ==="
ip route show
echo ""

echo "=== Linux Bridge Setup Completed Successfully ==="
echo "Note: To tear down this bridge later, run: $0 --cleanup"
