#!/bin/bash

# =============================================================================
# Swap Module - Swap file creation and configuration
# =============================================================================

# Default swap settings
SWAP_PATH="/swapfile"
SWAP_SIZE="2G"

# Create swap file
create_swap() {
    yellow_msg 'Creating SWAP Space...'
    echo
    sleep 0.5

    # Check if swap already exists
    if [ -f "$SWAP_PATH" ]; then
        yellow_msg "Swap file already exists at $SWAP_PATH"
        if ask_confirmation "Do you want to recreate it?"; then
            remove_swap
        else
            green_msg "Using existing swap file"
            return 0
        fi
    fi

    # Create swap file
    fallocate -l "$SWAP_SIZE" "$SWAP_PATH"
    chmod 600 "$SWAP_PATH"
    mkswap "$SWAP_PATH"
    swapon "$SWAP_PATH"
    
    # Add to fstab
    echo "$SWAP_PATH   none    swap    sw    0   0" >> /etc/fstab
    
    echo
    green_msg 'SWAP Created Successfully.'
    echo
    sleep 0.5
}

# Remove existing swap
remove_swap() {
    if [ -f "$SWAP_PATH" ]; then
        swapoff "$SWAP_PATH" 2>/dev/null || true
        rm -f "$SWAP_PATH"
        
        # Remove from fstab
        sed -i "\|$SWAP_PATH|d" /etc/fstab
        
        green_msg "Existing swap file removed"
    fi
}

# Set custom swap size
set_swap_size() {
    local size="$1"
    if [[ "$size" =~ ^[0-9]+[KMG]$ ]]; then
        SWAP_SIZE="$size"
        green_msg "Swap size set to $SWAP_SIZE"
    else
        red_msg "Invalid swap size format. Use format like 2G, 512M, etc."
        return 1
    fi
}

# Main swap setup function (called from main.sh)
setup_swap() {
    yellow_msg 'Setting up Swap File...'
    echo
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        red_msg "This operation requires root privileges"
        return 1
    fi
    
    # Run swap creation
    create_swap
    
    green_msg "Swap setup completed!"
    echo
}
