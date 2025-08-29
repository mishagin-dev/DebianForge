#!/bin/bash

# =============================================================================
# UFW Firewall Module - Firewall configuration and optimization
# =============================================================================

# Configuration is loaded centrally in main.sh

# Optimize UFW firewall configuration
optimize_ufw() {
    yellow_msg 'Optimizing UFW Firewall Configuration...'
    echo
    sleep 0.5

    # Check and install UFW dependencies
    if ! check_and_install_ufw_deps; then
        red_msg "Failed to install UFW dependencies. Exiting."
        return 1
    fi

    # Get UFW configuration
    local ufw_mode=$(get_ufw_config "mode")
    local ufw_ports=$(get_ufw_config "allow_ports")
    local disable_ipv6=$(get_ufw_config "disable_ipv6")
    
    # Configure UFW based on mode
    case "$ufw_mode" in
        "standard")
            configure_ufw_standard "$ufw_ports" "$disable_ipv6"
            ;;
        "strict")
            configure_ufw_strict "$ufw_ports" "$disable_ipv6"
            ;;
        "custom")
            configure_ufw_custom "$ufw_ports" "$disable_ipv6"
            ;;
        *)
            red_msg "Unknown UFW mode: $ufw_mode"
            return 1
            ;;
    esac
    
    green_msg "UFW firewall optimization completed!"
    echo
    
    # Enable and start UFW service
    yellow_msg "Enabling and starting UFW service..."
    if enable_services "ufw"; then
        green_msg "✅ UFW service enabled and started successfully"
    else
        red_msg "❌ Failed to enable/start UFW service"
    fi
    
    echo
    sleep 0.5
}

# Configure UFW in standard mode
configure_ufw_standard() {
    yellow_msg "Configuring UFW in STANDARD mode..."
    
    # Standard mode - basic security without extreme restrictions
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow established connections
    ufw allow out on any from any to any established
    ufw allow in on any from any to any established
    ufw allow out on any from any to any related
    ufw allow in on any from any to any related
    
    # Allow loopback
    ufw allow in on lo
    ufw allow out on lo
    
    green_msg "UFW configured in STANDARD mode"
}

# Configure UFW in strict mode
configure_ufw_strict() {
    yellow_msg "Configuring UFW in STRICT mode..."
    
    # Strict mode - maximum security with detailed rules
    ufw default deny incoming
    ufw default deny outgoing
    
    # Allow established connections
    ufw allow out on any from any to any established
    ufw allow in on any from any to any established
    ufw allow out on any from any to any related
    ufw allow in on any from any to any related
    
    # Allow loopback
    ufw allow in on lo
    ufw allow out on lo
    
    # Allow ICMP for network diagnostics
    ufw allow in proto icmp type echo-request
    ufw allow in proto icmp type echo-reply
    ufw allow in proto icmp type destination-unreachable
    ufw allow in proto icmp type time-exceeded
    
    # Allow outgoing connections from server
    ufw allow out on any
    
    green_msg "UFW configured in STRICT mode"
}

# Show UFW status
show_ufw_status() {
    yellow_msg 'UFW Status:'
    echo
    ufw status verbose numbered
    echo
}

# Show UFW rules
show_ufw_rules() {
    yellow_msg 'UFW Rules:'
    echo
    ufw status numbered
    echo
}

# Reset UFW to defaults
reset_ufw() {
    if ask_confirmation "Reset UFW to default settings? This will remove all custom rules."; then
        yellow_msg 'Resetting UFW...'
        ufw --force reset
        green_msg "UFW reset to defaults"
    fi
}

# Configure UFW with custom settings
configure_ufw_custom() {
    yellow_msg 'Configuring UFW with custom settings...'
    echo
    
    # Ask for IPv6 settings
    if ask_confirmation "Disable IPv6 (affects both UFW and system)?"; then
        update_config "DISABLE_IPV6" "true"
        green_msg "IPv6 will be disabled in UFW and system"
    else
        update_config "DISABLE_IPV6" "false"
        green_msg "IPv6 will remain enabled"
    fi
    
    # Ask for strict mode
    if ask_confirmation "Enable strict security mode (more restrictive)?"; then
        update_config "UFW_MODE" "strict"
        green_msg "Strict security mode enabled"
    else
        update_config "UFW_MODE" "standard"
        green_msg "Standard security mode enabled"
    fi
    
    # Configure UFW with selected settings
    optimize_ufw
}
