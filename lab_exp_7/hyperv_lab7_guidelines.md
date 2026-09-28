# Virtualization Lab Experiment 7: Guidelines & Command Reference

This document covers the complete walkthrough for **Lab Experiment 7a** and **Lab Experiment 7b**, including GUI procedures, PowerShell automation, Linux guest post-installation steps, and added missing commands.

---

## Experiment 7a: Configuration of Hyper-V on Windows

### **Aim**
To configure Hyper-V on Windows for creating and managing virtual machines (VMs), enabling efficient virtualization and resource utilization.

### **Method 1: GUI Procedure**
1. Open the **Start menu**, search for **"Turn Windows features on or off"**, and click to open it.
2. Locate **Hyper-V** in the features list, check all sub-boxes (**Hyper-V Management Tools** and **Hyper-V Platform**), and click **OK**.
3. **Restart** the computer to apply the changes.
4. After restarting, search for **Hyper-V Manager** in the Start menu and launch the application.
5. Verify that Hyper-V Manager opens and displays the host server.

### **Method 2: PowerShell / CLI Procedure (Added Command)**
Run Windows PowerShell as **Administrator**:
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```
*Alternatively, using DISM:*
```cmd
dism /online /enable-feature /featurename:Microsoft-Hyper-V -all
```

---

## Experiment 7b: VM Creation, PowerShell Commands, and Management

### **Aim**
To create and manage Virtual Machines (VMs) using Hyper-V, including PowerShell commands for automation, efficient administration, and storage migration.

---

### **Part 1: VM Installation via Hyper-V Manager (GUI)**

1. Open **Hyper-V Manager**, right-click the host server, and select **New -> Virtual Machine**.
2. **VM Name**: `sooriya_ubuntu` -> Click **Next**.
3. **Generation**: Select **Generation 2**.
4. **Startup Memory**: Assign **2048 MB** (2 GB).
5. **Networking**: Select **Default Switch**.
6. **Virtual Hard Disk**: Connect a VHD with disk size set to **30 GB**.
7. **Installation Options**: Select **Install an operating system from a bootable image file** and browse to the Ubuntu ISO path (e.g., `D:\soft\Cloud lab Software\ubuntu-22.04.3-desktop-amd64.iso`).
8. **Security Configuration (Crucial Step)**:
   - Right-click the newly created VM -> **Settings -> Security**.
   - Set the **Secure Boot template** to **Microsoft UEFI Certificate Authority** (or disable Secure Boot for third-party Linux kernels).
9. **Launch**: Start and Connect to the VM to perform standard Ubuntu OS installation.

---

### **Part 2: VM Installation & Management via PowerShell**

#### **1. Create Storage Directory**
```powershell
New-Item -ItemType Directory -Path "C:\Hyper-V"
```

#### **2. Create Virtual Machine**
```powershell
New-VM -Name "Sooriya_Ubuntu_PS" -MemoryStartupBytes 2GB -Generation 2 -NewVHDPath "C:\Hyper-V\Sooriya_Ubuntu_PS.vhdx" -NewVHDSizeBytes 30GB
```

#### **3. Connect Network Adapter**
```powershell
Connect-VMNetworkAdapter -VMName "Sooriya_Ubuntu_PS" -SwitchName "Default Switch"
```

#### **4. Attach Operating System ISO**
```powershell
Add-VMDvdDrive -VMName "Sooriya_Ubuntu_PS" -Path "D:\soft\Cloud lab Software\ubuntu-22.04.3-desktop-amd64.iso"
```

#### **5. [Added Command] Set Secure Boot Template for Linux Gen 2 VM**
```powershell
Set-VMFirmware -VMName "Sooriya_Ubuntu_PS" -SecureBootTemplate "MicrosoftUEFICertificateAuthority"
```

#### **6. Lifecycle Control (Start / Verify / Stop)**
```powershell
# Start VM
Start-VM -Name "Sooriya_Ubuntu_PS"

# Check VM Status
Get-VM -Name "Sooriya_Ubuntu_PS"

# Stop VM
Stop-VM -Name "Sooriya_Ubuntu_PS"
```

---

### **Part 3: VM Storage Migration**

#### **GUI Procedure**
1. In Hyper-V Manager, right-click `Sooriya_Ubuntu_PS` and select **Move...**
2. Choose **Move the virtual machine's storage** -> Click **Next**.
3. Select **Move all of the virtual machine's data to a single location**.
4. Set the destination path to `C:\Hyper-V Migrated` and click **Finish**.
5. Verify in File Explorer that the `.vhdx` file has successfully moved to `C:\Hyper-V Migrated`.

#### **PowerShell Procedure (Added Command)**
```powershell
New-Item -ItemType Directory -Path "C:\Hyper-V Migrated" -Force
Move-VMStorage -VMName "Sooriya_Ubuntu_PS" -DestinationStoragePath "C:\Hyper-V Migrated"
```

---

## Part 4: Linux Post-Installation Commands (Inside Ubuntu VM)

Once Ubuntu is installed inside the Hyper-V VM, run these shell commands inside the Linux terminal:

```bash
# 1. Update package list and system packages
sudo apt update && sudo apt upgrade -y

# 2. Install Hyper-V Integration Services for dynamic memory & time sync
sudo apt install -y linux-tools-virtual linux-cloud-tools-virtual

# 3. Verify hypervisor detection & hardware information
lscpu | grep -i "Hypervisor"

# 4. Check active IP and Network connectivity
ip a
ping -c 3 google.com

# 5. Check Disk and RAM utilization
free -h
df -h /
```

---

## Summary of Added Missing Commands

1. **PowerShell Hyper-V Feature Enablement**:
   `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All`
   *(Automates Lab 7a GUI feature installation)*
2. **UEFI Secure Boot Configuration for Ubuntu Gen 2**:
   `Set-VMFirmware -VMName "Sooriya_Ubuntu_PS" -SecureBootTemplate "MicrosoftUEFICertificateAuthority"`
   *(Translates GUI Security setting from Lab 7b Part 1 into PowerShell)*
3. **PowerShell Storage Migration**:
   `Move-VMStorage -VMName "Sooriya_Ubuntu_PS" -DestinationStoragePath "C:\Hyper-V Migrated"`
   *(Automates Lab 7b Part 3 storage migration)*
4. **Hyper-V Linux Integration Services**:
   `sudo apt install -y linux-tools-virtual linux-cloud-tools-virtual`
   *(Ensures full guest driver support for Ubuntu on Hyper-V)*
