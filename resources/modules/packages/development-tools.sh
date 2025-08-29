#!/bin/bash

# =============================================================================
# Development Tools Module - Build tools and development utilities
# =============================================================================

# Install development tools
install_development_tools() {
    yellow_msg 'Installing Development Tools...'
    echo
    
    local dev_packages=(
        # Build tools
        "build-essential"
        "autoconf"
        "automake"
        "libtool"
        "make"
        "pkg-config"
        
        # Version control
        "git"
        
        # Text editors
        "vim"
        "nano"
        
        # File management
        "tree"
        "rsync"
        
        # Archive tools
        "unzip"
        "zip"
        "tar"
        "gzip"
        "bzip2"
        "xz-utils"
        
        # Programming languages
        "python3"
    )
    
    install_package_list "Development Tools" "${dev_packages[@]}"
    
    # Install problematic packages separately with quiet installation
    install_development_packages_quiet
}

# Install development packages that may require interactive prompts
install_development_packages_quiet() {
    local quiet_packages=(
        "python3-pip"
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
