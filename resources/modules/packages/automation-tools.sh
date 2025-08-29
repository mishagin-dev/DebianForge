#!/bin/bash

# =============================================================================
# Automation Tools Module - Automation and configuration utilities
# =============================================================================

# Install automation tools
install_automation_tools() {
    yellow_msg 'Installing Automation Tools...'
    echo
    
    local automation_packages=(
        # Terminal multiplexer
        "tmux"
        
        # Unattended upgrades
        "unattended-upgrades"
    )
    
    install_package_list "Automation Tools" "${automation_packages[@]}"
    
    # Configure unattended-upgrades after installation
    configure_unattended_upgrades
    
    # Configure tmux after installation
    configure_tmux
    
    # Configure mc after installation
    configure_mc
}

# Configure Midnight Commander (mc)
configure_mc() {
    yellow_msg 'Configuring Midnight Commander...'
    echo
    
    # Copy sh.syntax to unknown.syntax for better file highlighting
    if [ -f "/usr/share/mc/syntax/sh.syntax" ]; then
        cp "/usr/share/mc/syntax/sh.syntax" "/usr/share/mc/syntax/unknown.syntax"
        green_msg "MC syntax configuration updated"
    else
        yellow_msg "MC syntax files not found, skipping syntax configuration"
    fi
    
    green_msg "Midnight Commander configured"
    echo
}

# Configure tmux
configure_tmux() {
    yellow_msg 'Configuring TMUX...'
    echo
    
    # Create tmux configuration directory
    mkdir -p /etc/tmux
    
    # Copy tmux configuration from config file
    local tmux_config="resources/config/packages/tmux.conf"
    
    if [ -f "$tmux_config" ]; then
        cp "$tmux_config" "/etc/tmux/tmux.conf"
        green_msg "TMUX configuration copied from: $tmux_config"
    else
        red_msg "TMUX configuration file not found: $tmux_config"
        return 1
    fi
    
    # Create user tmux configuration directory
    mkdir -p /etc/skel/.tmux
    
    # Copy configuration to user template
    cp "/etc/tmux/tmux.conf" "/etc/skel/.tmux/tmux.conf"
    
    green_msg "TMUX configured globally and for new users"
    echo
    
    # Note: tmux is not a systemd service, so no need to enable/start
}

# Configure unattended-upgrades
configure_unattended_upgrades() {
    yellow_msg 'Configuring Unattended-Upgrades...'
    echo
    
    # Create backup of original configuration
    if [ -f "/etc/apt/apt.conf.d/50-unattended-upgrades" ]; then
        cp "/etc/apt/apt.conf.d/50-unattended-upgrades" "/etc/apt/apt.conf.d/50-unattended-upgrades.bak"
        green_msg "Backup created: /etc/apt/apt.conf.d/50-unattended-upgrades.bak"
    fi
    
    # Copy unattended-upgrades configuration from config file
    local unattended_config="resources/config/packages/unattended-upgrades.conf"
    
    if [ -f "$unattended_config" ]; then
        cp "$unattended_config" "/etc/apt/apt.conf.d/50-unattended-upgrades"
        green_msg "Unattended-upgrades configuration copied from: $unattended_config"
    else
        red_msg "Unattended-upgrades configuration file not found: $unattended_config"
        return 1
    fi
    
    # Enable unattended-upgrades service
    enable_services "unattended-upgrades"
    
    green_msg "Unattended-upgrades configured and enabled"
    echo
}
