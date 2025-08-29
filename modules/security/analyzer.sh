#!/bin/bash

# =============================================================================
# Audit Analyzer Module - System analysis and information collection
# =============================================================================

# Configuration is loaded centrally in main.sh

# Collect comprehensive system information
collect_system_info() {
    local report_file="$1"
    
    echo "=== System Information ===" >> "$report_file"
    echo "Hostname: $(hostname)" >> "$report_file"
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo 'Unknown')" >> "$report_file"
    echo "Kernel: $(uname -r)" >> "$report_file"
    echo "Architecture: $(uname -m)" >> "$report_file"
    echo "CPU Cores: $(nproc)" >> "$report_file"
    echo "CPU Model: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)" >> "$report_file"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')" >> "$report_file"
    echo "Disk: $(df -h / | awk 'NR==2 {print $2}')" >> "$report_file"
    echo "Uptime: $(uptime -p)" >> "$report_file"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')" >> "$report_file"
    echo "" >> "$report_file"
}

# Analyze system resources
analyze_system_resources() {
    local report_file="$1"
    
    echo "=== System Resources Analysis ===" >> "$report_file"
    
    # Check disk usage
    local disk_usage=$(df -h / | awk 'NR==2 {print int($5)}')
    if [ "$disk_usage" -lt 80 ]; then
        echo "Disk Usage: ${disk_usage}% [PASS]" >> "$report_file"
    else
        echo "Disk Usage: ${disk_usage}% [WARN]" >> "$report_file"
    fi
    
    # Check memory usage
    local mem_usage=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100}')
    if [ "$mem_usage" -lt 80 ]; then
        echo "Memory Usage: ${mem_usage}% [PASS]" >> "$report_file"
    else
        echo "Memory Usage: ${mem_usage}% [WARN]" >> "$report_file"
    fi
    
    # Check swap
    if swapon --show | grep -q .; then
        local swap_usage=$(free | awk '/^Swap:/ {printf "%.0f", $3/$2 * 100}')
        echo "Swap: ENABLED (${swap_usage}% used) [PASS]" >> "$report_file"
    else
        echo "Swap: DISABLED [WARN]" >> "$report_file"
    fi
    
    # Check load average
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local cpu_cores=$(nproc)
    local load_per_core=$(echo "scale=2; $load_avg / $cpu_cores" | bc 2>/dev/null || echo "0")
    
    if (( $(echo "$load_per_core < 1.0" | bc -l) )); then
        echo "Load Average: $load_avg (${load_per_core} per core) [PASS]" >> "$report_file"
    else
        echo "Load Average: $load_avg (${load_per_core} per core) [WARN]" >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Analyze system performance
analyze_system_performance() {
    local report_file="$1"
    
    echo "=== System Performance Analysis ===" >> "$report_file"
    
    # Check CPU frequency
    if [ -f "/proc/cpuinfo" ]; then
        local cpu_freq=$(grep "cpu MHz" /proc/cpuinfo | head -1 | awk '{print $4}')
        echo "CPU Frequency: ${cpu_freq} MHz" >> "$report_file"
    fi
    
    # Check I/O statistics
    if [ -f "/proc/diskstats" ]; then
        echo "Disk I/O Statistics:" >> "$report_file"
        iostat -x 1 1 2>/dev/null | tail -n +3 | head -5 >> "$report_file" || echo "  iostat not available" >> "$report_file"
    fi
    
    # Check network statistics
    if [ -f "/proc/net/dev" ]; then
        echo "Network Statistics:" >> "$report_file"
        cat /proc/net/dev | grep -E "(eth|en|wlan)" | head -3 >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Analyze system configuration
analyze_system_config() {
    local report_file="$1"
    
    echo "=== System Configuration Analysis ===" >> "$report_file"
    
    # Check kernel parameters
    echo "Kernel Parameters:" >> "$report_file"
    local important_params=("vm.swappiness" "vm.dirty_ratio" "net.core.rmem_max" "net.core.wmem_max")
    for param in "${important_params[@]}"; do
        local value=$(sysctl -n "$param" 2>/dev/null || echo "not set")
        echo "  $param = $value" >> "$report_file"
    done
    
    # Check system limits
    echo "System Limits:" >> "$report_file"
    echo "  Max open files: $(ulimit -n)" >> "$report_file"
    echo "  Max processes: $(ulimit -u)" >> "$report_file"
    echo "  Stack size: $(ulimit -s)" >> "$report_file"
    
    echo "" >> "$report_file"
}
