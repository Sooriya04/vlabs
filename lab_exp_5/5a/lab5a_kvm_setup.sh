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
# Output >= 1 indicates CPU hardware virtualization support; 0 indicates no support
echo "[*] Checking CPU virtualization support:"
egrep -c 'lm' /proc/cpuinfo

echo "[*] System information (uname -a):"
uname -a

echo "[*] Checking KVM kernel module files:"
ls -l /lib/modules/$(uname -r)/kernel/arch/x86/kvm/kvm*


echo "=========================================================="
echo " Step 2: KVM Package Installation"
echo "=========================================================="
echo "[*] Installing qemu-kvm, libvirt-daemon-system, libvirt-clients, bridge-utils, qemu-system, and virt-manager..."
sudo apt-get update
sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils qemu-system virt-manager


echo "=========================================================="
echo " Step 3: Service Status & Virsh Verification"
echo "=========================================================="
echo "[*] Checking libvirtd service status:"
sudo systemctl status libvirtd --no-pager

echo "[*] Listing current virtual machines:"
sudo virsh list --all

echo "[*] Virsh Hypervisor & Node Info:"
sudo virsh version
sudo virsh nodeinfo


echo "=========================================================="
echo " Step 4: Downloading CirrOS Disk Image"
echo "=========================================================="
# Download cirros disk image for existing VM import
mkdir -p ~/Downloads
wget -P ~/Downloads/ https://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img


echo "=========================================================="
echo " Step 5: Commands to execute inside the guest VM terminal"
echo "=========================================================="
echo "Inside the guest VM shell, run:"
echo "  mkdir sooriya"
echo "  cd sooriya"
echo "  echo "Hello, World" > file.txt"
echo "  cat file.txt"

echo "=========================================================="
echo " Lab 5a script completed successfully."
echo "=========================================================="
