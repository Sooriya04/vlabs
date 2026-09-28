#!/usr/bin/env bash
# ==============================================================================
# Script Name: vbox_cold_migration.sh
# Lab Experiment 3: Cold Migration of Virtual Machines via OVA Export and Import
# Description: Automates test file preparation in guest OS, and provides CLI
#              helpers for VBoxManage export and import of virtual appliances.
# ==============================================================================

ACTION="${1:-help}"
VM_NAME="${2:-sooriya}"
OUTPUT_PATH="${3:-./sooriya.ova}"

show_usage() {
    echo "=============================================================="
    echo "  EXPERIMENT 3: VirtualBox Cold Migration Helper (OVA)        "
    echo "=============================================================="
    echo "Usage: $0 [prepare-guest | export | import | status] [options]"
    echo ""
    echo "Commands:"
    echo "  prepare-guest               Create test directory and file inside guest VM"
    echo "  export [VM_NAME] [OUTPUT]   Power off and export VM to OVA appliance package"
    echo "  import [OVA_FILE] [VM_NAME] Import OVA appliance as a new VM instance"
    echo "  status                      List registered VirtualBox VMs"
    echo ""
    echo "Examples:"
    echo "  $0 prepare-guest"
    echo "  $0 export sooriya ./sooriya.ova"
    echo "  $0 import ./sooriya.ova sooriya1"
    echo "=============================================================="
}

case "$ACTION" in
    prepare-guest)
        echo "=== [Phase 1] Preparing Test Data Inside Guest OS ==="
        mkdir -p "$HOME/sooriya"
        echo "Test Data for Migration - Generated $(date)" > "$HOME/sooriya/file.txt"
        echo "[*] Test file created at $HOME/sooriya/file.txt:"
        cat "$HOME/sooriya/file.txt"
        echo ""
        echo "Guest preparation complete. Now shut down the VM cleanly before exporting."
        ;;

    export)
        TARGET_VM="$VM_NAME"
        TARGET_OVA="$OUTPUT_PATH"
        echo "=== [Phase 2] Exporting VM '$TARGET_VM' to OVA appliance ==="
        
        if ! command -v VBoxManage &>/dev/null; then
            echo "Error: VBoxManage not found in PATH. Ensure Oracle VirtualBox is installed."
            exit 1
        fi
        
        echo "[*] Checking if VM '$TARGET_VM' is running..."
        if VBoxManage list runningvms | grep -q "\"$TARGET_VM\""; then
            echo "[*] Sending graceful ACPI shutdown signal..."
            VBoxManage controlvm "$TARGET_VM" acpipoweroff
            echo "Waiting for VM to power off completely..."
            sleep 5
        fi
        
        echo "[*] Exporting '$TARGET_VM' to '$TARGET_OVA' with manifest..."
        VBoxManage export "$TARGET_VM" --output "$TARGET_OVA" --ovf10 --manifest
        echo "SUCCESS: Export completed. File saved at: $TARGET_OVA"
        ls -lh "$TARGET_OVA"
        ;;

    import)
        OVA_INPUT="$VM_NAME"
        NEW_VM_NAME="${3:-sooriya1}"
        echo "=== [Phase 4] Importing OVA appliance '$OVA_INPUT' as '$NEW_VM_NAME' ==="
        
        if ! command -v VBoxManage &>/dev/null; then
            echo "Error: VBoxManage not found in PATH."
            exit 1
        fi
        
        if [ ! -f "$OVA_INPUT" ]; then
            echo "Error: OVA file '$OVA_INPUT' not found!"
            exit 1
        fi
        
        echo "[*] Importing appliance..."
        VBoxManage import "$OVA_INPUT" --vsys 0 --vmname "$NEW_VM_NAME"
        echo "SUCCESS: VM '$NEW_VM_NAME' successfully imported."
        echo "To launch the imported VM: VBoxManage startvm \"$NEW_VM_NAME\""
        ;;

    status)
        echo "=== VirtualBox Registered VMs ==="
        if command -v VBoxManage &>/dev/null; then
            VBoxManage list vms
            echo ""
            echo "=== Running VMs ==="
            VBoxManage list runningvms
        else
            echo "VBoxManage not found in PATH."
        fi
        ;;

    help|*)
        show_usage
        ;;
esac
