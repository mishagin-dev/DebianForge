#!/bin/bash

# =============================================================================
# Utils Module - Common functions for DebianForge
# =============================================================================

# Color message functions
green_msg() {
    tput setaf 2
    echo "[*] ----- $1"
    tput sgr0
}

yellow_msg() {
    tput setaf 3
    echo "[*] ----- $1"
    tput sgr0
}

red_msg() {
    tput setaf 1
    echo "[*] ----- $1"
    tput sgr0
}

blue_msg() {
    tput setaf 4
    echo "[*] ----- $1"
    tput sgr0
}

# Check if running as root
check_root() {
    if [[ "$EUID" -ne '0' ]]; then
        red_msg 'Error: You must run this script as root!'
        echo
        sleep 0.5
        exit 1
    fi
}

# Create backup of a file
create_backup() {
    local file="$1"
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$file" ]; then
        cp "$file" "$backup"
        echo "$backup"
    else
        echo ""
    fi
}

# Ask user for confirmation
ask_confirmation() {
    local message="$1"
    local default="${2:-n}"
    
    echo
    yellow_msg "$message (y/n)"
    echo
    
    while true; do
        read -p "Enter your choice: " choice
        echo
        
        case $choice in
            [yY]|[yY][eE][sS])
                return 0
                ;;
            [nN]|[nN][oO])
                return 1
                ;;
            "")
                if [[ "$default" == "y" ]]; then
                    return 0
                else
                    return 1
                fi
                ;;
            *)
                red_msg 'Invalid input! Please enter y or n.'
                ;;
        esac
    done
}

# Enable and start system services
enable_services() {
    local services=("$@")
    
    yellow_msg 'Enabling and starting system services...'
    echo
    
    for service in "${services[@]}"; do
        if systemctl is-enabled --quiet "$service" 2>/dev/null; then
            green_msg "Service $service is already enabled"
        else
            if systemctl enable "$service" 2>/dev/null; then
                green_msg "Service $service enabled successfully"
            else
                red_msg "Failed to enable service $service"
                continue
            fi
        fi
        
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            green_msg "Service $service is already running"
        else
            if systemctl start "$service" 2>/dev/null; then
                green_msg "Service $service started successfully"
            else
                red_msg "Failed to start service $service"
            fi
        fi
        echo
    done
    
    green_msg 'Services configuration completed!'
    echo
}

# Check if running in KVM VM
is_kvm_vm() {
    # Use virt-what to detect hypervisor
    if command -v virt-what >/dev/null 2>&1; then
        local hypervisor=$(virt-what 2>/dev/null | head -n1)
        if [ "$hypervisor" = "kvm" ]; then
            return 0  # Success - is KVM VM
        fi
    fi
    return 1  # Failure - not KVM VM
}

# Ask for reboot
ask_reboot() {
    yellow_msg 'Reboot now? (RECOMMENDED) (y/n)'
    echo
    
    while true; do
        read -p "Enter your choice: " choice
        echo
        
        case $choice in
            [yY]|[yY][eE][sS])
                sleep 0.5
                reboot
                exit 0
                ;;
            [nN]|[nN][oO])
                break
                ;;
            *)
                red_msg 'Invalid input! Please enter y or n.'
                ;;
        esac
    done
}

# Wait for user input to continue
wait_for_enter() {
    echo
    read -p 'Press Enter to continue...'
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install package if not exists
ensure_package() {
    local package="$1"
    
    if ! command_exists "$package"; then
        yellow_msg "Installing $package..."
        apt update -q && apt install -y "$package"
    fi
}

# Universal quiet package installation method
install_package_quiet() {
    local package="$1"
    local description="${2:-$package}"
    local requires_config="${3:-false}"
    
    if [ -z "$package" ]; then
        red_msg "Package name is required"
        return 1
    fi
    
    # Check if package is already installed
    if check_package_installed "$package"; then
        green_msg "$description already installed"
        if [ "$requires_config" = "true" ]; then
            yellow_msg "⚠️  Note: $description may require additional configuration"
        fi
        return 0
    fi
    
    yellow_msg "Installing $description (quiet mode)..."
    
    # Set environment variable to disable interactive prompts
    export DEBIAN_FRONTEND=noninteractive
    
    # Install with quiet output but keep stderr for error diagnosis
    if apt install -qq -y -o Dpkg::Options::="--force-confold" "$package" >/dev/null; then
        green_msg "✅ $description installed successfully (quiet mode)"
        if [ "$requires_config" = "true" ]; then
            yellow_msg "⚠️  Important: $description requires additional configuration for optimal use"
        fi
        unset DEBIAN_FRONTEND
        return 0
    else
        red_msg "❌ Failed to install $description"
        unset DEBIAN_FRONTEND
        return 1
    fi
}

# Universal quiet package list installation method
install_package_list_quiet() {
    local packages=("$@")
    local failed_packages=()
    
    if [ ${#packages[@]} -eq 0 ]; then
        red_msg "No packages specified for installation"
        return 1
    fi
    
    yellow_msg "Installing ${#packages[@]} packages in quiet mode..."
    
    # Set environment variable to disable interactive prompts
    export DEBIAN_FRONTEND=noninteractive
    
    for package in "${packages[@]}"; do
        if ! install_package_quiet "$package"; then
            failed_packages+=("$package")
        fi
    done
    
    # Reset environment variable
    unset DEBIAN_FRONTEND
    
    # Report results
    if [ ${#failed_packages[@]} -eq 0 ]; then
        green_msg "✅ All packages installed successfully!"
        return 0
    else
        red_msg "❌ Failed to install ${#failed_packages[@]} packages: ${failed_packages[*]}"
        return 1
    fi
}

# Install packages that require configuration with warnings
install_packages_with_config_warnings() {
    local packages=("$@")
    local failed_packages=()
    
    if [ ${#packages[@]} -eq 0 ]; then
        red_msg "No packages specified for installation"
        return 1
    fi
    
    yellow_msg "Installing ${#packages[@]} packages (some require configuration)..."
    
    for package in "${packages[@]}"; do
        if ! install_package_quiet "$package" "$package" "true"; then
            failed_packages+=("$package")
        fi
    done
    
    # Report results
    if [ ${#failed_packages[@]} -eq 0 ]; then
        green_msg "✅ All packages installed successfully!"
        yellow_msg "⚠️  Some packages require additional configuration for optimal use"
        return 0
    else
        red_msg "❌ Failed to install ${#failed_packages[@]} packages: ${failed_packages[*]}"
        return 1
    fi
}
