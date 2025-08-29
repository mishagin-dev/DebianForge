#!/bin/bash

# =============================================================================
# System Packages Module - Unified package management for system modules
# =============================================================================

# Configuration is loaded centrally in main.sh

# Source all package modules
source "lib/core.sh"
source "lib/packages.sh"

# Additional system-specific package functions
install_system_packages() {
    yellow_msg 'Installing System Packages...'
    echo
    
    # Install all package types
    install_basic_dependencies
    install_system_utilities
    install_development_tools
    install_monitoring_tools
    install_network_tools
    install_additional_libraries
    install_automation_tools
    install_security_tools
    
    green_msg "System packages installation completed!"
}

# Show system packages status
show_system_packages_status() {
    yellow_msg 'System Packages Status:'
    echo
    
    # Show status for each package category
    show_basic_dependencies_status
    show_system_utilities_status
    show_development_tools_status
    show_monitoring_tools_status
    show_network_tools_status
    show_additional_libraries_status
    show_automation_tools_status
    show_security_tools_status
    
    echo
}

# Main function to run system packages setup
run_system_packages_setup() {
    yellow_msg 'Starting System Packages Setup...'
    echo
    
    # Install packages
    install_system_packages
    
    # Show status
    show_system_packages_status
    
    green_msg "System packages setup completed successfully!"
}
