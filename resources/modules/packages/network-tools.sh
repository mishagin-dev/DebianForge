#!/bin/bash

# =============================================================================
# Network Tools Module - Network utilities and diagnostics
# =============================================================================

# Install network tools
install_network_tools() {
    yellow_msg 'Installing Network Tools...'
    echo
    
    local network_packages=(
        # Network utilities
        "net-tools"
        "iproute2"
        
        # Network scanning
        "nmap"
        
        # Network diagnostics
        "telnet"
        "traceroute"
        "mtr"
        
        # DNS tools
        "whois"
        
        # Web tools
        # curl and wget are installed automatically in dependencies.sh
        
        # Network testing
        "speedtest-cli"
    )
    
    install_package_list "Network Tools" "${network_packages[@]}"
    
    # Install iperf3 separately to avoid interactive prompts
    install_iperf3_quiet
}

# Install iperf3 without interactive prompts
install_iperf3_quiet() {
    if ! check_package_installed "iperf3"; then
        yellow_msg "Installing iperf3 (quiet mode)..."
        
        # Set environment variable to disable interactive prompts
        export DEBIAN_FRONTEND=noninteractive
        
        # Install with quiet output and force non-interactive mode
        # Install with quiet output but keep stderr for error diagnosis
        if apt install -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" iperf3 >/dev/null; then
            green_msg "✅ iperf3 installed successfully (quiet mode)"
        else
            red_msg "❌ Failed to install iperf3"
        fi
        
        # Reset environment variable
        unset DEBIAN_FRONTEND
    else
        green_msg "iperf3 already installed"
    fi
}
