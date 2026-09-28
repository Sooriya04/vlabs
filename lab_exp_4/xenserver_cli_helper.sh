#!/usr/bin/env bash
# ==============================================================================
# Script Name: xenserver_cli_helper.sh
# Lab Experiment 4: Citrix XenServer Lifecycle Management and Live Migration Helper
# Description: Automates common 'xe' CLI operations for listing hosts, VMs,
#              templates, storage repositories, and performing live VM migrations.
# ==============================================================================

ACTION="${1:-help}"
PARAM1="$2"
PARAM2="$3"

show_usage() {
    echo "=============================================================="
    echo "  EXPERIMENT 4: Citrix XenServer CLI ('xe') Helper            "
    echo "=============================================================="
    echo "Usage: $0 [command] [arguments]"
    echo ""
    echo "Commands:"
    echo "  hosts                          List all XenServer hosts with UUIDs and IPs"
    echo "  vms                            List all Virtual Machines with power states"
    echo "  templates                      List available OS templates"
    echo "  sr                             List Storage Repositories (SRs)"
    echo "  migrate <VM_UUID> <HOST_UUID>  Execute live migration of VM to destination host"
    echo "  restart-toolstack              Restart XenServer toolstack (xe-toolstack-restart)"
    echo "  info <VM_UUID>                 Show resident host and parameters of a VM"
    echo "=============================================================="
}

case "$ACTION" in
    hosts)
        echo "=== XenServer Host List ==="
        xe host-list params=uuid,name-label,address
        ;;

    vms)
        echo "=== Virtual Machines ==="
        xe vm-list params=uuid,name-label,power-state,resident-on is-control-domain=false
        ;;

    templates)
        echo "=== Available OS Templates ==="
        xe template-list params=uuid,name-label | head -n 30
        ;;

    sr)
        echo "=== Storage Repositories (SR) ==="
        xe sr-list params=uuid,name-label,type,physical-size
        ;;

    migrate)
        VM_UUID="$PARAM1"
        TARGET_HOST_UUID="$PARAM2"
        if [ -z "$VM_UUID" ] || [ -z "$TARGET_HOST_UUID" ]; then
            echo "Error: Missing parameters."
            echo "Usage: $0 migrate <VM_UUID> <TARGET_HOST_UUID>"
            exit 1
        fi
        echo "=== Initiating Live Migration ==="
        echo "Moving VM ($VM_UUID) to Destination Host ($TARGET_HOST_UUID)..."
        xe vm-migrate uuid="$VM_UUID" host-uuid="$TARGET_HOST_UUID"
        echo "SUCCESS: Live migration completed."
        echo "Verifying VM status:"
        xe vm-list uuid="$VM_UUID" params=name-label,resident-on,power-state
        ;;

    info)
        VM_UUID="$PARAM1"
        if [ -z "$VM_UUID" ]; then
            echo "Usage: $0 info <VM_UUID>"
            exit 1
        fi
        xe vm-list uuid="$VM_UUID" params=name-label,resident-on,power-state,VCPUs-number,memory-actual
        ;;

    restart-toolstack)
        echo "Restarting XenServer Toolstack..."
        xe-toolstack-restart
        ;;

    help|*)
        show_usage
        ;;
esac
