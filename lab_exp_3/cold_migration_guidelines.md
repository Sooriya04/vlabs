# Cold Migration of Virtual Machines via OVA Export and Import

## Overview & Aim
The objective of this procedure is to perform a **cold migration** of a virtual machine (VM) from a source host to a destination host using the export/import appliance method in **Open Virtualization Format (OVA)**. Cold migration ensures seamless transfer of VM configurations, virtual storage disk data, and operating system state while the VM is powered off.

---

## Prerequisites
1. **VM Power State**: The VM must be completely shut down (powered off). Suspend/Saved state is not sufficient.
2. **Hypervisor Software**: Both source and destination host systems must have **Oracle VM VirtualBox** installed.
3. **Storage Capacity**: Ensure sufficient storage capacity on the destination storage device and target host directory to hold the `.ova` file and unpacked disk files.
4. **Transfer Medium**: External storage device (USB drive, external HDD/SSD) or network transfer channel (`scp`, `rsync`, or shared network directory).

---

## Step-by-Step Procedure

### Phase 1: Source Host - Pre-Migration & Setup
1. **Boot Guest OS & Prepare Test File**:
   - Power on the virtual machine (e.g., `sooriya`).
   - Open terminal inside guest OS.
   - Create and verify presence of test data:
     ```bash
     mkdir -p sooriya
     echo "Test Data for Migration" > sooriya/file.txt
     cat sooriya/file.txt
     ```
2. **Shutdown Virtual Machine**:
   - Issue a clean shutdown from within guest OS or power off cleanly via VirtualBox Manager.

---

### Phase 2: Source Host - OVA Export Procedure

#### GUI Method (VirtualBox Manager)
1. Open **VirtualBox Manager**.
2. Click **File** $\rightarrow$ **Export Appliance...** (or press `Ctrl + E`).
3. Select target VM (`sooriya`) from list $\rightarrow$ Click **Next**.
4. Configure Export Settings:
   - **Format**: Select *Open Virtualization Format 1.0*.
   - **File Path**: Set destination path (e.g., `E:\sooriya\sooriya.ova` or `/tmp/ova_export/sooriya.ova`).
   - **Manifest**: Keep *Write Manifest file* checked (default).
   - **MAC Address Policy**: Retain default policy.
5. Click **Next**, review appliance parameters, and click **Finish / Export**.
6. **Verify Export**: Open File Explorer / Terminal and check that `sooriya.ova` is successfully created.

#### Host CLI Method (`VBoxManage`)
```bash
# Power off VM gracefully if running
VBoxManage controlvm "sooriya" acpipoweroff

# Export VM to OVA package with manifest
VBoxManage export "sooriya" --output "/path/to/sooriya.ova" --ovf10 --manifest
```

---

### Phase 3: File Transfer
Copy the `.ova` package to external transfer media or transfer over network to the destination host:
```bash
# Example via USB / Local Copy
cp /path/to/sooriya.ova /media/usb_drive/

# Example via SSH/SCP
scp /path/to/sooriya.ova user@destination_host:/tmp/
```

---

### Phase 4: Destination Host - Appliance Import Procedure

#### GUI Method (VirtualBox Manager)
1. Open **VirtualBox Manager** on destination system.
2. Go to **File** $\rightarrow$ **Import Appliance...** (or press `Ctrl + I`).
3. Click **Browse**, select `sooriya.ova`, and click **Next**.
4. Review VM configuration, set target VM name (e.g., `sooriya1`), and click **Import**.
5. Wait for import process to complete.

#### Host CLI Method (`VBoxManage`)
```bash
# Import OVA package into VirtualBox
VBoxManage import "/path/to/sooriya.ova" --vsys 0 --vmname "sooriya1"
```

---

### Phase 5: Post-Migration Verification & Data Integrity
1. Start the newly imported VM (`sooriya1`):
   - **GUI**: Select `sooriya1` $\rightarrow$ Click **Start**.
   - **CLI**: `VBoxManage startvm "sooriya1"`
2. Log into guest OS terminal and execute:
   ```bash
   cd sooriya
   cat file.txt
   ```
3. **Expected Result**: The file content, directory structure, configurations, and system state are fully preserved and retained without error.

---

## Command Reference Summary Table

| Scope | Operation | Command / Procedure |
|---|---|---|
| **Guest OS** | Create Test File | `mkdir -p sooriya && echo "data" > sooriya/file.txt` |
| **Guest OS** | Verify File Content | `cd sooriya && cat file.txt` |
| **Host CLI** | Graceful Power Off | `VBoxManage controlvm "sooriya" acpipoweroff` |
| **Host CLI** | Export VM to OVA | `VBoxManage export "sooriya" -o "sooriya.ova" --ovf10 --manifest` |
| **Host CLI** | Import OVA Package | `VBoxManage import "sooriya.ova" --vsys 0 --vmname "sooriya1"` |
| **Host CLI** | Start Migrated VM | `VBoxManage startvm "sooriya1"` |
| **Host CLI** | Transfer File (SCP) | `scp sooriya.ova user@dest_host:/path/` |

---

## Troubleshooting & Key Notes
- **Power State Mismatch**: If export fails, verify VM is not in 'Paused' or 'Saved' state. It must be 'Powered Off'.
- **MAC Address Conflicts**: When importing on the same network as the source, ensure unique MAC address re-generation if both instances run simultaneously.
- **Disk Space Errors**: OVA packages are compressed, but importing expands disk images to full provisioned size. Ensure destination host has sufficient free disk space.
