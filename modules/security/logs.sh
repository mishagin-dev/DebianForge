#!/bin/bash

# =============================================================================
# Audit Logs Module - System and application log analysis
# =============================================================================

# Configuration is loaded centrally in main.sh

# Check system logs
check_system_logs() {
    local report_file="$1"
    
    echo "=== System Logs Analysis ===" >> "$report_file"
    
    # Check SSH login attempts
    if [ -f "/var/log/auth.log" ]; then
        local failed_logins=$(grep "Failed password" /var/log/auth.log | tail -5 | wc -l)
        local successful_logins=$(grep "Accepted password\|Accepted publickey" /var/log/auth.log | tail -5 | wc -l)
        
        echo "Recent SSH Activity:" >> "$report_file"
        echo "  - Failed attempts: $failed_logins" >> "$report_file"
        echo "  - Successful logins: $successful_logins" >> "$report_file"
        
        # Show recent failed attempts
        if [ "$failed_logins" -gt 0 ]; then
            echo "  Recent failed attempts:" >> "$report_file"
            grep "Failed password" /var/log/auth.log | tail -3 | while read line; do
                echo "    - $line" >> "$report_file"
            done
        fi
    fi
    
    # Check system errors
    if [ -f "/var/log/syslog" ]; then
        local system_errors=$(grep -i "error\|fail\|critical" /var/log/syslog | tail -3 | wc -l)
        echo "Recent System Errors: $system_errors" >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Check UFW logs
check_ufw_logs() {
    local report_file="$1"
    
    echo "=== UFW Logs Analysis ===" >> "$report_file"
    
    if [ -f "/var/log/ufw.log" ]; then
        local ufw_blocks=$(grep "BLOCK" /var/log/ufw.log | tail -5 | wc -l)
        local ufw_allows=$(grep "ALLOW" /var/log/ufw.log | tail -5 | wc -l)
        
        echo "Recent UFW Activity:" >> "$report_file"
        echo "  - Blocks: $ufw_blocks" >> "$report_file"
        echo "  - Allows: $ufw_allows" >> "$report_file"
        
        # Show recent blocks
        if [ "$ufw_blocks" -gt 0 ]; then
            echo "  Recent blocks:" >> "$report_file"
            grep "BLOCK" /var/log/ufw.log | tail -3 | while read line; do
                echo "    - $line" >> "$report_file"
            done
        fi
    else
        echo "UFW logs not found or empty" >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Check application logs
check_application_logs() {
    local report_file="$1"
    
    echo "=== Application Logs Analysis ===" >> "$report_file"
    
    # Check common application logs
    local log_files=(
        "/var/log/apache2/error.log"
        "/var/log/nginx/error.log"
        "/var/log/mysql/error.log"
        "/var/log/php/error.log"
    )
    
    for log_file in "${log_files[@]}"; do
        if [ -f "$log_file" ]; then
            local error_count=$(grep -i "error\|fail\|critical" "$log_file" | tail -5 | wc -l)
            echo "$(basename "$log_file"): $error_count recent errors" >> "$report_file"
        fi
    done
    
    echo "" >> "$report_file"
}

# Check log rotation
check_log_rotation() {
    local report_file="$1"
    
    echo "=== Log Rotation Analysis ===" >> "$report_file"
    
    # Check logrotate configuration
    if [ -f "/etc/logrotate.conf" ]; then
        echo "Logrotate Configuration:" >> "$report_file"
        grep -v '^#' /etc/logrotate.conf | grep -v '^$' | head -5 | while read line; do
            echo "  - $line" >> "$report_file"
        done
    fi
    
    # Check log file sizes
    echo "Large Log Files:" >> "$report_file"
    find /var/log -name "*.log" -size +10M 2>/dev/null | head -5 | while read log_file; do
        local size=$(du -h "$log_file" | cut -f1)
        echo "  - $log_file: $size" >> "$report_file"
    done
    
    echo "" >> "$report_file"
}

# Check log permissions
check_log_permissions() {
    local report_file="$1"
    
    echo "=== Log Permissions Analysis ===" >> "$report_file"
    
    # Check log directory permissions
    local log_dirs=("/var/log" "/var/log/apache2" "/var/log/nginx" "/var/log/mysql")
    
    for log_dir in "${log_dirs[@]}"; do
        if [ -d "$log_dir" ]; then
            local perms=$(stat -c "%a" "$log_dir")
            local owner=$(stat -c "%U" "$log_dir")
            echo "$log_dir: $perms ($owner)" >> "$report_file"
            
            # Check for world-writable
            if [ "$((perms % 10))" -ge 2 ]; then
                echo "  [WARN] World-writable permissions" >> "$report_file"
            fi
        fi
    done
    
    echo "" >> "$report_file"
}

# Check log integrity
check_log_integrity() {
    local report_file="$1"
    
    echo "=== Log Integrity Check ===" >> "$report_file"
    
    # Check for log tampering indicators
    local suspicious_patterns=(
        "grep -v"
        "sed -i"
        "truncate"
        "> /var/log"
    )
    
    echo "Suspicious Log Operations:" >> "$report_file"
    for pattern in "${suspicious_patterns[@]}"; do
        local matches=$(grep -r "$pattern" /var/log 2>/dev/null | wc -l)
        if [ "$matches" -gt 0 ]; then
            echo "  [WARN] Found $matches instances of '$pattern'" >> "$report_file"
        fi
    done
    
    echo "" >> "$report_file"
}
