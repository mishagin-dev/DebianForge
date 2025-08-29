#!/bin/bash

# =============================================================================
# System Update Module - Complete system update and cleanup
# =============================================================================

# Complete system update and cleanup
complete_update() {
    yellow_msg 'Updating the System... (This can take a while.)'
    echo
    sleep 0.5

    # Check if apt is available
    if ! command -v apt >/dev/null 2>&1; then
        red_msg "❌ Error: apt command not found. This system may not be Debian/Ubuntu based."
        return 1
    fi

    # First update cycle
    yellow_msg "Updating package lists..."
    apt update -qq >/dev/null 2>&1
    
    yellow_msg "Checking for available upgrades..."
    local upgrade_count=$(apt list --upgradable 2>/dev/null | grep -v "^WARNING:" | grep -c "upgradable" || echo "0")
    
    # Ensure upgrade_count is a valid number
    if [[ ! "$upgrade_count" =~ ^[0-9]+$ ]]; then
        upgrade_count=0
    fi
    
    if [ "$upgrade_count" -gt 0 ]; then
        yellow_msg "Found $upgrade_count packages to upgrade"
        apt upgrade -qq -y >/dev/null 2>&1
        green_msg "✅ System packages upgraded ($upgrade_count packages)"
    else
        green_msg "✅ All packages are up to date"
    fi
    
    yellow_msg "Checking for full upgrades..."
    apt full-upgrade -qq -y >/dev/null 2>&1
    
    yellow_msg "Cleaning up old packages..."
    apt autoremove -qq -y >/dev/null 2>&1
    sleep 0.5

    # Second update cycle for thorough cleanup
    yellow_msg "Performing thorough cleanup..."
    apt autoclean -qq -y >/dev/null 2>&1
    apt clean -qq -y >/dev/null 2>&1
    
    yellow_msg "Final package list update..."
    apt update -qq >/dev/null 2>&1
    
    yellow_msg "Final upgrade check..."
    apt upgrade -qq -y >/dev/null 2>&1
    apt full-upgrade -qq -y >/dev/null 2>&1
    
    yellow_msg "Final cleanup..."
    apt autoremove --purge -qq -y >/dev/null 2>&1

    # Show final statistics
    echo
    yellow_msg "Final system status:"
    local final_upgrade_count=$(apt list --upgradable 2>/dev/null | grep -v "^WARNING:" | grep -c "upgradable" || echo "0")
    
    # Ensure final_upgrade_count is a valid number
    if [[ ! "$final_upgrade_count" =~ ^[0-9]+$ ]]; then
        final_upgrade_count=0
    fi
    
    if [ "$final_upgrade_count" -eq 0 ]; then
        green_msg "✅ System is fully up to date"
    else
        yellow_msg "⚠️  $final_upgrade_count packages still available for upgrade"
    fi
    
    echo
    green_msg 'System Updated & Cleaned Successfully.'
    echo
    sleep 0.5
}

# Main system update function (called from main.sh)
update_system() {
    yellow_msg 'Running System Update and Upgrade...'
    echo
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        red_msg "This operation requires root privileges"
        return 1
    fi
    
    # Run complete update
    complete_update
    
    echo
}
