# Network Virtualization Guidelines - Lab 8
## Linux Bridge & OpenVSwitch (OVS)

---

## 📋 Overview & Objectives

**Aim:** To perform network virtualization in Linux using **Linux Bridge** and **OpenVSwitch (OVS)**.

- **Linux Bridge:** A software-based Layer-2 network device built into the Linux kernel that behaves like a physical ethernet switch. It connects multiple virtual or physical network interfaces into a single logical network segment.
- **OpenVSwitch (OVS):** An open-source, production-grade, multi-layer software switch designed for virtualized environments and Software-Defined Networking (SDN). Supports advanced management features like OpenFlow, NetFlow, sFlow, LACP, and STP.

---

## 🛠️ Part 1: Linux Bridge Configuration

### Step-by-Step Procedure & Commands

#### Step 1: Check Current Network Configuration
Examine existing network interfaces, IP addresses, and bridge devices:
```bash
ip addr show
# OR
ifconfig
```

#### Step 2: Install Bridge Utilities & Load Kernel Modules
Install `bridge-utils` package and load required kernel modules:
```bash
# Update package index and install bridge utilities
sudo apt update && sudo apt install -y bridge-utils

# Load bridge kernel module
sudo modprobe bridge

# Load br_netfilter module (enables firewall/iptables rules on bridge traffic)
sudo modprobe br_netfilter

# Verify loaded modules
lsmod | grep -E 'bridge|br_netfilter'
```

#### Step 3: Configure Linux Bridge via Netplan
Edit your Netplan configuration file (typically in `/etc/netplan/`):
```bash
sudo nano /etc/netplan/01-bridge-config.yaml
```

**Netplan YAML Example Configuration:**
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
  bridges:
    br0:
      interfaces: [eth0]
      dhcp4: yes
      parameters:
        stp: false
        forward-delay: 0
```

Apply Netplan changes:
```bash
sudo netplan apply
```

#### Step 4: Alternative Direct Command-Line Configuration (CLI)
If Netplan is not used, configure the bridge directly using `brctl` or `ip`:
```bash
# Create bridge 'br0'
sudo brctl addbr br0
# Alternatively: sudo ip link add name br0 type bridge

# Attach a physical or virtual interface (e.g., eth0) to br0
sudo brctl addif br0 eth0
# Alternatively: sudo ip link set eth0 master br0

# Bring up the bridge interface
sudo ip link set dev br0 up

# Assign an IP address to the bridge interface
sudo ip addr add 192.168.1.100/24 dev br0
```

#### Step 5: Verification & Routing Inspection
Verify bridge status, attached interfaces, and routing table:
```bash
# Show active bridges and attached interfaces
brctl show
# OR
ip link show type bridge

# Inspect bridge interface IP address
ip addr show br0

# Verify routing table
ip route show
# OR
route -n
```

---

## 🌐 Part 2: OpenVSwitch (OVS) & Network Namespaces

### Topology Diagram
```
  [ VRF1 Namespace ]               [ VRF2 Namespace ]
     (veth1: 192.168.10.1/24)         (veth3: 192.168.10.2/24)
            |                                |
            | (veth pair)                    | (veth pair)
            v                                v
     (veth2 interface)                (veth4 interface)
          \                                /
           \                              /
            +----------------------------+
            |    OpenVSwitch Bridge      |
            |         (ovs-br0)          |
            +----------------------------+
```

---

### Step-by-Step Procedure & Commands

#### Step 1: Gain Root Privileges
Switch to root user to perform administrative network operations:
```bash
sudo -i
# OR run all subsequent commands with 'sudo'
```

#### Step 2: Create Virtual Network Namespaces (VRF1 & VRF2)
Create two isolated network namespaces to simulate distinct virtual environments:
```bash
# Create namespaces
ip netns add VRF1
ip netns add VRF2

# Verify creation
ip netns list
```

#### Step 3: Create Virtual Ethernet Pairs (VETH Ports)
Create two pairs of connected virtual ethernet interfaces:
```bash
# Create pair 1: veth1 <--> veth2
ip link add veth1 type veth peer name veth2

# Create pair 2: veth3 <--> veth4
ip link add veth3 type veth peer name veth4
```

#### Step 4: Attach VETH Ports to Namespaces
Move `veth1` into `VRF1` and `veth3` into `VRF2` (leaving `veth2` and `veth4` in the root namespace for OVS):
```bash
# Move veth1 to VRF1 namespace
ip link set veth1 netns VRF1

# Move veth3 to VRF2 namespace
ip link set veth3 netns VRF2
```

#### Step 5: Install & Start OpenVSwitch
Install `openvswitch-switch` package and ensure the daemon is running:
```bash
# Install OpenVSwitch
apt update && apt install -y openvswitch-switch

# Start and enable OpenVSwitch service
systemctl start openvswitch-switch
systemctl enable openvswitch-switch

# Check service status
systemctl status openvswitch-switch
```

#### Step 6: Create OVS Bridge & Attach Ports
Create an OVS switch (`ovs-br0`) and attach host-side veth interfaces (`veth2` and `veth4`):
```bash
# Add OVS bridge
ovs-vsctl add-br ovs-br0

# Attach veth2 and veth4 to ovs-br0
ovs-vsctl add-port ovs-br0 veth2
ovs-vsctl add-port ovs-br0 veth4

# Display OVS bridge topology and status
ovs-vsctl show
```

#### Step 7: Enable Interfaces & Assign IP Addresses
Bring interfaces UP and assign IP addresses within each virtual namespace:
```bash
# Bring host interfaces UP
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
```

#### Step 8: Test Inter-Namespace Connectivity
Verify ping from `VRF1` to `VRF2` across the OpenVSwitch bridge:
```bash
ip netns exec VRF1 ping -c 4 192.168.10.2
```

#### Step 9: Enable Spanning Tree Protocol (STP) [Optional]
Enable STP on the OVS bridge to prevent network loops and broadcast storms:
```bash
ovs-vsctl set bridge ovs-br0 stp_enable=true

# Check STP status
ovs-vsctl get bridge ovs-br0 stp_enable
```

#### Step 10: Verify MAC Address Learning Table
Inspect the OVS Forwarding Database (FDB) and compare learned MACs with namespace devices:
```bash
# Display OVS learned MAC addresses
ovs-appctl fdb/show ovs-br0

# Check actual MAC address of veth1 in VRF1
ip netns exec VRF1 ip link show veth1

# Check actual MAC address of veth3 in VRF2
ip netns exec VRF2 ip link show veth3
```

---

## 🔍 Verification Checklist

| Test Item | Command | Expected Result |
| :--- | :--- | :--- |
| **Linux Bridge Status** | `brctl show` | `br0` listed with interface (e.g. `eth0`) attached |
| **OVS Switch Status** | `ovs-vsctl show` | Bridge `ovs-br0` containing ports `veth2` and `veth4` |
| **IP Reachability** | `ip netns exec VRF1 ping 192.168.10.2` | 0% packet loss, valid ICMP replies |
| **MAC Match** | `ovs-appctl fdb/show ovs-br0` | Learned MACs match `veth1` and `veth3` MAC addresses |

---

## ❓ Troubleshooting & Tips

1. **Ping Fails Between Namespaces:**
   - Ensure interfaces are UP: Run `ip netns exec VRF1 ip link show` and confirm `veth1` state is `UP`.
   - Ensure host interfaces (`veth2`, `veth4`, `ovs-br0`) are UP in root namespace.
2. **Permission Denied / Operation Not Permitted:**
   - Always run namespace and OVS commands with `sudo` or as `root`.
3. **Module Loading Errors:**
   - If `modprobe bridge` fails, check if kernel headers match: `uname -r`.
4. **Cleanup Commands (Resetting Environment):**
   ```bash
   # Remove OVS bridge
   sudo ovs-vsctl del-br ovs-br0
   # Remove namespaces
   sudo ip netns del VRF1
   sudo ip netns del VRF2
   # Remove Linux bridge
   sudo ip link set dev br0 down && sudo brctl delbr br0
   ```
