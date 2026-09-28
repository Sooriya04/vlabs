#!/bin/bash
# =========================================================
# Shell Script: NFS Share Setup (Server & Client)
# Grounded in VT LAB 6TH EXCERCISE
# =========================================================

MODE="${1,,}"
TARGET_IP="$2"

if [ "$MODE" = "server" ]; then
    echo "=== Setting up NFS Server (Ubuntu) ==="
    sudo apt update
    sudo apt install -y nfs-kernel-server
    sudo mkdir -p /srv/nfs/sharedfolder
    sudo chown nobody:nogroup /srv/nfs/sharedfolder
    sudo chmod 777 /srv/nfs/sharedfolder
    
    # Create sample file for client verification (Lab 6 Method 1 Step 5)
    echo "Hello from Ubuntu NFS Server - $(date)" | sudo tee /srv/nfs/sharedfolder/ubuntu_test.txt > /dev/null
    
    if [ -n "$TARGET_IP" ]; then
        EXPORT_ENTRY="/srv/nfs/sharedfolder $TARGET_IP(rw,sync,no_subtree_check,no_root_squash)"
        if grep -Fq "/srv/nfs/sharedfolder $TARGET_IP" /etc/exports 2>/dev/null; then
            echo "Notice: NFS Export already present in /etc/exports for $TARGET_IP"
        else
            echo "$EXPORT_ENTRY" | sudo tee -a /etc/exports
            echo "NFS Export entry added to /etc/exports."
        fi
        
        sudo exportfs -ra
        sudo systemctl enable --now nfs-kernel-server
        sudo systemctl restart nfs-kernel-server
        
        # Configure firewall permissions for target client if UFW is active
        if command -v ufw &>/dev/null; then
            sudo ufw allow from "$TARGET_IP" to any port nfs 2>/dev/null || true
            sudo ufw allow 2049/tcp 2>/dev/null || true
            sudo ufw allow 111 2>/dev/null || true
        fi
        
        echo "SUCCESS: NFS Export configured and active for $TARGET_IP"
        sudo exportfs -v
    else
        echo "Notice: Target client IP not provided. Add client IP to /etc/exports manually."
        echo "Example: /srv/nfs/sharedfolder 192.168.56.104(rw,sync,no_subtree_check,no_root_squash)"
    fi

elif [ "$MODE" = "client" ]; then
    echo "=== Setting up NFS Client (Kali) ==="
    sudo apt update
    sudo apt install -y nfs-common
    sudo mkdir -p /mnt/nfs/sharedfolder
    
    if [ -n "$TARGET_IP" ]; then
        # Check if already mounted
        if mountpoint -q /mnt/nfs/sharedfolder; then
            echo "Notice: /mnt/nfs/sharedfolder is already mounted."
        else
            echo "[*] Checking available NFS exports on $TARGET_IP..."
            showmount -e "$TARGET_IP" 2>/dev/null || true
            
            echo "[*] Mounting $TARGET_IP:/srv/nfs/sharedfolder to /mnt/nfs/sharedfolder..."
            sudo mount -t nfs "$TARGET_IP:/srv/nfs/sharedfolder" /mnt/nfs/sharedfolder
        fi
        
        echo ""
        echo "=== Mount Verification ==="
        df -h | grep -E 'Filesystem|nfs'
        echo ""
        
        echo "[*] Reading file from NFS Server:"
        if [ -f /mnt/nfs/sharedfolder/ubuntu_test.txt ]; then
            cat /mnt/nfs/sharedfolder/ubuntu_test.txt
        else
            ls -l /mnt/nfs/sharedfolder
        fi
        
        echo ""
        echo "[*] Writing test file from NFS Client:"
        echo "Hello from NFS Client ($(hostname)) - $(date)" | sudo tee /mnt/nfs/sharedfolder/kali_test.txt > /dev/null && \
            echo "SUCCESS: Read/Write verification completed on NFS share."
    else
        echo "Notice: Server IP not provided. Mount manually using: sudo mount <SERVER_IP>:/srv/nfs/sharedfolder /mnt/nfs/sharedfolder"
    fi

else
    echo "Usage:"
    echo "  Server Setup: $0 server <KALI_CLIENT_IP>"
    echo "  Client Setup: $0 client <UBUNTU_SERVER_IP>"
fi
