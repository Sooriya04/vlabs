# Lab 5a Guidelines: Installation of KVM and Creation of Virtual Instances

## 1. Aim
To install KVM (Kernel-based Virtual Machine) and create virtual instances for setting up a virtualized environment on a Linux system.

---

## 2. Theoretical Overview & Benefits
KVM turns Linux into a Type-1 hypervisor embedded directly within the Linux kernel. Each Virtual Machine (VM) operates with its own virtualized hardware (CPU, RAM, network interfaces, and disk storage) running an independent operating system.

### Benefits of KVM:
- **Open Source**: Free and backed by the Linux community.
- **Performance**: Delivers near-native speed utilizing CPU hardware extensions (Intel VT-x / AMD-V).
- **Security**: Strict isolation enforced via SELinux and AppArmor.
- **Scalability**: Excellent vertical scaling supporting numerous instances per host.
- **Flexibility**: Broad OS support including Linux, BSD, and Windows.
- **Integration**: Native integration with `libvirt`, `virt-manager`, and cloud stacks like OpenStack.
- **Live Migration**: Allows moving active VMs between physical hosts without downtime.

---

## 3. Step-by-Step Procedure & Execution

### Phase 1: Hardware & System Check
1. **Verify CPU Hardware Virtualization Support**:
   ```bash
   egrep -c 'lm' /proc/cpuinfo
   ```
   *Note*: An output value $\ge 1$ confirms CPU hardware virtualization capability.
2. **Inspect Kernel & System Information**:
   ```bash
   uname -a
   ```
   Displays host architecture (`x86_64`), kernel version, OS release, and hostname.
3. **Verify KVM Kernel Modules**:
   ```bash
   ls /lib/modules/$(uname -r)/kernel/arch/x86/kvm/kvm*
   ```
   Confirms existence of `kvm.ko`, `kvm-intel.ko`, or `kvm-amd.ko`.

---

### Phase 2: Installing KVM Packages
Install the required hypervisor packages, user-space toolkits, and management software:
```bash
sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils qemu-system virt-manager
```

---

### Phase 3: Libvirt Daemon Configuration (`/etc/libvirt/libvirtd.conf`)
Configure remote access and unix socket authorization settings by editing `/etc/libvirt/libvirtd.conf` (e.g. using `nano`):
```ini
# /etc/libvirt/libvirtd.conf configuration options:
listen_addr = "0.0.0.0"
unix_sock_group = "libvirt"
unix_sock_ro_perms = "0777"
unix_sock_rw_perms = "0777"
unix_sock_dir = "/var/run/libvirt"
auth_unix_ro = "none"
auth_unix_rw = "none"
```

---

### Phase 4: Virsh Interactive Shell & Service Checks
1. **Check Daemon Status**:
   ```bash
   systemctl status libvirtd
   ```
2. **List Running VMs**:
   ```bash
   virsh list
   ```
3. **Interactive Virsh Management**:
   Launch `virsh` and run hypervisor inspection commands:
   ```text
   virsh
   virsh # version
   virsh # nodeinfo
   virsh # quit
   ```

---

### Phase 5: Importing Existing VM Image via Virt-Manager
1. **Download CirrOS Disk Image**:
   ```bash
   wget https://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img -P ~/Downloads/
   ```
2. **Virt-Manager Wizard Steps**:
   - Open **Virtual Machine Manager** (`virt-manager`).
   - Right-click **QEMU/KVM** $ightarrow$ Click **New**.
   - Select **Import existing disk image** $ightarrow$ Click **Forward**.
   - Browse and choose: `~/Downloads/cirros-0.5.1-x86_64-disk.img`.
   - OS Selection: **Generic Linux 2024** (or Generic).
   - Resource allocation: Set **Memory (1024 MiB)** and **CPUs (1)**.
   - Enter VM Name and click **Finish**.

---

### Phase 6: Inside the Booted VM Test Commands
Upon successful boot and login to the virtual instance console, test basic file system operations:
```bash
mkdir sooriya
cd sooriya
echo "Hello, World" > file.txt
cat file.txt
```

---

## 4. Result
KVM was successfully installed on the Linux host, and virtual instances were configured and booted using `virt-manager` and `virsh`.
