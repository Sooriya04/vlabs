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

# 0. Verify Ping Utility Availability
if ! command -v ping &> /dev/null; then
    echo "[!] 'ping' command not found. Installing iputils-ping..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y iputils-ping
    fi
fi

# 1. Display Local Network Interfaces & Assigned IP
echo "[1] Checking Local IP Address and Network Interfaces:"
if command -v ip &> /dev/null; then
    ip addr show
elif command -v ifconfig &> /dev/null; then
    ifconfig
fi
echo ""

echo "[1b] Checking Kernel Routing Table:"
if command -v ip &> /dev/null; then
    ip route show
elif command -v route &> /dev/null; then
    route -n
fi
echo ""

# 2. Linux Firewall Configuration
echo "[2] Disabling Uncomplicated Firewall (UFW) and Resetting Iptables Policies..."
if command -v ufw &> /dev/null; then
    sudo ufw disable
    sudo ufw status
else
    echo "ufw not installed or skipped."
fi

if command -v iptables &> /dev/null; then
    # Ensure default policies are ACCEPT before flushing to avoid connection drops
    sudo iptables -P INPUT ACCEPT 2>/dev/null || true
    sudo iptables -P FORWARD ACCEPT 2>/dev/null || true
    sudo iptables -P OUTPUT ACCEPT 2>/dev/null || true
    sudo iptables -F 2>/dev/null || true
    echo "Iptables default policies set to ACCEPT and filter rules flushed successfully."
fi
echo ""

# 3. Local Loopback Ping Test
echo "[3] Executing Local Loopback Ping (127.0.0.1):"
ping -c 4 127.0.0.1
echo ""

# 4. VM-to-Native (Host) Ping Test
echo "[4] Executing VM-to-Native (Host) Ping to $TARGET_HOST_IP:"
if ping -c 4 "$TARGET_HOST_IP"; then
    echo "SUCCESS: Host ($TARGET_HOST_IP) is ALIVE and reachable!"
else
    echo "FAILED: Cannot reach Host ($TARGET_HOST_IP)."
    echo "Troubleshooting steps:"
    echo "  1. Check Windows Firewall Inbound ICMPv4 rule (wf.msc -> File and Printer Sharing Echo Request)."
    echo "  2. Ensure VM adapter is configured as Host-Only (e.g. vboxnet0) on subnet 192.168.56.x."
fi
echo ""

# 5. VM-to-VM Ping Test
echo "[5] Executing VM-to-VM Ping to $TARGET_VM_IP:"
if ping -c 4 "$TARGET_VM_IP"; then
    echo "SUCCESS: Target VM ($TARGET_VM_IP) is ALIVE and reachable!"
else
    echo "FAILED: Cannot reach Target VM ($TARGET_VM_IP)."
    echo "Troubleshooting steps:"
    echo "  1. Verify Target VM is running and has IP assigned on same subnet (e.g. 192.168.56.x)."
    echo "  2. Run: sudo dhclient -r && sudo dhclient to renew DHCP lease."
    echo "  3. Scan subnet with nmap: sudo nmap -sn 192.168.56.0/24"
fi
echo ""

echo "Experiment 2b network test completed."
