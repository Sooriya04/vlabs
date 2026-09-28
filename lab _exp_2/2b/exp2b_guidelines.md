# Lab Experiment 2b Guidelines: VM-to-VM Ping and VM-to-Native Ping Connectivity Analysis

---

## 1. Aim
To configure network interfaces, manage firewall security rules, and verify network layer connectivity (determining if target system is alive) between VM-to-VM and VM-to-Native Host using the `ping` command.

---

## 2. Pre-Requisite Architecture & Network Configuration

Before initiating connectivity commands, ensure the VirtualBox environment is configured as follows:

1. **Power ON Systems**:
   - Primary Linux VM (e.g., **Ubuntu**).
   - Secondary Linux VM (e.g., **Kali Linux** or **Linux Mint**).
   - Physical Host System (**Windows Native OS**).

2. **Configure VirtualBox Network Adapters**:
   - Open **VirtualBox Manager** -> Select **VM** -> **Settings** -> **Network**.
   - Set **Adapter 1**: Attached to **Host-Only Adapter** (e.g., `vboxnet0` or `VirtualBox Host-Only Ethernet Adapter`).
   - *Note*: Using Host-Only mode creates a dedicated private virtual network between the host and virtual machines without requiring an active internet connection.

3. **Subnet Consistency**:
   - Verify both VMs and the Host-Only interface reside on the same network subnet (e.g., `192.168.56.x/24`).

---

## 3. Firewall Rules & Security Settings

ICMP Echo Requests (ping packets) are often blocked by default firewalls. Follow these steps to allow ping traffic:

### A. Linux VM Firewall Configuration
Execute on both Linux VMs:
```bash
# 1. Disable Uncomplicated Firewall (UFW)
sudo ufw disable

# 2. Check UFW status to confirm it is inactive
sudo ufw status

# 3. Flush existing IP tables filter rules
sudo iptables -F
```

### B. Windows Host Firewall Configuration
1. Open **Windows Defender Firewall with Advanced Security** (search `wf.msc` in Windows Start).
2. Click **Inbound Rules** in the left panel.
3. Locate **File and Printer Sharing (Echo Request - ICMPv4-In)** for IPv4.
4. Right-click and select **Enable Rule** (for both Private and Domain profiles).

---

## 4. Step-by-Step Command Execution & Connectivity Testing

### Step 1: Identify System IP Addresses

- **On Linux VMs** (Ubuntu / Kali / Mint):
  ```bash
  ip a
  # or
  ip addr show
  # or
  ifconfig
  ```
  *(Identify the IP under the host-only adapter interface, e.g., `192.168.56.101` and `192.168.56.102`)*.

- **On Windows Host**:
  Open Command Prompt (`cmd`) or PowerShell:
  ```cmd
  ipconfig
  ```
  *(Identify the IPv4 address of the VirtualBox Host-Only Network Adapter, e.g., `192.168.56.1`)*.

---

### Step 2: Local Loopback Ping Verification
Test internal TCP/IP network protocol stack functionality on the Linux VM:
```bash
ping -c 4 127.0.0.1
```

---

### Step 3: VM-to-Native Host Ping Test
Execute from the primary Linux VM (Ubuntu) targeting the Windows Native Host IP:
```bash
# Syntax: ping -c <count> <Windows_Host_IP>
ping -c 4 192.168.56.1
```
- **Expected Outcome**: `0% packet loss`, displaying response times in milliseconds (e.g., `64 bytes from 192.168.56.1: icmp_seq=1 ttl=128 time=0.45 ms`).

---

### Step 4: VM-to-VM Ping Test
Execute from the primary Linux VM (Ubuntu) targeting the secondary VM (Kali / Mint):
```bash
# Syntax: ping -c <count> <Secondary_VM_IP>
ping -c 4 192.168.56.102
```
- **Expected Outcome**: `0% packet loss`, verifying direct peer-to-peer virtual network communication.

---

### Step 5: Native Host to VM Ping Test
Open Windows Command Prompt (`cmd`) and ping both Linux VMs:
```cmd
:: Ping Ubuntu VM from Windows Host
ping 192.168.56.101

:: Ping Secondary VM from Windows Host
ping 192.168.56.102
```

---

## 5. Comprehensive Command Summary Matrix

| Task / Objective | Linux Command | Windows Command |
| :--- | :--- | :--- |
| **Check Network Interfaces** | `ip a` / `ifconfig` | `ipconfig` |
| **Disable Firewall** | `sudo ufw disable` | GUI: Windows Firewall Inbound ICMP Rule |
| **Flush Filter Rules** | `sudo iptables -F` | N/A |
| **Loopback Test** | `ping -c 4 127.0.0.1` | `ping 127.0.0.1` |
| **VM to Host Ping** | `ping -c 4 <Windows_Host_IP>` | N/A |
| **VM to VM Ping** | `ping -c 4 <Target_VM_IP>` | N/A |
| **Host to VM Ping** | N/A | `ping <Target_VM_IP>` |

---

## 6. Troubleshooting & Missing Commands Added

If ping requests result in `Destination Host Unreachable` or `100% packet loss`:

```bash
# 1. Check active routing table on Linux
ip route

# 2. Renew DHCP IP lease on Linux VM if interface lacks IP
sudo dhclient -r && sudo dhclient

# 3. Discover active hosts on the Host-Only subnet (192.168.56.0/24)
sudo apt install -y nmap
sudo nmap -sn 192.168.56.0/24
```
