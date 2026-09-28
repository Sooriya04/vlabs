#!/bin/bash
# =========================================================
# Shell Script: NFS Share Setup (Server & Client)
# Grounded in VT LAB 6TH EXCERCISE
# =========================================================

MODE="$1"
TARGET_IP="$2"

if [ "$MODE" == "server" ]; then
    echo "=== Setting up NFS Server (Ubuntu) ==="
    sudo apt update
    sudo apt install nfs-kernel-server -y
    sudo mkdir -p /srv/nfs/sharedfolder
    sudo chown nobody:nogroup /srv/nfs/sharedfolder
    sudo chmod 777 /srv/nfs/sharedfolder
    
    if [ -n "$TARGET_IP" ]; then
        echo "/srv/nfs/sharedfolder $TARGET_IP(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
        sudo exportfs -a
        sudo systemctl restart nfs-kernel-server
        echo "NFS Export configured for $TARGET_IP"
    else
        echo "Notice: Target client IP not provided. Add client IP to /etc/exports manually."
    fi

elif [ "$MODE" == "client" ]; then
    echo "=== Setting up NFS Client (Kali) ==="
    sudo apt update
    sudo apt install nfs-common -y
    sudo mkdir -p /mnt/nfs/sharedfolder
    
    if [ -n "$TARGET_IP" ]; then
        sudo mount "$TARGET_IP:/srv/nfs/sharedfolder" /mnt/nfs/sharedfolder
        echo "NFS Share mounted from $TARGET_IP"
        df -h | grep nfs
    else
        echo "Notice: Server IP not provided. Mount manually using: sudo mount <SERVER_IP>:/srv/nfs/sharedfolder /mnt/nfs/sharedfolder"
    fi

else
    echo "Usage:"
    echo "  Server Setup: $0 server <KALI_CLIENT_IP>"
    echo "  Client Setup: $0 client <UBUNTU_SERVER_IP>"
fi
