#!/bin/bash

# =============================================================================
# Performance Monitoring Module - Real-time system performance monitoring
# =============================================================================

# Configuration is loaded centrally in main.sh

# Start real-time performance monitoring
start_performance_monitoring() {
    yellow_msg 'Starting Performance Monitoring...'
    echo
    
    # Check if monitoring tools are available
    local monitoring_tools=("htop" "iotop" "nethogs" "dstat" "atop")
    local missing_tools=()
    
    for tool in "${monitoring_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        yellow_msg "Installing missing monitoring tools: ${missing_tools[*]}"
        install_performance_tools
    fi
    
    green_msg "Performance monitoring tools ready!"
}

# Monitor CPU usage
monitor_cpu() {
    yellow_msg 'CPU Usage Monitoring:'
    echo
    
    # Show CPU info
    echo "CPU Cores: $(nproc)"
    echo "CPU Model: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
    echo
    
    # Show current CPU usage
    echo "Current CPU Usage:"
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//'
    
    # Show load average
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo
}

# Monitor memory usage
monitor_memory() {
    yellow_msg 'Memory Usage Monitoring:'
    echo
    
    # Show memory info
    free -h
    
    # Show memory details
    echo
    echo "Memory Details:"
    cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree"
    echo
}

# Monitor disk usage
monitor_disk() {
    yellow_msg 'Disk Usage Monitoring:'
    echo
    
    # Show disk space
    df -h
    
    # Show disk I/O
    echo
    echo "Disk I/O Statistics:"
    iostat -x 1 1 2>/dev/null || echo "iostat not available"
    echo
}

# Monitor network usage
monitor_network() {
    yellow_msg 'Network Usage Monitoring:'
    echo
    
    # Show network interfaces
    echo "Network Interfaces:"
    ip -br addr show
    
    # Show network statistics
    echo
    echo "Network Statistics:"
    ss -tuln | head -10
    echo
}

# Monitor system processes
monitor_processes() {
    yellow_msg 'Process Monitoring:'
    echo
    
    # Show top processes by CPU
    echo "Top Processes by CPU Usage:"
    ps aux --sort=-%cpu | head -6
    
    echo
    # Show top processes by memory
    echo "Top Processes by Memory Usage:"
    ps aux --sort=-%mem | head -6
    
    echo
}

# Generate monitoring report
generate_monitoring_report() {
    yellow_msg 'Generating Performance Monitoring Report...'
    echo
    
    local report_file="reports/performance/monitoring/monitoring-report-$(date +%Y%m%d-%H%M%S).md"
    
    # Create reports directory if it doesn't exist
    mkdir -p "reports/performance/monitoring"
    
    # Generate report
    cat > "$report_file" << EOF
# Performance Monitoring Report

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**System**: $(uname -a)

## System Overview
- **Uptime**: $(uptime -p)
- **Load Average**: $(uptime | awk -F'load average:' '{print $2}')
- **Users**: $(who | wc -l)

## Resource Usage
### CPU
- **Cores**: $(nproc)
- **Current Usage**: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')

### Memory
$(free -h | sed 's/^/  /')

### Disk
$(df -h | sed 's/^/  /')

## Process Information
### Top CPU Processes
$(ps aux --sort=-%cpu | head -6 | sed 's/^/  /')

### Top Memory Processes
$(ps aux --sort=-%mem | head -6 | sed 's/^/  /')

## Recommendations
*Performance recommendations will be added here*

EOF
    
    green_msg "Monitoring report generated: $report_file"
}

# Continuous monitoring mode
start_continuous_monitoring() {
    yellow_msg 'Starting Continuous Performance Monitoring...'
    echo
    
    yellow_msg "Press Ctrl+C to stop monitoring"
    echo
    
    # Start monitoring loop
    while true; do
        clear
        echo "=== Performance Monitoring - $(date '+%Y-%m-%d %H:%M:%S') ==="
        echo
        
        monitor_cpu
        monitor_memory
        monitor_disk
        monitor_network
        monitor_processes
        
        echo "Monitoring will refresh in 10 seconds..."
        sleep 10
    done
}

# Main monitoring function
run_performance_monitoring() {
    yellow_msg 'Performance Monitoring Dashboard'
    echo
    
    echo "Choose monitoring option:"
    echo "1. CPU Usage"
    echo "2. Memory Usage"
    echo "3. Disk Usage"
    echo "4. Network Usage"
    echo "5. Process Monitoring"
    echo "6. Continuous Monitoring"
    echo "7. Generate Report"
    echo "8. All Monitoring"
    echo "0. Exit"
    echo
    
    read -p "Enter your choice (0-8): " choice
    
    case $choice in
        1) monitor_cpu ;;
        2) monitor_memory ;;
        3) monitor_disk ;;
        4) monitor_network ;;
        5) monitor_processes ;;
        6) start_continuous_monitoring ;;
        7) generate_monitoring_report ;;
        8) 
            monitor_cpu
            monitor_memory
            monitor_disk
            monitor_network
            monitor_processes
            generate_monitoring_report
            ;;
        0) echo "Exiting monitoring..." ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
}
