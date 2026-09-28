# ==============================================================================
# Hyper-V Lab Experiment 7 Automated PowerShell Script
# Based on Lab Experiment 7a (Hyper-V Config) and 7b (VM Creation & Management)
# ==============================================================================

# ------------------------------------------------------------------------------
# Part 1: Enable Hyper-V Feature (Lab 7a)
# Note: Requires Administrator privileges. Computer restart is required afterwards.
# ------------------------------------------------------------------------------
Write-Host "Checking/Enabling Hyper-V Feature..." -ForegroundColor Cyan
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

# ------------------------------------------------------------------------------
# Part 2: VM Directory & VM Creation (Lab 7b)
# ------------------------------------------------------------------------------
$VMName = "Sooriya_Ubuntu_PS"
$VHDDirectory = "C:\Hyper-V"
$VHDPath = "$VHDDirectory\Sooriya_Ubuntu_PS.vhdx"
$VMSize = 30GB
$VMMemory = 2GB
$SwitchName = "Default Switch"
$ISOPath = "D:\soft\Cloud lab Software\ubuntu-22.04.3-desktop-amd64.iso"
$MigrationPath = "C:\Hyper-V Migrated"

# Create Directory
Write-Host "Creating Directory: $VHDDirectory" -ForegroundColor Cyan
New-Item -ItemType Directory -Path $VHDDirectory -Force

# Create VM (Generation 2, 2GB Memory, 30GB Disk)
Write-Host "Creating Generation 2 Virtual Machine: $VMName" -ForegroundColor Cyan
New-VM -Name $VMName -MemoryStartupBytes $VMMemory -Generation 2 -NewVHDPath $VHDPath -NewVHDSizeBytes $VMSize

# Configure Networking Adapter
Write-Host "Connecting Network Adapter to $SwitchName" -ForegroundColor Cyan
Connect-VMNetworkAdapter -VMName $VMName -SwitchName $SwitchName

# Attach Operating System ISO
Write-Host "Attaching Installation ISO: $ISOPath" -ForegroundColor Cyan
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

# [Added Command] Set UEFI Secure Boot Template for Ubuntu Generation 2 VM
Write-Host "Setting Secure Boot Template to Microsoft UEFI Certificate Authority..." -ForegroundColor Cyan
Set-VMFirmware -VMName $VMName -SecureBootTemplate "MicrosoftUEFICertificateAuthority"

# ------------------------------------------------------------------------------
# Part 3: VM Power Lifecycle Management (Lab 7b)
# ------------------------------------------------------------------------------
# Start the Virtual Machine
Write-Host "Starting Virtual Machine..." -ForegroundColor Cyan
Start-VM -Name $VMName

# Verify VM Status
Write-Host "Current VM Status:" -ForegroundColor Green
Get-VM -Name $VMName

# Stop the Virtual Machine
Write-Host "Stopping Virtual Machine..." -ForegroundColor Yellow
Stop-VM -Name $VMName -Force

# ------------------------------------------------------------------------------
# Part 4: VM Storage Migration (Lab 7b)
# ------------------------------------------------------------------------------
# [Added Command] PowerShell equivalent for Storage Migration
Write-Host "Migrating VM Storage to: $MigrationPath" -ForegroundColor Cyan
New-Item -ItemType Directory -Path $MigrationPath -Force
Move-VMStorage -VMName $VMName -DestinationStoragePath $MigrationPath

Write-Host "Storage migration complete. Verifying new storage path..." -ForegroundColor Green
Get-VHD -VMId (Get-VM -Name $VMName).VMId | Select-Object Path
