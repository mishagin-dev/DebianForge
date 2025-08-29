#!/bin/bash

# =============================================================================
# System Utilities Module - Essential system tools and optimization packages
# =============================================================================

# Install system utilities
install_system_utilities() {
    yellow_msg 'Installing System Utilities...'
    echo
    
    local system_packages=(
        # Package management
        "apt-transport-https"
        
        # System tools
        "bash-completion"
        "busybox"
        "cron"
        "gnupg2"
        "lsb-release"
        "screen"
        "tmux"
        
        # System optimization
        "haveged"
        "preload"
        
        # Basic utilities
        "dialog"
        "xxd"
        "mc"
    )
    
    install_package_list "System Utilities" "${system_packages[@]}"
    
    # Install problematic packages separately with quiet installation
    install_system_packages_quiet
    
    # Enable optimization services after installation
    local optimization_services=()
    
    if check_package_installed "haveged"; then
        optimization_services+=("haveged")
    fi
    
    if check_package_installed "preload"; then
        optimization_services+=("preload")
    fi
    
    if [ ${#optimization_services[@]} -gt 0 ]; then
        enable_services "${optimization_services[@]}"
    fi
}

# Install system packages that may require interactive prompts
install_system_packages_quiet() {
    local quiet_packages=(
        "unattended-upgrades"
        "locales"
    )
    
    for package in "${quiet_packages[@]}"; do
        if ! check_package_installed "$package"; then
            yellow_msg "Installing $package (quiet mode)..."
            
            # Use universal quiet installation method
            if install_package_quiet "$package" "$package" "true"; then
                # Apply configuration if available
                apply_system_package_config "$package"
            fi
        else
            green_msg "$package already installed"
        fi
    done
}

# Apply configuration for system packages
apply_system_package_config() {
    local package="$1"
    
    case "$package" in
        "locales")
            yellow_msg "Applying locales configuration..."
            if [ -f "resources/config/packages/locales.conf" ]; then
                # Generate locales based on configuration
                yellow_msg "Generating system locales..."
                locale-gen en_US.UTF-8
                locale-gen ru_RU.UTF-8
                update-locale LANG=en_US.UTF-8
                green_msg "✅ Locales configuration applied"
            fi
            ;;
        "unattended-upgrades")
            yellow_msg "Applying unattended-upgrades configuration..."
            if [ -f "resources/config/packages/unattended-upgrades.conf" ]; then
                cp "resources/config/packages/unattended-upgrades.conf" "/etc/apt/apt.conf.d/50-unattended-upgrades"
                green_msg "✅ Unattended-upgrades configuration applied"
            fi
            ;;
    esac
}
