#!/bin/bash

# =============================================================================
# Packages Module - Unified package management system
# =============================================================================

# Configuration is loaded centrally in main.sh

# Load utils for common functions first
source "resources/modules/optimize/utils.sh"

# Load all package modules
source "resources/modules/packages/basic-dependencies.sh"
source "resources/modules/packages/system-utilities.sh"
source "resources/modules/packages/development-tools.sh"
source "resources/modules/packages/monitoring-tools.sh"
source "resources/modules/packages/security-tools.sh"
source "resources/modules/packages/network-tools.sh"
source "resources/modules/packages/additional-libraries.sh"
source "resources/modules/packages/automation-tools.sh"

# Check if package is installed
check_package_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii.*$package"
}

# Install package list with error handling
install_package_list() {
    local category="$1"
    shift
    local packages=("$@")
    
    local missing_packages=()
    
    # Check which packages are not installed
    for package in "${packages[@]}"; do
        if ! check_package_installed "$package"; then
            missing_packages+=("$package")
        fi
    done
    
    if [ ${#missing_packages[@]} -eq 0 ]; then
        green_msg "All $category packages are already installed"
        return 0
    fi
    
    yellow_msg "Installing missing $category packages: ${missing_packages[*]}"
    
    # Update package list quietly
    apt update -qq >/dev/null 2>&1
    
    # Install packages with quiet output
    for package in "${missing_packages[@]}"; do
        yellow_msg "Installing $package..."
        
        # Install with quiet output but keep stderr for error diagnosis
        if apt install -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$package" >/dev/null; then
            green_msg "✅ $package installed successfully"
        else
            red_msg "❌ Failed to install $package"
            return 1
        fi
    done
    
    green_msg "$category packages installation completed!"
}

# Install recommended software
install_recommended_software() {
    yellow_msg 'Installing Recommended Software...'
    echo
    sleep 0.5

    # Install system utilities
    install_system_utilities
    
    # Install development tools
    install_development_tools
    
    # Install monitoring tools
    install_monitoring_tools
    
    # Install security tools
    install_security_tools
    
    # Install network tools
    install_network_tools
    
    # Install automation tools
    install_automation_tools
    
    # Install additional libraries
    install_additional_libraries
    
    green_msg 'Recommended software installation completed!'
    echo
    sleep 0.5
}

# Show installed recommended software
show_installed_recommended() {
    yellow_msg 'Installed Recommended Software:'
    echo
    
    echo "System Utilities:"
    show_package_status "bash-completion" "busybox" "cron" "gnupg2" "tmux" "unattended-upgrades" "locales"
    
    echo
    echo "Development Tools:"
    show_package_status "build-essential" "git" "vim" "nano" "tree" "autoconf" "automake" "python3" "python3-pip"
    
    echo
    echo "Monitoring Tools:"
    show_package_status "htop" "iotop" "ncdu" "nethogs" "iftop" "nload" "vnstat" "sysstat" "logwatch"
    
    echo
    echo "Security Tools:"
    show_package_status "fail2ban" "chkrootkit" "lynis" "clamav" "clamav-daemon" "rkhunter" "tripwire" "aide"
    
    echo
    echo "Network Tools:"
    show_package_status "net-tools" "iproute2" "nmap" "netcat" "traceroute" "mtr" "dig" "iperf3"
    
    echo
    echo "Additional Libraries:"
    show_package_status "bc" "binutils" "haveged" "jq" "libsodium-dev" "libssl-dev" "socat"
    
    echo
    echo "Automation Tools:"
    show_package_status "tmux" "unattended-upgrades"
    
    echo
}



# Show package installation status
show_package_status() {
    for package in "$@"; do
        if check_package_installed "$package"; then
            echo "  ✅ $package"
        else
            echo "  ❌ $package"
        fi
    done
}
