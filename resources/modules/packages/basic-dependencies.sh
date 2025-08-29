#!/bin/bash

# =============================================================================
# Basic Dependencies Module - Essential packages for script operation
# This module is independent and contains only core dependencies needed
# for the scripts to function properly, not for package management
# =============================================================================

# Check and install basic dependencies (called automatically on startup)
check_and_install_basic_dependencies() {
    yellow_msg 'Checking Basic Dependencies...'
    echo
    
    local basic_packages=(
        "wget"
        "curl"
        "gpg"
        "apt-utils"
        "ca-certificates"
        "virt-what"
        "jq"
        "bc"
        "apt-transport-https"
        "software-properties-common"
    )
    
    local missing_packages=()
    
    # Check which packages are not installed
    for package in "${basic_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii.*$package"; then
            missing_packages+=("$package")
        fi
    done
    
    if [ ${#missing_packages[@]} -eq 0 ]; then
        green_msg "All basic dependencies are already installed"
        return 0
    fi
    
    yellow_msg "Installing missing basic dependencies: ${missing_packages[*]}"
    
    # Update package list quietly
    apt update -qq >/dev/null 2>&1
    
    # Install packages with quiet output
    for package in "${missing_packages[@]}"; do
        yellow_msg "Installing $package..."
        
        # Special handling for jq package
        if [ "$package" = "jq" ]; then
            # Install jq with quiet output and non-interactive mode
            export DEBIAN_FRONTEND=noninteractive
            if apt install -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$package" >/dev/null; then
                green_msg "✅ $package installed successfully"
            else
                red_msg "❌ Failed to install $package"
                unset DEBIAN_FRONTEND
                return 1
            fi
            unset DEBIAN_FRONTEND
        else
            # Install other packages normally
            if apt install -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$package" >/dev/null; then
                green_msg "✅ $package installed successfully"
            else
                red_msg "❌ Failed to install $package"
                return 1
            fi
        fi
    done
    
    green_msg "Basic dependencies installation completed!"
    
    echo
    
    # Check and install KVM VM dependencies if applicable
    install_kvm_dependencies
}

# Install KVM VM dependencies (qemu-agent)
install_kvm_dependencies() {
    yellow_msg 'Checking KVM VM Dependencies...'
    echo
    
    # Check if running in KVM VM
    if is_kvm_vm; then
        yellow_msg "KVM VM detected, installing qemu-guest-agent..."
        
        if check_package_installed "qemu-guest-agent"; then
            green_msg "qemu-guest-agent already installed"
        else
            yellow_msg "Installing qemu-guest-agent..."
            
            # Install with quiet output but keep stderr for error diagnosis
            if apt install -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" qemu-guest-agent >/dev/null; then
                green_msg "✅ qemu-guest-agent installed successfully"
                
                # Enable and start qemu-guest-agent service
                enable_services "qemu-guest-agent"
            else
                red_msg "❌ Failed to install qemu-guest-agent"
                return 1
            fi
        fi
    else
        blue_msg "Not running in KVM VM, skipping qemu-agent installation"
    fi
    
    echo
}
