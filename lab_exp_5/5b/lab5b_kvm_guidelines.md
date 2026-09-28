# Lab 5b Guidelines: KVM – ISO Image Creation, Resizing, and Format Conversion

## 1. Aim
To demonstrate creating virtual machine disk images using ISO installer media, resizing QCOW2 disk images, and converting disk images across standard virtual machine formats (`.qcow2`, `.vdi`, `.vhd`/`.vpc`, `.img`).

---

## 2. Step-by-Step Instructions

### Part 1: Creating VM Image from ISO Media
1. **Download Ubuntu Server ISO**:
   ```bash
   wget https://cdimage.ubuntu.com/ubuntu/releases/18.04/release/ubuntu-18.04.6-server-amd64.iso
   ```
2. **Create QCOW2 Virtual Disk Image**:
   Execute `qemu-img` to create a 10 GB disk file in QCOW2 format:
   ```bash
   qemu-img create -f qcow2 ubuntu_vm.qcow2 10G
   ```
3. **GUI Setup in Virt-Manager**:
   - Open `virt-manager`.
   - Right-click **QEMU/KVM** $ightarrow$ Select **New**.
   - Choose **Local install media (ISO image or CDROM)**.
   - Locate ISO: Browse to `ubuntu-18.04.6-server-amd64.iso`.
   - Set OS Type: **Linux**, Version: **Ubuntu 18.04 LTS**.
   - Allocate Memory: **2048 MiB**, CPUs: **2**.
   - Select custom disk image: Assign `ubuntu_vm.qcow2`.
   - Name VM and click **Finish**.
4. **Guest OS Installation Wizard Options**:
   - Language: **English**
   - Option: **Install Ubuntu Server**
   - Location: **India** (or local region)
   - Keyboard Layout: **English (US)**
   - Network / Hostname: `sooriya`
   - User Setup: Create username (`sooriya`) and password.
   - Partitioning: **Guided - use entire disk** (`vda` Virtio Block Device).
   - Write changes to disk: **Yes**.
   - HTTP Proxy: Leave blank $ightarrow$ Press **Enter**.
   - Updates: **No automatic updates**.
   - Software Selection: Use Spacebar to select **standard system utilities** and **OpenSSH server**.
   - Boot Loader: Install GRUB boot loader to Master Boot Record ($ightarrow$ **Yes**).
   - Complete installation, reboot, and log into the VM.

---

### Part 2: Virtual Disk Image Resizing
*Prerequisite*: Shut down the Virtual Machine before executing resizing operations.

1. **Expand QCOW2 Image Size**:
   ```bash
   qemu-img resize ubuntu_vm.qcow2 +5G
   ```
2. **Verify Updated Metadata**:
   ```bash
   qemu-img info ubuntu_vm.qcow2
   ```
   *Expected Output*: Displays increased virtual size (e.g. `15 GiB`).
3. **Partition & Filesystem Expansion inside Guest OS**:
   Boot into the VM OS to expand the guest filesystem/partition to consume the added storage.

---

### Part 3: Virtual Disk Image Format Conversion
`qemu-img` enables seamless conversion between hypervisor disk formats.

1. **Convert QCOW2 to VDI (VirtualBox)**:
   ```bash
   qemu-img convert -f qcow2 -O vdi ubuntu_vm.qcow2 output_image.vdi
   ```
2. **Convert QCOW2 to VHD/VPC (Hyper-V / Virtual PC)**:
   ```bash
   qemu-img convert -f qcow2 -O vpc ubuntu_vm.qcow2 output_image.vhd
   ```
3. **Convert QCOW2 to RAW Image (.img)**:
   ```bash
   qemu-img convert -f qcow2 -O raw ubuntu_vm.qcow2 output_image.img
   ```
4. **Verify Converted File Attributes**:
   ```bash
   qemu-img info output_image.vdi
   qemu-img info output_image.hvd
   qemu-img info output_image.img
   ```

---

## 3. Image Format Reference Matrix

| Format | File Extension | Target Hypervisor / Use Case |
| :--- | :--- | :--- |
| **QCOW2** | `.qcow2` | Native QEMU / KVM (supports copy-on-write, snapshots) |
| **VDI** | `.vdi` | Oracle VirtualBox |
| **VHD (VPC)** | `.vhd` | Microsoft Hyper-V / Virtual PC |
| **RAW** | `.img` | Direct raw disk image (uncompressed/flat) |

---

## 4. Result
Creation, ISO-based OS installation, disk resizing, and cross-platform format conversions of KVM disk images were successfully demonstrated.
