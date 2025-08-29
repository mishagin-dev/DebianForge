#!/bin/bash

# =============================================================================
# Audit Processes Module - Process and service analysis
# =============================================================================

# Configuration is loaded centrally in main.sh

# Check running processes
check_running_processes() {
    local report_file="$1"
    
    echo "=== Running Processes Analysis ===" >> "$report_file"
    
    # Check high CPU processes
    echo "High CPU Processes:" >> "$report_file"
    ps aux --sort=-%cpu | head -5 | while read line; do
        echo "  - $line" >> "$report_file"
    done
    
    # Check high memory processes
    echo "High Memory Processes:" >> "$report_file"
    ps aux --sort=-%mem | head -5 | while read line; do
        echo "  - $line" >> "$report_file"
    done
    
    # Check suspicious processes
    echo "Suspicious Process Check:" >> "$report_file"
    ps aux | grep -E "(nc|netcat|telnet|rsh|rlogin)" | grep -v grep | while read line; do
        if [ -n "$line" ]; then
            echo "  [WARN] Potentially suspicious: $line" >> "$report_file"
        fi
    done
    
    echo "" >> "$report_file"
}

# Check autostart services
check_autostart_services() {
    local report_file="$1"
    
    echo "=== Autostart Services Analysis ===" >> "$report_file"
    
    # Check enabled systemd services
    echo "Enabled Systemd Services:" >> "$report_file"
    systemctl list-unit-files --state=enabled | grep -E "\.service$" | head -10 | while read line; do
        echo "  - $line" >> "$report_file"
    done
    
    # Check failed services
    local failed_services=$(systemctl list-units --state=failed | grep "\.service")
    if [ -n "$failed_services" ]; then
        echo "Failed Services:" >> "$report_file"
        echo "$failed_services" | while read line; do
            echo "  - $line" >> "$report_file"
        done
    fi
    
    echo "" >> "$report_file"
}

# Check process limits
check_process_limits() {
    local report_file="$1"
    
    echo "=== Process Limits Analysis ===" >> "$report_file"
    
    # Check current limits
    echo "Current Process Limits:" >> "$report_file"
    echo "  - Max open files: $(ulimit -n)" >> "$report_file"
    echo "  - Max processes: $(ulimit -u)" >> "$report_file"
    echo "  - Stack size: $(ulimit -s)" >> "$report_file"
    echo "  - Core file size: $(ulimit -c)" >> "$report_file"
    
    # Check system-wide limits
    if [ -f "/etc/security/limits.conf" ]; then
        echo "System Limits Configuration:" >> "$report_file"
        grep -v '^#' /etc/security/limits.conf | grep -v '^$' | while read line; do
            if [ -n "$line" ]; then
                echo "  - $line" >> "$report_file"
            fi
        done
    fi
    
    echo "" >> "$report_file"
}

# Check service status
check_service_status() {
    local report_file="$1"
    
    echo "=== Service Status Analysis ===" >> "$report_file"
    
    # Check critical services
    local critical_services=("ssh" "ufw" "systemd" "cron")
    echo "Critical Services Status:" >> "$report_file"
    
    for service in "${critical_services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo "  - $service: ACTIVE [PASS]" >> "$report_file"
        else
            echo "  - $service: INACTIVE [FAIL]" >> "$report_file"
        fi
    done
    
    # Check all running services
    echo "All Running Services:" >> "$report_file"
    systemctl list-units --state=running | grep "\.service$" | head -10 | while read line; do
        echo "  - $line" >> "$report_file"
    done
    
    echo "" >> "$report_file"
}

# Check process tree
check_process_tree() {
    local report_file="$1"
    
    echo "=== Process Tree Analysis ===" >> "$report_file"
    
    # Check init process
    echo "Init Process:" >> "$report_file"
    ps -p 1 -o pid,ppid,cmd >> "$report_file"
    
    # Check systemd processes
    echo "Systemd Processes:" >> "$report_file"
    ps aux | grep systemd | grep -v grep | head -5 | while read line; do
        echo "  - $line" >> "$report_file"
    done
    
    echo "" >> "$report_file"
}

# Check zombie processes
check_zombie_processes() {
    local report_file="$1"
    
    echo "=== Zombie Process Check ===" >> "$report_file"
    
    local zombie_count=$(ps aux | grep -c "Z\|<defunct>")
    if [ "$zombie_count" -gt 0 ]; then
        echo "Zombie Processes Found: $zombie_count [WARN]" >> "$report_file"
        ps aux | grep "Z\|<defunct>" | while read line; do
            echo "  - $line" >> "$report_file"
        done
    else
        echo "Zombie Processes: None [PASS]" >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}
