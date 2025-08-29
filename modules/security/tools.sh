#!/bin/bash

# =============================================================================
# Security Tools Module - Security and intrusion detection utilities
# =============================================================================

# Install security tools
install_security_tools() {
    yellow_msg 'Installing Security Tools...'
    echo
    
    local security_packages=(
        # Intrusion detection
        "fail2ban"
        "psad"
        
        # Rootkit detection
        "chkrootkit"
        "unhide"
        
        # Security auditing
        "lynis"
        "auditd"
        "audispd-plugins"
        "python3-audit"
        
        # Network security
        "arpwatch"
        "tcpdump"
        
        # Additional security tools
        "tripwire"
        "aide"
    )
    
    install_package_list "Security Tools" "${security_packages[@]}"
    
    # Install problematic packages separately with quiet installation
    install_security_packages_quiet
    
    # Enable and start security services
    yellow_msg "Enabling and starting security services..."
    
    # Enable auditd service
    if check_package_installed "auditd"; then
        if enable_services "auditd"; then
            green_msg "✅ Auditd service enabled and started successfully"
        else
            red_msg "❌ Failed to enable/start auditd service"
        fi
    fi
    
    # Enable fail2ban service
    if check_package_installed "fail2ban"; then
        if enable_services "fail2ban"; then
            green_msg "✅ Fail2ban service enabled and started successfully"
        else
            red_msg "❌ Failed to enable/start fail2ban service"
        fi
    fi
}

# Install security packages that may require interactive prompts
install_security_packages_quiet() {
    local quiet_packages=(
        "clamav"
        "clamav-daemon"
        "rkhunter"
        "tripwire"
        "aide"
        "auditd"
        "audispd-plugins"
        "python3-audit"
    )
    
    for package in "${quiet_packages[@]}"; do
        if ! check_package_installed "$package"; then
            yellow_msg "Installing $package (quiet mode)..."
            
            # Use universal quiet installation method
            if install_package_quiet "$package" "$package" "true"; then
                # Apply configuration if available
                apply_security_package_config "$package"
            fi
        else
            green_msg "$package already installed"
        fi
    done
}

# Apply configuration for security packages
apply_security_package_config() {
    local package="$1"
    
    case "$package" in
        "clamav"|"clamav-daemon")
            yellow_msg "Applying ClamAV configuration..."
            if [ -f "resources/config/packages/clamav.conf" ]; then
                cp "resources/config/packages/clamav.conf" "/etc/clamav/clamd.conf"
                green_msg "✅ ClamAV configuration applied"
            fi
            ;;
        "rkhunter")
            yellow_msg "Applying RKHunter configuration..."
            if [ -f "resources/config/packages/rkhunter.conf" ]; then
                cp "resources/config/packages/rkhunter.conf" "/etc/rkhunter.conf"
                green_msg "✅ RKHunter configuration applied"
            fi
            ;;
        "fail2ban")
            yellow_msg "Applying Fail2ban configuration..."
            if [ -f "resources/config/packages/fail2ban.conf" ]; then
                cp "resources/config/packages/fail2ban.conf" "/etc/fail2ban/jail.local"
                green_msg "✅ Fail2ban configuration applied"
            fi
            ;;
        "auditd"|"audispd-plugins"|"python3-audit")
            yellow_msg "Applying Audit configuration..."
            if [ -f "resources/config/packages/auditd.conf" ]; then
                cp "resources/config/packages/auditd.conf" "/etc/audit/auditd.conf"
                green_msg "✅ Audit configuration applied"
            fi
            ;;
    esac
}
