#!/bin/bash
# ==============================================================================
# Script Name: exp2b_network_ping.sh
# Lab Experiment 2b: VM-to-VM Ping and VM-to-Native Ping Connectivity Test
# Description: Configures Linux firewall rules and executes connectivity pings
#              between Linux VM, Windows Host, and target VMs.
# ==============================================================================

TARGET_HOST_IP="${1:-192.168.56.1}"
TARGET_VM_IP="${2:-192.168.56.102}"

echo "=================================================="
echo "  EXPERIMENT 2b: Network Connectivity Ping Test  "
echo "=================================================="
echo ""

# 1. Display Local Network Interfaces & Assigned IP
echo "[1] Checking Local IP Address and Network Interfaces:"
if command -v ip &> /dev/null; then
    ip addr show
elif command -v ifconfig &> /dev/null; then
    ifconfig
fi
echo ""

# 2. Linux Firewall Configuration
echo "[2] Disabling Uncomplicated Firewall (UFW) and Flushing Iptables..."
if command -v ufw &> /dev/null; then
    sudo ufw disable
    sudo ufw status
else
    echo "ufw not installed or skipped."
fi

if command -v iptables &> /dev/null; then
    sudo iptables -F
    echo "Iptables rules flushed successfully."
fi
echo ""

# 3. Local Loopback Ping Test
echo "[3] Executing Local Loopback Ping (127.0.0.1):"
ping -c 4 127.0.0.1
echo ""

# 4. VM-to-Native (Host) Ping Test
echo "[4] Executing VM-to-Native (Host) Ping to $TARGET_HOST_IP:"
ping -c 4 "$TARGET_HOST_IP"
if [ $? -eq 0 ]; then
    echo "SUCCESS: Host ($TARGET_HOST_IP) is ALIVE and reachable!"
else
    echo "FAILED: Cannot reach Host ($TARGET_HOST_IP). Check Windows Firewall ICMP rules or VirtualBox network adapter (Host-Only/Bridged)."
fi
echo ""

# 5. VM-to-VM Ping Test
echo "[5] Executing VM-to-VM Ping to $TARGET_VM_IP:"
ping -c 4 "$TARGET_VM_IP"
if [ $? -eq 0 ]; then
    echo "SUCCESS: Target VM ($TARGET_VM_IP) is ALIVE and reachable!"
else
    echo "FAILED: Cannot reach Target VM ($TARGET_VM_IP). Ensure both VMs are on the same network adapter (e.g. Host-Only vboxnet0)."
fi
echo ""

echo "Experiment 2b network test completed."
