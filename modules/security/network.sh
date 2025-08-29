#!/bin/bash

# =============================================================================
# Audit Network Module - Network security and connection analysis
# =============================================================================

# Configuration is loaded centrally in main.sh

# Check network security
check_network_security() {
    local report_file="$1"
    
    echo "=== Network Security ===" >> "$report_file"
    
    # Check open ports
    if command_exists ss; then
        local open_ports=$(ss -tln | grep -v "127.0.0.1" | wc -l)
        echo "Open Network Ports: $open_ports" >> "$report_file"
    elif command_exists netstat; then
        local open_ports=$(netstat -tln | grep -v "127.0.0.1" | wc -l)
        echo "Open Network Ports: $open_ports" >> "$report_file"
    else
        echo "Open Network Ports: Unable to check [WARN]" >> "$report_file"
    fi
    
    # Check listening services
    echo "Listening Services:" >> "$report_file"
    if command_exists ss; then
        ss -tln | grep -v "127.0.0.1" | head -10 >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Check network connections
check_network_connections() {
    local report_file="$1"
    
    echo "=== Network Connections ===" >> "$report_file"
    
    # Check active connections
    if command_exists ss; then
        local tcp_connections=$(ss -t | grep -v "State" | wc -l)
        local udp_connections=$(ss -u | grep -v "State" | wc -l)
        
        echo "Active TCP Connections: $tcp_connections" >> "$report_file"
        echo "Active UDP Connections: $udp_connections" >> "$report_file"
        
        # Show top connections
        echo "Top TCP Connections:" >> "$report_file"
        ss -t | head -5 >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Check DNS security
check_dns_security() {
    local report_file="$1"
    
    echo "=== DNS Security ===" >> "$report_file"
    
    # Check DNS servers
    if [ -f "/etc/resolv.conf" ]; then
        echo "DNS Servers:" >> "$report_file"
        grep "^nameserver" /etc/resolv.conf | while read line; do
            echo "  - $line" >> "$report_file"
        done
    fi
    
    # Check DNS over HTTPS support
    if command_exists dig; then
        echo "DNS over HTTPS Test:" >> "$report_file"
        if dig +https @1.1.1.1 google.com >/dev/null 2>&1; then
            echo "  - DoH supported [PASS]" >> "$report_file"
        else
            echo "  - DoH not supported [INFO]" >> "$report_file"
        fi
    fi
    
    echo "" >> "$report_file"
}

# Check network interfaces
check_network_interfaces() {
    local report_file="$1"
    
    echo "=== Network Interfaces ===" >> "$report_file"
    
    # Check interface status
    if command_exists ip; then
        echo "Network Interfaces:" >> "$report_file"
        ip addr show | grep -E "^[0-9]+:" | while read line; do
            echo "  - $line" >> "$report_file"
        done
    fi
    
    # Check routing table
    echo "Routing Table:" >> "$report_file"
    if command_exists ip; then
        ip route show | head -5 >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Check network traffic patterns
check_network_traffic() {
    local report_file="$1"
    
    echo "=== Network Traffic Analysis ===" >> "$report_file"
    
    # Check interface statistics
    if [ -f "/proc/net/dev" ]; then
        echo "Interface Statistics:" >> "$report_file"
        cat /proc/net/dev | grep -E "(eth|en|wlan)" | while read line; do
            local interface=$(echo "$line" | awk '{print $1}' | sed 's/://')
            local rx_bytes=$(echo "$line" | awk '{print $2}')
            local tx_bytes=$(echo "$line" | awk '{print $10}')
            echo "  - $interface: RX: $rx_bytes, TX: $tx_bytes" >> "$report_file"
        done
    fi
    
    echo "" >> "$report_file"
}

# Check firewall rules
check_firewall_rules() {
    local report_file="$1"
    
    echo "=== Firewall Rules Analysis ===" >> "$report_file"
    
    # Check UFW rules
    if command_exists ufw; then
        local ufw_status=$(ufw status | grep "Status:" | awk '{print $2}')
        echo "UFW Status: $ufw_status" >> "$report_file"
        
        if [ "$ufw_status" = "active" ]; then
            echo "UFW Rules:" >> "$report_file"
            ufw status numbered | grep -E "(ALLOW|DENY)" | head -10 >> "$report_file"
        fi
    fi
    
    # Check iptables rules
    if command_exists iptables; then
        echo "IPTables Rules:" >> "$report_file"
        iptables -L -n | head -10 >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}
