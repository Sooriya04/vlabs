#!/bin/bash
# ==============================================================================
# Lab 5b: KVM – ISO Image Creation, Image Resizing, and Image Conversion
# Description: Shell commands for creating QCOW2 images, downloading Ubuntu ISO,
#              resizing disk images, and converting formats (VDI, VHD/VPC, RAW).
# Grounded in source: VT LAB 5TH EXCERCISE.docx.pdf
# ==============================================================================

# Ensure qemu-img and wget are installed
if ! command -v qemu-img &>/dev/null; then
    echo "[!] 'qemu-img' not found. Installing qemu-utils..."
    sudo apt-get update -qq && sudo apt-get install -y qemu-utils
fi

if ! command -v wget &>/dev/null; then
    echo "[!] 'wget' not found. Installing wget..."
    sudo apt-get update -qq && sudo apt-get install -y wget
fi

echo "=========================================================="
echo " Step 1: Download Ubuntu Server ISO"
echo "=========================================================="
ISO_FILE="ubuntu-18.04.6-server-amd64.iso"
ISO_URL="https://cdimage.ubuntu.com/ubuntu/releases/18.04/release/ubuntu-18.04.6-server-amd64.iso"

if [ -f "$ISO_FILE" ]; then
    echo "[*] ISO already exists ($ISO_FILE). Skipping download."
else
    echo "[*] Downloading Ubuntu Server ISO ($ISO_FILE)..."
    wget -c "$ISO_URL" || echo "Warning: Download failed or interrupted. Ensure internet connectivity."
fi


echo "=========================================================="
echo " Step 2: Create Virtual Hard Disk (QCOW2)"
echo "=========================================================="
# Creates 10GB QCOW2 virtual hard disk file
if [ ! -f "ubuntu_vm.qcow2" ]; then
    echo "[*] Creating 10GB QCOW2 virtual disk image: ubuntu_vm.qcow2"
    qemu-img create -f qcow2 ubuntu_vm.qcow2 10G
else
    echo "[*] Disk image ubuntu_vm.qcow2 already exists."
fi
qemu-img info ubuntu_vm.qcow2


echo "=========================================================="
echo " Step 3: Launch Virtual Machine Manager"
echo "=========================================================="
# Launch GUI for VM installation if DISPLAY is available
if [ -n "$DISPLAY" ] && command -v virt-manager &>/dev/null; then
    echo "[*] Launching virt-manager GUI in background..."
    virt-manager &>/dev/null &
else
    echo "[*] Headless or non-GUI terminal detected. virt-manager skipped."
    echo "    To launch manually on desktop: run 'virt-manager'"
fi


echo "=========================================================="
echo " Step 4: Image Resizing (VM must be powered off)"
echo "=========================================================="
# Increase disk image size by 5 GB
echo "[*] Resizing ubuntu_vm.qcow2 (+5G)..."
qemu-img resize ubuntu_vm.qcow2 +5G

echo "[*] Inspecting resized image metadata:"
qemu-img info ubuntu_vm.qcow2


echo "=========================================================="
echo " Step 5: Disk Image Format Conversion"
echo "=========================================================="
echo "[*] Converting QCOW2 to VDI (VirtualBox)..."
qemu-img convert -f qcow2 -O vdi ubuntu_vm.qcow2 output_image.vdi

echo "[*] Converting QCOW2 to VHD/VPC (Hyper-V)..."
qemu-img convert -f qcow2 -O vpc ubuntu_vm.qcow2 output_image.vhd

echo "[*] Converting QCOW2 to RAW (.img)..."
qemu-img convert -f qcow2 -O raw ubuntu_vm.qcow2 output_image.img


echo "=========================================================="
echo " Step 6: Verifying Converted Images Metadata & File Sizes"
echo "=========================================================="
qemu-img info output_image.vdi
qemu-img info output_image.vhd
qemu-img info output_image.img

echo ""
echo "[*] Generated Image Files:"
ls -lh ubuntu_vm.qcow2 output_image.vdi output_image.vhd output_image.img 2>/dev/null || true

echo "=========================================================="
echo " Lab 5b script execution completed."
echo "=========================================================="
