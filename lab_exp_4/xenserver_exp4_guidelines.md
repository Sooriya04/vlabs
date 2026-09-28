# Virtualization Laboratory — Experiment 4

**Title:**  
a) Installation and Configuration of Citrix XenServer  
b) Live Migration of Virtual Machines using XenCenter and `xe` CLI  

---

## 1. Aim
1. To install and configure **Citrix XenServer** as a Type-1 (bare-metal) hypervisor for executing multiple virtual machines on physical hardware.
2. To configure **XenCenter** (GUI) and the **`xe` CLI** for virtual machine lifecycle management.
3. To perform **Live Migration** of running Virtual Machines (VMs) between physical hosts without causing downtime.

---

## 2. Theoretical Background

### 2.1 What is Xen?
Xen is a **Type-1 (bare-metal) hypervisor** that runs directly on server hardware, sitting beneath operating systems. It controls physical CPU, memory, and storage, allocating them among multiple virtual guest instances (referred to as **Domains** or **DomU**). The primary management partition in Xen is called **Domain 0 (Dom0)**.

### 2.2 Virtualization Modes: Paravirtualization (PV) vs. Full Virtualization (HVM)
| Feature | Paravirtualization (PV) | Hardware-assisted Full Virtualization (HVM) |
| :--- | :--- | :--- |
| **Concept** | Guest OS is modified to be aware of hypervisor | Guest OS is unmodified; leverages CPU flags |
| **Hardware Requirement** | Standard CPU (no hardware extensions needed) | Requires CPU virtualization support (**Intel VT-x** / **AMD-V**) |
| **Performance** | High I/O efficiency, low overhead | High CPU performance with modern hardware acceleration |
| **OS Support** | Linux / Unix variants | Windows, Linux, and custom operating systems |

### 2.3 Hypervisor Comparison Matrix
| Feature | Xen / XenServer | KVM | VMware ESXi | Microsoft Hyper-V | Oracle VirtualBox |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Type** | Type 1 | Type 1 (In Linux kernel) | Type 1 | Type 1 | Type 2 |
| **Execution Environment** | Bare Metal | Bare Metal | Bare Metal | Bare Metal | Runs on Host OS |
| **Primary GUI Management** | XenCenter | virt-manager / Cockpit | vSphere Client | Hyper-V Manager | VirtualBox GUI |
| **Use Case** | Cloud / Enterprise | Enterprise / Linux | Enterprise Data Center | Enterprise Windows | Desktop Development |

### 2.4 XenServer vs. XenCenter
- **XenServer:** The bare-metal hypervisor installed directly on the server host machine.
- **XenCenter:** Windows-based desktop application used to remotely manage, configure, and monitor one or more XenServer hosts.

---

## 3. Requirements for Live Migration

Live Migration refers to transferring a stateful, powered-on virtual machine from one physical server host to another without shutting down the VM or disconnecting active applications.

1. **Shared Storage:** Both physical hosts must have concurrent read/write access to a shared storage repository (e.g., NFS, iSCSI, or SAN).
2. **CPU Compatibility:** Both source and target hosts must share compatible CPU families (matching instruction sets or masked CPU flags).
3. **Network Connectivity:** A dedicated high-speed, low-latency LAN connection between Dom0 interfaces on both hosts.
4. **Pool Configuration:** Hosts should ideally belong to a single **XenServer Resource Pool**.
5. **Open Firewall Ports:** Required ports for migration traffic and XenAPI must be accessible.

---

## 4. Part 4a: Guidelines for Citrix XenServer Installation & VM Creation

### Step 1: Media Preparation & BIOS Configuration
1. Download the Citrix XenServer / Citrix Hypervisor ISO image.
2. Flash the ISO onto a USB drive using tools such as **Rufus** or **Ventoy**.
3. Reboot the target physical host, enter the BIOS/UEFI configuration menu:
   - Enable **Intel VT-x** or **AMD-V** virtualization support.
   - Set the USB drive as the primary boot device.

### Step 2: Bare-Metal Installation
1. Boot from the USB installer and select **Install Citrix XenServer**.
2. Accept the EULA and select the local disk target for OS installation.
3. Configure the primary Network Interface Card (NIC) with a **Static IP address** (e.g., `10.10.25.150`), Subnet Mask, Gateway, and DNS.
4. Set the `root` administrative password.
5. Complete installation and reboot the host. The XenServer text-based console menu (xsconsole) will display the host IP address upon startup.

### Step 3: XenCenter Client Setup & VM Provisioning
1. Launch **XenCenter** on a client workstation.
2. Click **Server -> Add** and enter the XenServer IP address, username (`root`), and password.
3. Right-click the host and select **New VM**.
4. Choose an OS template (e.g., **CentOS 7** or **Ubuntu**).
5. Specify VM Name (e.g., `22IT043_KESHOKUMAR D`).
6. Select installation media ISO (`xs-tools.iso` or OS ISO library).
7. Allocate system resources (vCPUs: `4`, Memory: `3 GB`, Disk: `10 GB`).
8. Click **Create Now** to build and start the virtual machine.

---

## 5. Part 4b: Guidelines for Live Migration of VMs

### Approach A: Live Migration via XenCenter GUI
1. Ensure both XenServer Host 1 (`XENSERVER-1`) and Host 2 (`tce` / `xenserver-3`) are connected under XenCenter.
2. Connect both hosts to a shared Storage Repository (NFS / iSCSI).
3. Select the running VM under Host 1 in the resource tree.
4. Right-click the VM and choose **Move VM...** (or **Migrate VM**).
5. Select the destination host (Host 2 / `tce`) or destination shared storage repository.
6. Click **Move**. XenCenter transfers memory pages and VM execution context in real time.
7. Monitor the task progress. The VM will transition seamlessly to Host 2 with zero downtime.

### Approach B: Live Migration via `xe` CLI Commands
1. **Identify VM and Destination Host UUIDs:**
   ```bash
   xe vm-list name-label="22IT043_KESHOKUMAR_D" params=uuid
   xe host-list params=uuid,name-label,host-IP
   ```
2. **Execute Live Migration Command:**
   ```bash
   xe vm-migrate uuid=<VM_UUID> host-uuid=<TARGET_HOST_UUID>
   ```
3. **Cross-Pool / Storage XenMotion Migration (if storage is independent):**
   ```bash
   xe vm-migrate uuid=<VM_UUID> \
                host-uuid=<TARGET_HOST_UUID> \
                remote-master=<TARGET_HOST_IP> \
                remote-username=root \
                remote-password=<PASSWORD>
   ```
4. **Verify Migration Success:**
   ```bash
   xe vm-list uuid=<VM_UUID> params=name-label,resident-on,power-state
   ```

---

## 6. Essential `xe` CLI Command Cheat Sheet

| Operation | `xe` CLI Command |
| :--- | :--- |
| **List Hosts** | `xe host-list` |
| **List Virtual Machines** | `xe vm-list` |
| **Check Toolstack Status** | `xe-toolstack-restart` |
| **List OS Templates** | `xe template-list` |
| **Create VM from Template** | `xe vm-install template="CentOS 7" new-name-label="<VM_NAME>"` |
| **Set Memory Allocation** | `xe vm-memory-limits-set uuid=<VM_UUID> static-min=3GiB static-max=3GiB dynamic-min=3GiB dynamic-max=3GiB` |
| **Set vCPU Count** | `xe vm-param-set uuid=<VM_UUID> VCPUs-max=4 VCPUs-at-startup=4` |
| **Start VM** | `xe vm-start uuid=<VM_UUID>` |
| **Shutdown VM** | `xe vm-shutdown uuid=<VM_UUID>` |
| **Live Migrate VM** | `xe vm-migrate uuid=<VM_UUID> host-uuid=<TARGET_HOST_UUID>` |
| **List Storage Repositories** | `xe sr-list` |
| **Monitor Resources** | `xentop` |

---

## 7. Troubleshooting & Pitfalls
- **Host Unresponsive in XenCenter:** Run `xe-toolstack-restart` in the XenServer console to restart control services without affecting running VMs.
- **Migration Fails (CPU Incompatibility):** Ensure CPU feature masking is enabled in the host pool settings or use identical CPU models.
- **Shared Storage Missing:** Verify NFS/iSCSI exports and ensure both hosts can ping the storage server.

---

## 8. Result
The setup and installation of **Citrix XenServer** were successfully completed. Virtual machines were configured and executed, and **Live Migration** was successfully demonstrated between physical hosts using both XenCenter GUI and the `xe` command-line tool with zero downtime.
