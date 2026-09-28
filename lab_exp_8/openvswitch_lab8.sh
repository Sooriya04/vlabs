#!/usr/bin/env bash
# ==============================================================================
# Script Name: openvswitch_lab8.sh
# Lab Title: Virtualization Lab 8 - Network Virtualization (OpenVSwitch / OVS)
# Description: Shell script to automate OVS bridge creation, network namespaces
#              (VRF1 & VRF2), virtual ethernet (veth) setup, IP configuration,
#              ping test, STP enabling, and MAC address verification.
# ==============================================================================

set -e

# Ensure root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root (use 'sudo bash openvswitch_lab8.sh')"
  exit 1
fi

# Handle cleanup parameter
if [ "$1" = "--cleanup" ] || [ "$1" = "clean" ]; then
    echo "=== Cleaning up OpenVSwitch & Namespaces ==="
    ovs-vsctl del-br ovs-br0 2>/dev/null || true
    ip netns del VRF1 2>/dev/null || true
    ip netns del VRF2 2>/dev/null || true
    ip link del veth1 2>/dev/null || true
    ip link del veth2 2>/dev/null || true
    ip link del veth3 2>/dev/null || true
    ip link del veth4 2>/dev/null || true
    echo "Cleaned up VRF1, VRF2, veth pairs, and ovs-br0."
    exit 0
fi

echo "=== [Step 1] Installing and Verifying OpenVSwitch Service ==="
if ! command -v ovs-vsctl &>/dev/null; then
    apt-get update -qq
    apt-get install -y openvswitch-switch
fi

systemctl start openvswitch-switch
systemctl enable openvswitch-switch
systemctl status openvswitch-switch --no-pager -n 10 || true
echo ""

echo "=== [Step 2] Cleaning Previous Lab Interfaces and Namespaces ==="
ovs-vsctl del-br ovs-br0 2>/dev/null || true
ip netns del VRF1 2>/dev/null || true
ip netns del VRF2 2>/dev/null || true
ip link del veth1 2>/dev/null || true
ip link del veth2 2>/dev/null || true
ip link del veth3 2>/dev/null || true
ip link del veth4 2>/dev/null || true

echo "=== [Step 3] Creating Network Namespaces (VRF1 & VRF2) ==="
ip netns add VRF1
ip netns add VRF2
echo "Active Namespaces:"
ip netns list
echo ""

echo "=== [Step 4] Creating Virtual Ethernet (veth) Pairs ==="
# veth1 <--> veth2
# veth3 <--> veth4
ip link add veth1 type veth peer name veth2
ip link add veth3 type veth peer name veth4
echo "Created veth pairs: (veth1-veth2) and (veth3-veth4)"
echo ""

echo "=== [Step 5] Assigning VETH Ports to Namespaces ==="
ip link set veth1 netns VRF1
ip link set veth3 netns VRF2
echo "Assigned veth1 -> VRF1, veth3 -> VRF2"
echo ""

echo "=== [Step 6] Configuring OpenVSwitch Bridge and Adding Ports ==="
# Add OVS bridge
ovs-vsctl add-br ovs-br0

# Attach host veth interfaces to OVS bridge
ovs-vsctl add-port ovs-br0 veth2
ovs-vsctl add-port ovs-br0 veth4

echo "OVS Configuration Summary:"
ovs-vsctl show
echo ""

echo "=== [Step 7] Bringing Interfaces UP and Configuring IP Addresses ==="
# Host interfaces UP
ip link set dev veth2 up
ip link set dev veth4 up
ip link set dev ovs-br0 up

# Configure VRF1 namespace
ip netns exec VRF1 ip link set dev lo up
ip netns exec VRF1 ip link set dev veth1 up
ip netns exec VRF1 ip addr add 192.168.10.1/24 dev veth1

# Configure VRF2 namespace
ip netns exec VRF2 ip link set dev lo up
ip netns exec VRF2 ip link set dev veth3 up
ip netns exec VRF2 ip addr add 192.168.10.2/24 dev veth3

echo "IP Configuration:"
echo "VRF1 (veth1):"
ip netns exec VRF1 ip addr show veth1
echo "VRF2 (veth3):"
ip netns exec VRF2 ip addr show veth3
echo ""

echo "=== [Step 8] Ping Verification Between Namespaces via OVS ==="
echo "Pinging 192.168.10.2 (VRF2) from VRF1..."
ip netns exec VRF1 ping -c 4 192.168.10.2
echo ""

echo "=== [Step 9] Enabling Spanning Tree Protocol (STP) on OVS Bridge ==="
ovs-vsctl set bridge ovs-br0 stp_enable=true
echo "STP enabled on ovs-br0 (Status: $(ovs-vsctl get bridge ovs-br0 stp_enable))."
echo ""

echo "=== [Step 10] Verifying MAC Address Table (FDB) ==="
echo "OVS MAC Address Table (FDB):"
ovs-appctl fdb/show ovs-br0

echo ""
echo "Actual MAC address of veth1 in VRF1:"
ip netns exec VRF1 ip link show veth1 | grep link/ether || true
echo "Actual MAC address of veth3 in VRF2:"
ip netns exec VRF2 ip link show veth3 | grep link/ether || true
echo ""

echo "=== OpenVSwitch Lab 8 Completed Successfully ==="
echo "Note: To tear down this OVS setup later, run: sudo $0 --cleanup"
