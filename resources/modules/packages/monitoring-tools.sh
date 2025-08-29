#!/bin/bash

# =============================================================================
# Monitoring Tools Module - System and network monitoring utilities
# =============================================================================

# Install monitoring tools
install_monitoring_tools() {
    yellow_msg 'Installing Monitoring Tools...'
    echo
    
    local monitoring_packages=(
        # System monitoring
        "htop"
        "iotop"
        "ncdu"
        
        # Network monitoring
        "nethogs"
        "iftop"
        "nload"
        "vnstat"
        
        # Performance monitoring
        "dstat"
        "glances"
    )
    
    install_package_list "Monitoring Tools" "${monitoring_packages[@]}"
    
    # Install problematic packages separately with quiet installation
    install_monitoring_packages_quiet
}

# Install monitoring packages that may require interactive prompts
install_monitoring_packages_quiet() {
    local quiet_packages=(
        "sysstat"
        "logwatch"
    )
    
    for package in "${quiet_packages[@]}"; do
        if ! check_package_installed "$package"; then
            yellow_msg "Installing $package (quiet mode)..."
            
            # Set environment variable to disable interactive prompts
            export DEBIAN_FRONTEND=noninteractive
            
            # Install with quiet output and force non-interactive mode
            # Install with quiet output but keep stderr for error diagnosis
            if apt install -qq -y -o Dpkg::Options::="--force-confold" "$package" >/dev/null; then
                green_msg "✅ $package installed successfully (quiet mode)"
            else
                red_msg "❌ Failed to install $package"
            fi
            
            # Reset environment variable
            unset DEBIAN_FRONTEND
        else
            green_msg "$package already installed"
        fi
    done
}
