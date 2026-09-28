#!/bin/bash
# ==============================================================================
# Lab 5a: Installation of KVM and Creation of Virtual Instances
# Description: Automated shell script for checking hardware virtualization, installing KVM packages,
#              configuring libvirt daemon, checking service status, downloading CirrOS disk image,
#              and verifying VM commands.
# Grounded in source: SOORIYA LAB 5A.pdf
# ==============================================================================

echo "=========================================================="
echo " Step 1: Checking Hardware Virtualization Support"
echo "=========================================================="
# Check CPU virtualization extensions: Intel (vmx) or AMD (svm)
echo "[*] Checking CPU hardware virtualization support (vmx/svm):"
VIRT_SUPPORT=$(egrep -c '(vmx|svm)' /proc/cpuinfo || true)
echo "CPU hardware virtualization count: $VIRT_SUPPORT"
if [ "$VIRT_SUPPORT" -ge 1 ]; then
    echo "SUCCESS: Hardware virtualization is enabled in CPU/BIOS."
else
    echo "WARNING: Hardware virtualization extensions (vmx/svm) not found or disabled in BIOS."
fi

# Check 64-bit Long Mode ('lm') support
echo "[*] Checking 64-bit CPU support (lm flag):"
LM_SUPPORT=$(egrep -c 'lm' /proc/cpuinfo || true)
echo "64-bit Long Mode flag count: $LM_SUPPORT"

echo "[*] System information (uname -a):"
uname -a

echo "[*] Checking KVM kernel module files:"
ls -l /lib/modules/$(uname -r)/kernel/arch/x86/kvm/kvm* 2>/dev/null || lsmod | grep kvm || echo "Checking loaded modules..."
sudo modprobe kvm 2>/dev/null || true
sudo modprobe kvm_intel 2>/dev/null || sudo modprobe kvm_amd 2>/dev/null || true


echo "=========================================================="
echo " Step 2: KVM Package Installation"
echo "=========================================================="
echo "[*] Installing qemu-kvm, libvirt-daemon-system, libvirt-clients, bridge-utils, qemu-system, virt-manager, and wget..."
sudo apt-get update
sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils qemu-system virt-manager wget

echo "[*] Adding user ($USER) to 'libvirt' and 'kvm' groups for non-root management..."
sudo usermod -aG libvirt,kvm "$USER" 2>/dev/null || true


echo "=========================================================="
echo " Step 3: Configuring Libvirt Daemon (/etc/libvirt/libvirtd.conf)"
echo "=========================================================="
LIBVIRTD_CONF="/etc/libvirt/libvirtd.conf"
if [ -f "$LIBVIRTD_CONF" ]; then
    echo "[*] Backing up and updating $LIBVIRTD_CONF..."
    sudo cp -n "$LIBVIRTD_CONF" "${LIBVIRTD_CONF}.bak" 2>/dev/null || true
    
    # Configure socket authorization and listening settings from Lab 5a guidelines
    sudo sed -i 's/^[# ]*listen_addr = .*/listen_addr = "0.0.0.0"/' "$LIBVIRTD_CONF" 2>/dev/null || echo 'listen_addr = "0.0.0.0"' | sudo tee -a "$LIBVIRTD_CONF"
    sudo sed -i 's/^[# ]*unix_sock_group = .*/unix_sock_group = "libvirt"/' "$LIBVIRTD_CONF" 2>/dev/null || true
    sudo sed -i 's/^[# ]*unix_sock_ro_perms = .*/unix_sock_ro_perms = "0777"/' "$LIBVIRTD_CONF" 2>/dev/null || true
    sudo sed -i 's/^[# ]*unix_sock_rw_perms = .*/unix_sock_rw_perms = "0777"/' "$LIBVIRTD_CONF" 2>/dev/null || true
    sudo sed -i 's/^[# ]*auth_unix_ro = .*/auth_unix_ro = "none"/' "$LIBVIRTD_CONF" 2>/dev/null || true
    sudo sed -i 's/^[# ]*auth_unix_rw = .*/auth_unix_rw = "none"/' "$LIBVIRTD_CONF" 2>/dev/null || true
    echo "Libvirt daemon configuration applied."
fi

echo "[*] Enabling and starting libvirtd service..."
sudo systemctl enable --now libvirtd 2>/dev/null || sudo systemctl restart libvirtd 2>/dev/null || sudo service libvirtd restart 2>/dev/null || true


echo "=========================================================="
echo " Step 4: Service Status & Virsh Verification"
echo "=========================================================="
echo "[*] Checking libvirtd service status:"
sudo systemctl status libvirtd --no-pager || true

echo "[*] Listing current virtual machines:"
sudo virsh list --all

echo "[*] Virsh Hypervisor & Node Info:"
sudo virsh version
sudo virsh nodeinfo


echo "=========================================================="
echo " Step 5: Downloading CirrOS Disk Image"
echo "=========================================================="
# Download cirros disk image for existing VM import if not already downloaded
CIRROS_DIR="$HOME/Downloads"
CIRROS_IMG="$CIRROS_DIR/cirros-0.5.1-x86_64-disk.img"
mkdir -p "$CIRROS_DIR"

if [ -f "$CIRROS_IMG" ]; then
    echo "[*] CirrOS disk image already exists at $CIRROS_IMG. Skipping download."
else
    echo "[*] Downloading CirrOS disk image to $CIRROS_DIR..."
    wget -c -P "$CIRROS_DIR/" https://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img
fi


echo "=========================================================="
echo " Step 6: Commands to execute inside the guest VM terminal"
echo "=========================================================="
echo "Inside the guest VM shell, run:"
echo "  mkdir sooriya"
echo "  cd sooriya"
echo '  echo "Hello, World" > file.txt'
echo "  cat file.txt"

echo "=========================================================="
echo " Lab 5a script completed successfully."
echo "=========================================================="
