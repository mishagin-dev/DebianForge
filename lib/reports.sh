#!/bin/bash

# =============================================================================
# Reports Management System - Modular Report Generation
# =============================================================================

# Source common functions
source "$(dirname "$0")/core.sh"

# Source all report modules
source "$(dirname "$0")/../modules/reports/security.sh"
source "$(dirname "$0")/../modules/reports/performance.sh"
source "$(dirname "$0")/../modules/reports/system.sh"
source "$(dirname "$0")/../modules/reports/configuration.sh"
source "$(dirname "$0")/../modules/reports/comprehensive.sh"

# =============================================================================
# Main Report Management Functions
# =============================================================================

# Main report generation function
generate_all_reports() {
    local report_type="$1"
    local report_data="$2"
    local diagnostic_type="$3"  # "quick" or "full"
    local output_dir="reports/$(date +%Y%m%d)"
    
    case "$report_type" in
        "security")
            generate_security_report "$report_data" "$output_dir"
            ;;
        "performance")
            generate_performance_report "$report_data" "$output_dir"
            ;;
        "system")
            generate_system_report "$report_data" "$output_dir"
            ;;
        "configuration")
            generate_configuration_report "$report_data" "$output_dir"
            ;;
        "comprehensive")
            # Comprehensive report only for full diagnostics
            if [ "$diagnostic_type" = "full" ]; then
                generate_comprehensive_report "$report_data" "$output_dir"
            else
                yellow_msg "⚠️  Comprehensive report only available for full diagnostics"
                return 1
            fi
            ;;
        *)
            red_msg "Unknown report type: $report_type"
            return 1
            ;;
    esac
    
    green_msg "🎉 All reports generated successfully in: $output_dir"
}

# Generate comprehensive system analysis (all reports)
generate_full_system_analysis() {
    local output_dir="reports/$(date +%Y%m%d)"
    local report_data="full_system_data"
    
    yellow_msg '🚀 Starting Full System Analysis...'
    echo
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Generate all individual reports
    generate_security_report "$report_data" "$output_dir"
    generate_performance_report "$report_data" "$output_dir"
    generate_system_report "$report_data" "$output_dir"
    generate_configuration_report "$report_data" "$output_dir"
    
    # Generate comprehensive report (only for full diagnostics)
    generate_comprehensive_report "$report_data" "$output_dir"
    
    green_msg "🎉 Full system analysis completed in: $output_dir"
}

# Show available report templates
show_report_templates() {
    yellow_msg 'Available Report Templates:'
    echo
    
    echo "📁 HTML Templates:"
    ls -la reports/templates/html/ 2>/dev/null || echo "  No HTML templates found"
    echo
    
    echo "📝 Markdown Templates:"
    ls -la reports/templates/markdown/ 2>/dev/null || echo "  No Markdown templates found"
    echo
    
    echo "🔧 JSON Templates:"
    ls -la reports/templates/json/ 2>/dev/null || echo "  No JSON templates found"
    echo
    
    echo "📄 Plain Text Templates:"
    ls -la reports/templates/plain/ 2>/dev/null || echo "  No Plain text templates found"
    echo
    
    echo "📊 CSV Templates:"
    ls -la reports/templates/csv/ 2>/dev/null || echo "  No CSV templates found"
    echo
}

# Show available report types
show_report_types() {
    yellow_msg 'Available Report Types:'
    echo
    
    echo "🔒 Security Report"
    echo "  - Comprehensive security audit"
    echo "  - Network security analysis"
    echo "  - Risk assessment"
    echo
    
    echo "⚡ Performance Report"
    echo "  - System performance benchmarks"
    echo "  - Component performance analysis"
    echo "  - Optimization recommendations"
    echo
    
    echo "🖥️  System Report"
    echo "  - System health status"
    echo "  - Resource usage analysis"
    echo "  - Service status monitoring"
    echo
    
    echo "🔧 Configuration Report"
    echo "  - System configuration analysis"
    echo "  - Security configuration review"
    echo "  - Performance configuration"
    echo
    
    echo "📊 Comprehensive Report (Full Diagnostics Only)"
    echo "  - Complete system analysis"
    echo "  - Executive summary"
    echo "  - Priority actions"
    echo
}

# Validate report templates
validate_report_templates() {
    yellow_msg 'Validating Report Templates...'
    echo
    
    local missing_templates=0
    local total_templates=0
    
    # Check all report types
    for report_type in security performance system configuration comprehensive; do
        # Check all formats
        for format in html markdown json csv plain; do
            local template_file="reports/templates/$format/$report_type-report.$format"
            if [ "$format" = "plain" ]; then
                template_file="reports/templates/$format/$report_type-report.txt"
            fi
            
            total_templates=$((total_templates + 1))
            
            if [ -f "$template_file" ]; then
                echo "✅ $report_type $format template: OK"
            else
                echo "❌ $report_type $format template: MISSING"
                missing_templates=$((missing_templates + 1))
            fi
        done
        echo
    done
    
    echo "📊 Template Validation Summary:"
    echo "  Total templates: $total_templates"
    echo "  Missing templates: $missing_templates"
    echo "  Valid templates: $((total_templates - missing_templates))"
    
    if [ $missing_templates -eq 0 ]; then
        green_msg "🎉 All report templates are present and valid!"
        return 0
    else
        red_msg "⚠️  Some report templates are missing!"
        return 1
    fi
}

# Test report generation
test_report_generation() {
    local test_output_dir="test_reports_$(date +%Y%m%d-%H%M%S)"
    
    yellow_msg "🧪 Testing Report Generation..."
    echo
    
    # Create test output directory
    mkdir -p "$test_output_dir"
    
    # Test each report type
    local test_data="test_data"
    
    echo "Testing Security Report..."
    generate_security_report "$test_data" "$test_output_dir"
    echo
    
    echo "Testing Performance Report..."
    generate_performance_report "$test_data" "$test_output_dir"
    echo
    
    echo "Testing System Report..."
    generate_system_report "$test_data" "$test_output_dir"
    echo
    
    echo "Testing Configuration Report..."
    generate_configuration_report "$test_data" "$test_output_dir"
    echo
    
    echo "Testing Comprehensive Report..."
    generate_comprehensive_report "$test_data" "$test_output_dir"
    echo
    
    # Show generated files
    echo "📁 Generated test reports:"
    ls -la "$test_output_dir"/
    
    green_msg "✅ Report generation test completed in: $test_output_dir"
}

# Main menu for reports
reports_main_menu() {
    while true; do
        echo
        yellow_msg "📊 Reports Management System"
        echo "================================"
        echo "1. Generate Security Report"
        echo "2. Generate Performance Report"
        echo "3. Generate System Report"
        echo "4. Generate Configuration Report"
        echo "5. Generate Comprehensive Report (Full Diagnostics)"
        echo "6. Full System Analysis"
        echo "7. Show Available Templates"
        echo "8. Show Report Types"
        echo "9. Validate Templates"
        echo "10. Test Report Generation"
        echo "0. Exit"
        echo
        
        read -p "Select option: " choice
        
        case $choice in
            1)
                read -p "Enter report data: " report_data
                generate_all_reports "security" "$report_data" "quick"
                ;;
            2)
                read -p "Enter report data: " report_data
                generate_all_reports "performance" "$report_data" "quick"
                ;;
            3)
                read -p "Enter report data: " report_data
                generate_all_reports "system" "$report_data" "quick"
                ;;
            4)
                read -p "Enter report data: " report_data
                generate_all_reports "configuration" "$report_data" "quick"
                ;;
            5)
                read -p "Enter report data: " report_data
                read -p "Diagnostic type (quick/full): " diagnostic_type
                generate_all_reports "comprehensive" "$report_data" "$diagnostic_type"
                ;;
            6)
                generate_full_system_analysis
                ;;
            7)
                show_report_templates
                ;;
            8)
                show_report_types
                ;;
            9)
                validate_report_templates
                ;;
            10)
                test_report_generation
                ;;
            0)
                echo "Exiting Reports Management System..."
                exit 0
                ;;
            *)
                red_msg "Invalid option. Please try again."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# If script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    reports_main_menu
fi
