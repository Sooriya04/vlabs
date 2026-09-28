# Virtual Machine File Transfer Guidelines (Lab Exercise 6)

This guideline document outlines the Linux commands, network setup, and procedures for transferring files between Virtual Machines (Ubuntu and Kali Linux) using four distinct methods as specified in **VT LAB 6TH EXCERCISE**.

---

## Prerequisites & Network Configuration
Before attempting file transfer, both Virtual Machines must be on the same subnet to communicate with each other.

1. **VirtualBox Adapter Settings**:
   - **Adapter 1**: Set to `Host-only Adapter` (creates a private network on the same subnet, e.g., `192.168.56.0/24`).
   - **Adapter 2**: Set to `NAT` (enables outbound internet access for downloading `apt` packages).
2. **Check IP Addresses**:
   ```bash
   ip a
   ```
   Ensure both VMs reflect IP addresses on the same host-only subnet (e.g., Ubuntu: `192.168.56.103/24`, Kali: `192.168.56.104/24`).

---

## Method 1: File Transfer via NFS Share (Ubuntu Server & Kali Client)

### Ubuntu VM (NFS Server Setup)
1. **Update package index & install NFS Kernel Server**:
   ```bash
   sudo apt update
   sudo apt install nfs-kernel-server -y
   ```
2. **Create export directory & assign permissions**:
   ```bash
   sudo mkdir -p /srv/nfs/sharedfolder
   sudo chown nobody:nogroup /srv/nfs/sharedfolder
   sudo chmod 777 /srv/nfs/sharedfolder
   ```
3. **Configure `/etc/exports`**:
   Open `/etc/exports` using nano:
   ```bash
   sudo nano /etc/exports
   ```
   Add the following line (replace `<KALI_IP>` with Kali's IP):
   ```text
   /srv/nfs/sharedfolder <KALI_IP>(rw,sync,no_subtree_check,no_root_squash)
   ```
4. **Export shares & restart server**:
   ```bash
   sudo exportfs -a
   sudo systemctl restart nfs-kernel-server
   ```
5. **Create a test file on Ubuntu**:
   ```bash
   echo "Hello from Ubuntu" | sudo tee /srv/nfs/sharedfolder/ubuntu_test.txt
   ```

### Kali VM (NFS Client Setup)
1. **Install NFS common client**:
   ```bash
   sudo apt update
   sudo apt install nfs-common -y
   ```
2. **Create mount directory & mount NFS share**:
   ```bash
   sudo mkdir -p /mnt/nfs/sharedfolder
   sudo mount <UBUNTU_IP>:/srv/nfs/sharedfolder /mnt/nfs/sharedfolder
   ```
3. **Verify mount & read/write access**:
   ```bash
   df -h | grep nfs
   ls -l /mnt/nfs/sharedfolder
   cat /mnt/nfs/sharedfolder/ubuntu_test.txt
   ```

---

## Method 2: VirtualBox Shared Folder

### Step 1: Create Host Shared Directory & VirtualBox Settings
1. On Host OS (Windows/Linux), create folder `C:\VMShared`.
2. In VirtualBox Manager (for both Ubuntu VMs):
   - Open **Settings -> Shared Folders**.
   - Click **Add new shared folder (+)**.
   - Set **Folder Path**: `C:\VMShared`, **Folder Name**: `VMShared`.
   - Tick **Auto-mount**.
3. Install Guest Additions inside VM:
   - In VirtualBox menu: **Devices -> Insert Guest Additions CD image...** and run installation.

### Step 2: Fix Guest Folder Permissions
1. Check automatically mounted folder in `/media`:
   ```bash
   ls /media
   ```
2. If getting `Permission denied` when listing `/media/sf_VMShared`, add user to `vboxsf` group:
   ```bash
   sudo usermod -aG vboxsf $USER
   sudo reboot
   ```
3. **Transfer files across VMs**:
   ```bash
   # From VM1:
   cp VM1.txt /media/sf_VMShared/
   
   # From VM2:
   ls /media/sf_VMShared
   cat /media/sf_VMShared/VM1.txt
   ```

---

## Method 3: SSH & SCP (Secure Shell File Transfer)

### Step 1: Install & Enable OpenSSH (Both VMs)
```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
```

### Step 2: Firewall Rules
```bash
sudo ufw allow 22/tcp
sudo ufw reload
```

### Step 3: File Transfer using SCP
1. SSH into Remote VM:
   ```bash
   ssh username@<REMOTE_IP>
   ```
2. Copy file from Client to Remote VM:
   ```bash
   scp file.txt username@<REMOTE_IP>:/home/username/
   ```

---

## Method 4: FTP Transfer via VSFTPD

### Step 1: Install & Configure VSFTPD Server (VM1)
```bash
sudo apt update
sudo apt install vsftpd -y
sudo systemctl enable --now vsftpd
```
Edit `/etc/vsftpd.conf`:
```bash
sudo nano /etc/vsftpd.conf
```
Ensure the following settings:
```ini
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
```
Restart VSFTPD & allow firewall ports:
```bash
sudo systemctl restart vsftpd
sudo ufw allow 21/tcp
sudo ufw allow 20/tcp
sudo ufw status
```

### Step 2: FTP Client Connection & Commands (VM2)
1. Install FTP client on VM2:
   ```bash
   sudo apt install ftp -y
   ```
2. Connect to FTP Server:
   ```bash
   ftp <VM1_IP>
   ```
3. Common FTP commands:
   - `ls` : List files on server
   - `cd <folder>` : Change remote directory
   - `get <filename>` : Download file from server
   - `put <filename>` : Upload file to server
   - `bye` : Disconnect session
