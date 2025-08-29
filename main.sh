#!/bin/bash

# =============================================================================
# DebianForge - Main Entry Point
# =============================================================================
# Copyright (c) 2025 Alexander Mishagin
# 
# This script is the ONLY entry point for all project functionality.
# Individual module scripts cannot be executed directly for security reasons.
# All operations must go through this centralized interface.
# =============================================================================

# Source core libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/core.sh" 2>/dev/null || {
    echo "Error: Core library not found. Please run from project root."
    exit 1
}

# =============================================================================
# Configuration
# =============================================================================
PROJECT_NAME="DEBIANFORGE"
PROJECT_VERSION="1.0"
PROJECT_DESCRIPTION="Comprehensive Debian System Optimization & Security Toolkit"

# =============================================================================
# Security Check - Prevent Direct Module Execution
# =============================================================================
check_execution_security() {
    local caller_script="${BASH_SOURCE[1]}"
    if [[ "$caller_script" != "" && "$caller_script" != "$0" ]]; then
        echo "Error: Direct execution of module scripts is not allowed."
        echo "All functionality must be accessed through main.sh"
        echo "Usage: ./main.sh [module] [action] [parameters]"
        exit 1
    fi
}

# =============================================================================
# Parameter Parsing and Validation
# =============================================================================
parse_parameters() {
    local module="$1"
    local action="$2"
    shift 2
    local params=("$@")
    
    # Validate module
    case "$module" in
        "security"|"performance"|"system"|"report"|"help")
            ;;
        *)
            echo "Error: Invalid module '$module'"
            show_help
            exit 1
            ;;
    esac
    
    # Validate action based on module
    case "$module" in
        "security")
            case "$action" in
                "audit"|"firewall"|"ssh"|"scan"|"harden")
                    ;;
                *)
                    echo "Error: Invalid action '$action' for security module"
                    show_security_help
                    exit 1
                    ;;
            esac
            ;;
        "performance")
            case "$action" in
                "benchmark"|"optimize"|"monitor"|"tune")
                    ;;
                *)
                    echo "Error: Invalid action '$action' for performance module"
                    show_performance_help
                    exit 1
                    ;;
            esac
            ;;
        "system")
            case "$action" in
                "update"|"configure"|"install"|"status")
                    ;;
                *)
                    echo "Error: Invalid action '$action' for system module"
                    show_system_help
                    exit 1
                    ;;
            esac
            ;;
        "report")
            case "$action" in
                "generate"|"export"|"list")
                    ;;
                *)
                    echo "Error: Invalid action '$action' for report module"
                    show_report_help
                    exit 1
                    ;;
            esac
            ;;
    esac
    
    # Execute module with parameters
    execute_module "$module" "$action" "${params[@]}"
}

# =============================================================================
# Module Execution
# =============================================================================
execute_module() {
    local module="$1"
    local action="$2"
    shift 2
    local params=("$@")
    
    case "$module" in
        "security")
            execute_security_module "$action" "${params[@]}"
            ;;
        "performance")
            execute_performance_module "$action" "${params[@]}"
            ;;
        "system")
            execute_system_module "$action" "${params[@]}"
            ;;
        "report")
            execute_report_module "$action" "${params[@]}"
            ;;
        "help")
            show_help
            ;;
    esac
}

# =============================================================================
# Security Module Execution
# =============================================================================
execute_security_module() {
    local action="$1"
    shift
    local params=("$@")
    
    case "$action" in
        "audit")
            echo "🔒 Running Security Audit..."
            source "$SCRIPT_DIR/modules/security/audit.sh"
            run_security_audit "${params[@]}"
            ;;
        "firewall")
            echo "🔥 Configuring Firewall..."
            source "$SCRIPT_DIR/modules/security/firewall.sh"
            configure_firewall "${params[@]}"
            ;;
        "ssh")
            echo "🔑 Hardening SSH..."
            source "$SCRIPT_DIR/modules/security/ssh.sh"
            harden_ssh "${params[@]}"
            ;;
        "scan")
            echo "🔍 Running Security Scan..."
            source "$SCRIPT_DIR/modules/security/tools.sh"
            run_security_scan "${params[@]}"
            ;;
        "harden")
            echo "🛡️ Applying Security Hardening..."
            source "$SCRIPT_DIR/modules/security/security.sh"
            apply_security_hardening "${params[@]}"
            ;;
    esac
}

# =============================================================================
# Performance Module Execution
# =============================================================================
execute_performance_module() {
    local action="$1"
    shift
    local params=("$@")
    
    case "$action" in
        "benchmark")
            echo "⚡ Running Performance Benchmarks..."
            source "$SCRIPT_DIR/modules/performance/benchmarks.sh"
            run_benchmarks "${params[@]}"
            ;;
        "optimize")
            echo "🚀 Applying Performance Optimizations..."
            source "$SCRIPT_DIR/modules/performance/kernel.sh"
            optimize_kernel "${params[@]}"
            ;;
        "monitor")
            echo "📊 Starting Performance Monitoring..."
            source "$SCRIPT_DIR/modules/performance/monitoring.sh"
            start_monitoring "${params[@]}"
            ;;
        "tune")
            echo "🎯 Tuning System Parameters..."
            source "$SCRIPT_DIR/modules/performance/sysctl.sh"
            tune_system "${params[@]}"
            ;;
    esac
}

# =============================================================================
# System Module Execution
# =============================================================================
execute_system_module() {
    local action="$1"
    shift
    local params=("$@")
    
    case "$action" in
        "update")
            echo "🔄 Updating System..."
            source "$SCRIPT_DIR/modules/system/update.sh"
            update_system "${params[@]}"
            ;;
        "configure")
            echo "⚙️ Configuring System..."
            source "$SCRIPT_DIR/modules/system/timezone.sh"
            configure_system "${params[@]}"
            ;;
        "install")
            echo "📦 Installing Packages..."
            source "$SCRIPT_DIR/modules/system/packages.sh"
            install_packages "${params[@]}"
            ;;
        "status")
            echo "📋 System Status..."
            source "$SCRIPT_DIR/modules/system/base-deps.sh"
            show_system_status "${params[@]}"
            ;;
    esac
}

# =============================================================================
# Report Module Execution
# =============================================================================
execute_report_module() {
    local action="$1"
    shift
    local params=("$@")
    
    case "$action" in
        "generate")
            echo "📊 Generating Report..."
            source "$SCRIPT_DIR/modules/security/reporter.sh"
            generate_report "${params[@]}"
            ;;
        "export")
            echo "📤 Exporting Report..."
            source "$SCRIPT_DIR/modules/security/reporter.sh"
            export_report "${params[@]}"
            ;;
        "list")
            echo "📋 Available Reports..."
            source "$SCRIPT_DIR/modules/security/reporter.sh"
            list_reports "${params[@]}"
            ;;
    esac
}

# =============================================================================
# Help Functions
# =============================================================================
show_help() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                      DEBIANFORGE                             ║"
    echo "║                    Version 1.0                               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo
    echo "Usage: ./main.sh [module] [action] [parameters...]"
    echo
    echo "Available Modules:"
    echo "  security   - Security audit, firewall, SSH hardening"
    echo "  performance - Benchmarks, optimization, monitoring"
    echo "  system     - Updates, configuration, package management"
    echo "  report     - Generate and export reports"
    echo "  help       - Show this help message"
    echo
    echo "Examples:"
    echo "  ./main.sh security audit"
    echo "  ./main.sh performance benchmark"
    echo "  ./main.sh system update"
    echo "  ./main.sh report generate security"
    echo
    echo "For detailed help on specific modules:"
    echo "  ./main.sh security help"
    echo "  ./main.sh performance help"
    echo "  ./main.sh system help"
    echo "  ./main.sh report help"
}

show_security_help() {
    echo "Security Module Actions:"
    echo "  audit   - Run comprehensive security audit"
    echo "  firewall - Configure and manage UFW firewall"
    echo "  ssh     - Harden SSH server configuration"
    echo "  scan    - Run security scanning tools"
    echo "  harden  - Apply security hardening measures"
}

show_performance_help() {
    echo "Performance Module Actions:"
    echo "  benchmark - Run system performance benchmarks"
    echo "  optimize  - Apply kernel and system optimizations"
    echo "  monitor   - Start real-time performance monitoring"
    echo "  tune      - Tune system parameters and limits"
}

show_system_help() {
    echo "System Module Actions:"
    echo "  update    - Update system packages and dependencies"
    echo "  configure - Configure system settings and timezone"
    echo "  install   - Install required packages and tools"
    echo "  status    - Show system status and information"
}

show_report_help() {
    echo "Report Module Actions:"
    echo "  generate - Generate security/performance reports"
    echo "  export   - Export reports to various formats"
    echo "  list     - List available reports and templates"
}

# =============================================================================
# Interactive Menu (Legacy Support)
# =============================================================================
show_interactive_menu() {
    while true; do
        clear
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║                      DEBIANFORGE                             ║"
        echo "║                    Version 1.0                               ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo
        echo "Select an option:"
        echo "1. Security Operations"
        echo "2. Performance Operations"
        echo "3. System Operations"
        echo "4. Report Generation"
        echo "5. Show Help"
        echo "6. Exit"
        echo
        read -p "Enter your choice (1-6): " choice
        
        case $choice in
            1) show_security_menu ;;
            2) show_performance_menu ;;
            3) show_system_menu ;;
            4) show_report_menu ;;
            5) show_help ;;
            6) echo "Exiting DebianForge..."; exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

show_security_menu() {
    echo "Security Operations:"
    echo "1. Run Security Audit"
    echo "2. Configure Firewall"
    echo "3. Harden SSH"
    echo "4. Security Scan"
    echo "5. Apply Hardening"
    echo "6. Back to Main Menu"
    
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1) execute_security_module "audit" ;;
        2) execute_security_module "firewall" ;;
        3) execute_security_module "ssh" ;;
        4) execute_security_module "scan" ;;
        5) execute_security_module "harden" ;;
        6) return ;;
        *) echo "Invalid option." ;;
    esac
}

show_performance_menu() {
    echo "Performance Operations:"
    echo "1. Run Benchmarks"
    echo "2. Optimize System"
    echo "3. Start Monitoring"
    echo "4. Tune Parameters"
    echo "5. Back to Main Menu"
    
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1) execute_performance_module "benchmark" ;;
        2) execute_performance_module "optimize" ;;
        3) execute_performance_module "monitor" ;;
        4) execute_performance_module "tune" ;;
        5) return ;;
        *) echo "Invalid option." ;;
    esac
}

show_system_menu() {
    echo "System Operations:"
    echo "1. Update System"
    echo "2. Configure System"
    echo "3. Install Packages"
    echo "4. Show Status"
    echo "5. Back to Main Menu"
    
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1) execute_system_module "update" ;;
        2) execute_system_module "configure" ;;
        3) execute_system_module "install" ;;
        4) execute_system_module "status" ;;
        5) return ;;
        *) echo "Invalid option." ;;
    esac
}

show_report_menu() {
    echo "Report Operations:"
    echo "1. Generate Report"
    echo "2. Export Report"
    echo "3. List Reports"
    echo "4. Back to Main Menu"
    
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1) execute_report_module "generate" ;;
        2) execute_report_module "export" ;;
        3) execute_report_module "list" ;;
        4) return ;;
        *) echo "Invalid option." ;;
    esac
}

# =============================================================================
# Main Execution Logic
# =============================================================================
main() {
    # Security check
    check_execution_security
    
    # Check if parameters provided
    if [ $# -eq 0 ]; then
        # No parameters - show interactive menu
        show_interactive_menu
    else
        # Parameters provided - parse and execute
        parse_parameters "$@"
    fi
}

# =============================================================================
# Script Entry Point
# =============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
