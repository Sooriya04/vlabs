#!/bin/bash
# =========================================================
# Shell Script: SSH & FTP Automation Setup
# Grounded in VT LAB 6TH EXCERCISE
# =========================================================

echo "=== Updating System Package Index ==="
sudo apt update

echo "=== Installing OpenSSH, VSFTPD, and FTP Client ==="
sudo apt install -y openssh-server vsftpd ftp

echo "=== Configuring VSFTPD (/etc/vsftpd.conf) ==="
VSFTPD_CONF="/etc/vsftpd.conf"
if [ -f "$VSFTPD_CONF" ]; then
    echo "[*] Backing up and updating $VSFTPD_CONF..."
    sudo cp -n "$VSFTPD_CONF" "${VSFTPD_CONF}.bak" 2>/dev/null || true
    
    # Enable local logins and file uploads (Lab 6 Method 4)
    sudo sed -i 's/^[# ]*local_enable=.*/local_enable=YES/' "$VSFTPD_CONF" 2>/dev/null || true
    sudo sed -i 's/^[# ]*write_enable=.*/write_enable=YES/' "$VSFTPD_CONF" 2>/dev/null || true
    sudo sed -i 's/^[# ]*chroot_local_user=.*/chroot_local_user=YES/' "$VSFTPD_CONF" 2>/dev/null || true
    
    # Ensure allow_writeable_chroot is set to avoid 500 OOPS: vsftpd: refusing to run with writable root inside chroot()
    if ! grep -q "allow_writeable_chroot=" "$VSFTPD_CONF"; then
        echo "allow_writeable_chroot=YES" | sudo tee -a "$VSFTPD_CONF" > /dev/null
    else
        sudo sed -i 's/^[# ]*allow_writeable_chroot=.*/allow_writeable_chroot=YES/' "$VSFTPD_CONF" 2>/dev/null || true
    fi
    
    # Configure passive FTP port range
    if ! grep -q "pasv_min_port=" "$VSFTPD_CONF"; then
        echo "pasv_enable=YES" | sudo tee -a "$VSFTPD_CONF" > /dev/null
        echo "pasv_min_port=40000" | sudo tee -a "$VSFTPD_CONF" > /dev/null
        echo "pasv_max_port=40100" | sudo tee -a "$VSFTPD_CONF" > /dev/null
    fi
    
    echo "[*] VSFTPD configuration updated successfully."
fi

echo "=== Enabling and Starting Services ==="
sudo systemctl enable --now ssh
sudo systemctl enable --now vsftpd
sudo systemctl restart vsftpd

echo "=== Configuring UFW Firewall Ports ==="
if command -v ufw &>/dev/null; then
    sudo ufw allow 22/tcp comment 'SSH'
    sudo ufw allow 21/tcp comment 'FTP Control'
    sudo ufw allow 20/tcp comment 'FTP Data'
    sudo ufw allow 40000:40100/tcp comment 'FTP Passive'
    sudo ufw reload
fi

echo "=== Adding Current User to vboxsf Group (for VirtualBox Shared Folder access) ==="
sudo usermod -aG vboxsf "$USER" 2>/dev/null || true
echo "Note: If using VirtualBox shared folders, group changes take effect after relogin or reboot."

echo ""
echo "=== Verification & Service Status ==="
echo "[*] SSH Service:    $(systemctl is-active ssh 2>/dev/null || echo 'inactive')"
echo "[*] VSFTPD Service: $(systemctl is-active vsftpd 2>/dev/null || echo 'inactive')"
echo ""
echo "[*] Active Network Addresses:"
ip -br addr show 2>/dev/null || ip a
echo ""
echo "Setup complete! Ready for SSH/SCP and FTP file transfer."
