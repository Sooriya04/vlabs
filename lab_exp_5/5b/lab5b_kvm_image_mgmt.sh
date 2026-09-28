#!/bin/bash
# ==============================================================================
# Lab 5b: KVM – ISO Image Creation, Image Resizing, and Image Conversion
# Description: Shell commands for creating QCOW2 images, downloading Ubuntu ISO,
#              resizing disk images, and converting formats (VDI, VHD/VPC, RAW).
# Grounded in source: VT LAB 5TH EXCERCISE.docx.pdf
# ==============================================================================

echo "=========================================================="
echo " Step 1: Download Ubuntu Server ISO"
echo "=========================================================="
wget https://cdimage.ubuntu.com/ubuntu/releases/18.04/release/ubuntu-18.04.6-server-amd64.iso


echo "=========================================================="
echo " Step 2: Create Virtual Hard Disk (QCOW2)"
echo "=========================================================="
# Creates 10GB QCOW2 virtual hard disk file
qemu-img create -f qcow2 ubuntu_vm.qcow2 10G


echo "=========================================================="
echo " Step 3: Launch Virtual Machine Manager"
echo "=========================================================="
# Launch GUI for VM installation
virt-manager &


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
echo " Step 6: Verifying Converted Images Metadata"
echo "=========================================================="
qemu-img info output_image.vdi
qemu-img info output_image.vhd
qemu-img info output_image.img

echo "=========================================================="
echo " Lab 5b script execution completed."
echo "=========================================================="
