#!/bin/bash

# =============================================================================
# Main Audit Module - Coordinates all audit functionality
# =============================================================================

# Configuration is loaded centrally in main.sh

# Load all audit modules
source "resources/modules/audit/analyzer.sh"
source "resources/modules/audit/security.sh"
source "resources/modules/audit/network.sh"
source "resources/modules/audit/processes.sh"
source "resources/modules/audit/logs.sh"
source "resources/modules/audit/integrity.sh"
source "resources/modules/audit/reporter.sh"

# Run enhanced security audit
run_security_audit() {
    yellow_msg 'Running Enhanced Security Audit...'
    echo
    sleep 0.5

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_file="security-audit-${timestamp}.txt"
    local summary_file="security-summary-${timestamp}.txt"
    local executive_file="executive-summary-${timestamp}.txt"
    
    # Start audit report
    echo "VPS Enhanced Security Audit Report" > "$report_file"
    echo "Generated at: $(date)" >> "$report_file"
    echo "=====================================" >> "$report_file"
    
    # System analysis
    if [ "$(get_audit_config "include_system_info" "true")" = "true" ]; then
        collect_system_info "$report_file"
        analyze_system_resources "$report_file"
        analyze_system_performance "$report_file"
        analyze_system_config "$report_file"
    fi
    
    # Security checks
    if [ "$(get_audit_config "include_security_check" "true")" = "true" ]; then
        check_basic_security "$report_file"
        check_advanced_security "$report_file"
        check_user_security "$report_file"
        check_cron_security "$report_file"
        check_critical_files "$report_file"
    fi
    
    # Resource checks
    if [ "$(get_audit_config "include_resource_check" "true")" = "true" ]; then
        analyze_system_resources "$report_file"
    fi
    
    # Network checks
    if [ "$(get_audit_config "include_network_check" "true")" = "true" ]; then
        check_network_security "$report_file"
        check_network_connections "$report_file"
        check_dns_security "$report_file"
        check_network_interfaces "$report_file"
        check_network_traffic "$report_file"
        check_firewall_rules "$report_file"
    fi
    
    # Enhanced checks based on configuration
    if [ "$(get_audit_config "check_processes" "true")" = "true" ]; then
        check_running_processes "$report_file"
        check_autostart_services "$report_file"
        check_process_limits "$report_file"
        check_service_status "$report_file"
        check_process_tree "$report_file"
        check_zombie_processes "$report_file"
    fi
    
    if [ "$(get_audit_config "check_logs" "true")" = "true" ]; then
        check_system_logs "$report_file"
        check_ufw_logs "$report_file"
        check_application_logs "$report_file"
        check_log_rotation "$report_file"
        check_log_permissions "$report_file"
        check_log_integrity "$report_file"
    fi
    
    if [ "$(get_audit_config "check_integrity" "true")" = "true" ]; then
        check_system_integrity "$report_file"
        check_package_integrity "$report_file"
        check_filesystem_integrity "$report_file"
        check_config_integrity "$report_file"
        check_boot_integrity "$report_file"
        check_service_integrity "$report_file"
        check_user_file_integrity "$report_file"
    fi
    
    # Calculate security score
    local security_score=$(calculate_security_score "$report_file")
    
    # Generate reports
    if [ "$(get_audit_config "generate_summary" "true")" = "true" ]; then
        generate_audit_summary "$summary_file" "$security_score" "$timestamp"
        generate_executive_summary "$executive_file" "$security_score" "$timestamp"
    fi
    
    echo
    green_msg "Enhanced security audit complete!"
    green_msg "Detailed report: $report_file"
    green_msg "Security summary: $summary_file"
    green_msg "Executive summary: $executive_file"
    green_msg "Security Score: $security_score/100"
    echo
    sleep 0.5
}

# Run quick audit
run_quick_audit() {
    yellow_msg 'Running Quick Security Audit...'
    echo
    sleep 0.5

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_file="quick-audit-${timestamp}.txt"
    
    # Start quick audit report
    echo "VPS Quick Security Audit Report" > "$report_file"
    echo "Generated at: $(date)" >> "$report_file"
    echo "=================================" >> "$report_file"
    
    # Basic checks only
    collect_system_info "$report_file"
    check_basic_security "$report_file"
    analyze_system_resources "$report_file"
    check_network_security "$report_file"
    
    # Calculate security score
    local security_score=$(calculate_security_score "$report_file")
    
    echo
    green_msg "Quick security audit complete!"
    green_msg "Report: $report_file"
    green_msg "Security Score: $security_score/100"
    echo
    sleep 0.5
}

# Run network audit
run_network_audit() {
    yellow_msg 'Running Network Security Audit...'
    echo
    sleep 0.5

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_file="network-audit-${timestamp}.txt"
    
    # Start network audit report
    echo "VPS Network Security Audit Report" > "$report_file"
    echo "Generated at: $(date)" >> "$report_file"
    echo "==================================" >> "$report_file"
    
    # Network-specific checks
    check_network_security "$report_file"
    check_network_connections "$report_file"
    check_dns_security "$report_file"
    check_network_interfaces "$report_file"
    check_network_traffic "$report_file"
    check_firewall_rules "$report_file"
    
    echo
    green_msg "Network security audit complete!"
    green_msg "Report: $report_file"
    echo
    sleep 0.5
}

# Run process audit
run_process_audit() {
    yellow_msg 'Running Process and Service Audit...'
    echo
    sleep 0.5

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_file="process-audit-${timestamp}.txt"
    
    # Start process audit report
    echo "VPS Process and Service Audit Report" > "$report_file"
    echo "Generated at: $(date)" >> "$report_file"
    echo "=====================================" >> "$report_file"
    
    # Process-specific checks
    check_running_processes "$report_file"
    check_autostart_services "$report_file"
    check_process_limits "$report_file"
    check_service_status "$report_file"
    check_process_tree "$report_file"
    check_zombie_processes "$report_file"
    
    echo
    green_msg "Process and service audit complete!"
    green_msg "Report: $report_file"
    echo
    sleep 0.5
}

# Show audit menu
show_audit_menu() {
    clear
    echo "=========================================="
    echo "           AUDIT MODULE MENU"
    echo "=========================================="
    echo
    echo "1. Full Security Audit (Comprehensive)"
    echo "2. Quick Security Audit (Basic)"
    echo "3. Network Security Audit"
    echo "4. Process and Service Audit"
    echo "5. Show Recent Reports"
    echo "6. Export Reports"
    echo "7. Back to Main Menu"
    echo
    echo "=========================================="
}

# Handle audit menu
handle_audit_menu() {
    while true; do
        show_audit_menu
        read -p "Choose an option (1-7): " choice
        
        case $choice in
            1)
                run_security_audit
                wait_for_enter
                ;;
            2)
                run_quick_audit
                wait_for_enter
                ;;
            3)
                run_network_audit
                wait_for_enter
                ;;
            4)
                run_process_audit
                wait_for_enter
                ;;
            5)
                show_audit_summary
                wait_for_enter
                ;;
            6)
                local timestamp=$(date +"%Y%m%d_%H%M%S")
                local report_file="security-audit-${timestamp}.txt"
                export_report_formats "$report_file" "$timestamp"
                wait_for_enter
                ;;
            7)
                break
                ;;
            *)
                red_msg "Invalid option. Please choose 1-7."
                sleep 1
                ;;
        esac
    done
}
