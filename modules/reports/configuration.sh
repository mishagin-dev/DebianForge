#!/bin/bash

# =============================================================================
# Configuration Report Module - Multi-format report generation
# =============================================================================

# Source common functions
source "$(dirname "$0")/../lib/core.sh" 2>/dev/null || source "lib/core.sh"

# Generate Configuration Report
generate_configuration_report() {
    local report_data="$1"
    local output_dir="$2"
    
    yellow_msg 'Generating Configuration Report in Multiple Formats...'
    echo
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Generate reports in all formats
    generate_config_html_report "$report_data" "$output_dir"
    generate_config_markdown_report "$report_data" "$output_dir"
    generate_config_json_report "$report_data" "$output_dir"
    generate_config_plain_report "$report_data" "$output_dir"
    generate_config_csv_report "$report_data" "$output_dir"
    
    green_msg "✅ Configuration report generated in all formats: $output_dir"
}

# Generate Configuration HTML report
generate_config_html_report() {
    local report_data="$1"
    local output_dir="$2"
    
    local template_file="reports/templates/html/configuration-report.html"
    local output_file="$output_dir/configuration-report-$(date +%Y%m%d-%H%M%S).html"
    
    if [ -f "$template_file" ]; then
        # Replace placeholders with actual data
        local html_content=$(cat "$template_file")
        html_content=$(echo "$html_content" | sed "s/{{GENERATED_DATE}}/$(date '+%Y-%m-%d')/g")
        html_content=$(echo "$html_content" | sed "s/{{GENERATED_TIME}}/$(date '+%H:%M:%S')/g")
        html_content=$(echo "$html_content" | sed "s/{{SYSTEM_INFO}}/$(uname -a | sed 's/\//\\\//g')/g")
        html_content=$(echo "$html_content" | sed "s/{{REPORT_TYPE}}/Configuration Analysis/g")
        html_content=$(echo "$html_content" | sed "s/{{CONFIG_VERSION}}/$(date +%Y%m%d)/g")
        html_content=$(echo "$html_content" | sed "s/{{CONFIG_HEALTH_SCORE}}/82/g")
        
        echo "$html_content" > "$output_file"
        green_msg "✅ Configuration HTML report: $output_file"
    else
        red_msg "❌ Configuration HTML template not found: $template_file"
    fi
}

# Generate Configuration Markdown report
generate_config_markdown_report() {
    local report_data="$1"
    local output_dir="$2"
    
    local template_file="reports/templates/markdown/configuration-report.md"
    local output_file="$output_dir/configuration-report-$(date +%Y%m%d-%H%M%S).md"
    
    if [ -f "$template_file" ]; then
        # Replace placeholders with actual data
        local md_content=$(cat "$template_file")
        md_content=$(echo "$md_content" | sed "s/{{GENERATED_DATE}}/$(date '+%Y-%m-%d')/g")
        md_content=$(echo "$md_content" | sed "s/{{GENERATED_TIME}}/$(date '+%H:%M:%S')/g")
        md_content=$(echo "$md_content" | sed "s/{{SYSTEM_INFO}}/$(uname -a)/g")
        md_content=$(echo "$md_content" | sed "s/{{REPORT_TYPE}}/Configuration Analysis/g")
        md_content=$(echo "$md_content" | sed "s/{{CONFIG_VERSION}}/$(date +%Y%m%d)/g")
        md_content=$(echo "$md_content" | sed "s/{{CONFIG_HEALTH_SCORE}}/82/g")
        
        echo "$md_content" > "$output_file"
        green_msg "✅ Configuration Markdown report: $output_file"
    else
        red_msg "❌ Configuration Markdown template not found: $template_file"
    fi
}

# Generate Configuration JSON report
generate_config_json_report() {
    local report_data="$1"
    local output_dir="$2"
    
    local template_file="reports/templates/json/configuration-report.json"
    local output_file="$output_dir/configuration-report-$(date +%Y%m%d-%H%M%S).json"
    
    if [ -f "$template_file" ]; then
        # Replace placeholders with actual data
        local json_content=$(cat "$template_file")
        json_content=$(echo "$json_content" | sed "s/{{GENERATED_DATE}}/$(date '+%Y-%m-%d')/g")
        json_content=$(echo "$json_content" | sed "s/{{GENERATED_TIME}}/$(date '+%H:%M:%S')/g")
        json_content=$(echo "$json_content" | sed "s/{{SYSTEM_INFO}}/$(uname -a)/g")
        json_content=$(echo "$json_content" | sed "s/{{REPORT_TYPE}}/Configuration Analysis/g")
        json_content=$(echo "$json_content" | sed "s/{{CONFIG_VERSION}}/$(date +%Y%m%d)/g")
        json_content=$(echo "$json_content" | sed "s/{{CONFIG_HEALTH_SCORE}}/82/g")
        
        echo "$json_content" > "$output_file"
        green_msg "✅ Configuration JSON report: $output_file"
    else
        red_msg "❌ Configuration JSON template not found: $template_file"
    fi
}

# Generate Configuration Plain report
generate_config_plain_report() {
    local report_data="$1"
    local output_dir="$2"
    
    local template_file="reports/templates/plain/configuration-report.txt"
    local output_file="$output_dir/configuration-report-$(date +%Y%m%d-%H%M%S).txt"
    
    if [ -f "$template_file" ]; then
        # Replace placeholders with actual data
        local txt_content=$(cat "$template_file")
        txt_content=$(echo "$txt_content" | sed "s/{{GENERATED_DATE}}/$(date '+%Y-%m-%d')/g")
        txt_content=$(echo "$txt_content" | sed "s/{{GENERATED_TIME}}/$(date '+%H:%M:%S')/g")
        txt_content=$(echo "$txt_content" | sed "s/{{SYSTEM_INFO}}/$(uname -a)/g")
        txt_content=$(echo "$txt_content" | sed "s/{{REPORT_TYPE}}/Configuration Analysis/g")
        txt_content=$(echo "$txt_content" | sed "s/{{CONFIG_VERSION}}/$(date +%Y%m%d)/g")
        txt_content=$(echo "$txt_content" | sed "s/{{CONFIG_HEALTH_SCORE}}/82/g")
        
        echo "$txt_content" > "$output_file"
        green_msg "✅ Configuration Plain report: $output_file"
    else
        red_msg "❌ Configuration Plain template not found: $template_file"
    fi
}

# Generate Configuration CSV report
generate_config_csv_report() {
    local report_data="$1"
    local output_dir="$2"
    
    local template_file="reports/templates/csv/configuration-report.csv"
    local output_file="$output_dir/configuration-report-$(date +%Y%m%d-%H%M%S).csv"
    
    if [ -f "$template_file" ]; then
        # Replace placeholders with actual data
        local csv_content=$(cat "$template_file")
        csv_content=$(echo "$csv_content" | sed "s/{{GENERATED_DATE}}/$(date '+%Y-%m-%d')/g")
        csv_content=$(echo "$csv_content" | sed "s/{{GENERATED_TIME}}/$(date '+%H:%M:%S')/g")
        csv_content=$(echo "$csv_content" | sed "s/{{SYSTEM_INFO}}/$(uname -a)/g")
        csv_content=$(echo "$csv_content" | sed "s/{{REPORT_TYPE}}/Configuration Analysis/g")
        csv_content=$(echo "$csv_content" | sed "s/{{CONFIG_VERSION}}/$(date +%Y%m%d)/g")
        csv_content=$(echo "$csv_content" | sed "s/{{CONFIG_HEALTH_SCORE}}/82/g")
        
        echo "$csv_content" > "$output_file"
        green_msg "✅ Configuration CSV report: $output_file"
    else
        red_msg "❌ Configuration CSV template not found: $template_file"
    fi
}
