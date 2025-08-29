#!/bin/bash

# =============================================================================
# SSH Optimization Module
# =============================================================================

# Configuration is loaded centrally in main.sh

# Optimize SSH configuration
optimize_ssh() {
    yellow_msg 'Optimizing SSH Configuration...'
    echo
    sleep 0.5

    # Check OpenSSH version for compatibility
    local sshd_version=$(sshd -V 2>&1 | head -1 | grep -o 'OpenSSH_[0-9.]*' | cut -d'_' -f2)
    if [ -n "$sshd_version" ]; then
        yellow_msg "Detected OpenSSH version: $sshd_version"
        
        # Check if version is very new (potential compatibility issues)
        if [[ "$sshd_version" > "9.0" ]]; then
            yellow_msg "⚠️  Warning: Very new OpenSSH version detected"
            yellow_msg "   Some settings may need adjustment for compatibility"
        fi
    fi
    
    echo

    # Check and install SSH dependencies
    if ! check_and_install_ssh_deps; then
        red_msg "Failed to install SSH dependencies. Exiting."
        return 1
    fi

    # Get SSH configuration from settings.conf
    local ssh_port=$(get_ssh_config "port" "22")
    local ssh_users=($(get_ssh_config "allow_users" "admin"))
    local disable_password_auth=$(get_ssh_config "disable_password_auth" "true")
    local disable_root_login=$(get_ssh_config "disable_root_login" "true")
    local max_auth_tries=$(get_ssh_config "max_auth_tries" "3")
    local client_alive_interval=$(get_ssh_config "client_alive_interval" "120")
    local client_alive_count_max=$(get_ssh_config "client_alive_count_max" "3")
    
    # Advanced SSH settings
    local allow_tcp_forwarding=$(get_ssh_config "allow_tcp_forwarding" "true")
    local gateway_ports=$(get_ssh_config "gateway_ports" "true")
    local permit_tunnel=$(get_ssh_config "permit_tunnel" "true")
    local tcp_keep_alive=$(get_ssh_config "tcp_keep_alive" "true")
    local x11_forwarding=$(get_ssh_config "x11_forwarding" "false")
    local pubkey_authentication=$(get_ssh_config "pubkey_authentication" "true")
    local use_pam=$(get_ssh_config "use_pam" "false")
    local use_dns=$(get_ssh_config "use_dns" "false")
    
    # SSH algorithms and ciphers
    local pubkey_algorithms=$(get_ssh_config "pubkey_algorithms" "ssh-ed25519,rsa-sha2-256")
    local host_key_algorithms=$(get_ssh_config "host_key_algorithms" "ssh-ed25519,rsa-sha2-256")
    local kex_algorithms=$(get_ssh_config "kex_algorithms" "curve25519-sha256,diffie-hellman-group16-sha512")
    local ciphers=$(get_ssh_config "ciphers" "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com")
    local macs=$(get_ssh_config "macs" "hmac-sha2-256-etm@openssh.com")
    
    # Create backup of current SSH config
    create_backup "/etc/ssh/sshd_config"
    green_msg "Backup of SSH config created"
    
    # Apply SSH configuration
    yellow_msg "Applying SSH configuration from settings.conf..."
    
    # Update SSH port if different from default
    if [ "$ssh_port" != "22" ]; then
        yellow_msg "Setting SSH port to $ssh_port..."
        sed -i "s/^#Port 22/Port $ssh_port/" /etc/ssh/sshd_config
        sed -i "s/^Port [0-9]*/Port $ssh_port/" /etc/ssh/sshd_config
        if ! grep -q "^Port $ssh_port" /etc/ssh/sshd_config; then
            echo "Port $ssh_port" >> /etc/ssh/sshd_config
        fi
        green_msg "SSH port set to $ssh_port"
    fi
    
    # Apply basic security settings
    yellow_msg "Applying SSH security settings..."
    
    # Password authentication
    if [ "$disable_password_auth" = "true" ]; then
        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        green_msg "Password authentication disabled"
    fi
    
    # Root login
    if [ "$disable_root_login" = "true" ]; then
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        green_msg "Root login disabled"
    fi
    
    # Max auth tries
    sed -i "s/^#*MaxAuthTries.*/MaxAuthTries $max_auth_tries/" /etc/ssh/sshd_config
    green_msg "Max auth tries set to $max_auth_tries"
    
    # Client alive settings
    sed -i "s/^#*ClientAliveInterval.*/ClientAliveInterval $client_alive_interval/" /etc/ssh/sshd_config
    sed -i "s/^#*ClientAliveCountMax.*/ClientAliveCountMax $client_alive_count_max/" /etc/ssh/sshd_config
    green_msg "Client alive settings configured"
    
    # Allow specific users
    if [ ${#ssh_users[@]} -gt 0 ]; then
        local users_str=$(IFS=' '; echo "${ssh_users[*]}")
        sed -i 's/^#*AllowUsers.*/AllowUsers '"$users_str"'/' /etc/ssh/sshd_config
        if ! grep -q "^AllowUsers" /etc/ssh/sshd_config; then
            echo "AllowUsers $users_str" >> /etc/ssh/sshd_config
        fi
        green_msg "Allowed users: $users_str"
    fi
    
    # Apply advanced SSH settings
    yellow_msg "Applying advanced SSH settings..."
    
    # TCP forwarding
    if [ "$allow_tcp_forwarding" = "true" ]; then
        sed -i 's/^#*AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
        green_msg "TCP forwarding enabled"
    else
        sed -i 's/^#*AllowTcpForwarding.*/AllowTcpForwarding no/' /etc/ssh/sshd_config
        green_msg "TCP forwarding disabled"
    fi
    
    # Gateway ports
    if [ "$gateway_ports" = "true" ]; then
        sed -i 's/^#*GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config
        green_msg "Gateway ports enabled"
    else
        sed -i 's/^#*GatewayPorts.*/GatewayPorts no/' /etc/ssh/sshd_config
        green_msg "Gateway ports disabled"
    fi
    
    # Permit tunnel
    if [ "$permit_tunnel" = "true" ]; then
        sed -i 's/^#*PermitTunnel.*/PermitTunnel yes/' /etc/ssh/sshd_config
        green_msg "Tunnel forwarding enabled"
    else
        sed -i 's/^#*PermitTunnel.*/PermitTunnel no/' /etc/ssh/sshd_config
        green_msg "Tunnel forwarding disabled"
    fi
    
    # TCP keep alive
    if [ "$tcp_keep_alive" = "true" ]; then
        sed -i 's/^#*TCPKeepAlive.*/TCPKeepAlive yes/' /etc/ssh/sshd_config
        green_msg "TCP keep alive enabled"
    else
        sed -i 's/^#*TCPKeepAlive.*/TCPKeepAlive no/' /etc/ssh/sshd_config
        green_msg "TCP keep alive disabled"
    fi
    
    # X11 forwarding
    if [ "$x11_forwarding" = "true" ]; then
        sed -i 's/^#*X11Forwarding.*/X11Forwarding yes/' /etc/ssh/sshd_config
        green_msg "X11 forwarding enabled"
    else
        sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
        green_msg "X11 forwarding disabled"
    fi
    
    # Public key authentication
    if [ "$pubkey_authentication" = "true" ]; then
        sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        green_msg "Public key authentication enabled"
    else
        sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication no/' /etc/ssh/sshd_config
        green_msg "Public key authentication disabled"
    fi
    
    # Use PAM
    if [ "$use_pam" = "true" ]; then
        sed -i 's/^#*UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
        green_msg "PAM authentication enabled"
    else
        sed -i 's/^#*UsePAM.*/UsePAM no/' /etc/ssh/sshd_config
        green_msg "PAM authentication disabled"
    fi
    
    # Use DNS
    if [ "$use_dns" = "true" ]; then
        sed -i 's/^#*UseDNS.*/UseDNS yes/' /etc/ssh/sshd_config
        green_msg "DNS resolution enabled"
    else
        sed -i 's/^#*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config
        green_msg "DNS resolution disabled"
    fi
    
    # Apply SSH algorithms and ciphers
    yellow_msg "Applying SSH algorithms and ciphers..."
    
    # Public key algorithms
    sed -i "s/^#*PubkeyAcceptedAlgorithms.*/PubkeyAcceptedAlgorithms $pubkey_algorithms/" /etc/ssh/sshd_config
    if ! grep -q "^PubkeyAcceptedAlgorithms" /etc/ssh/sshd_config; then
        echo "PubkeyAcceptedAlgorithms $pubkey_algorithms" >> /etc/ssh/sshd_config
    fi
    green_msg "Public key algorithms configured"
    
    # Host key algorithms
    sed -i "s/^#*HostKeyAlgorithms.*/HostKeyAlgorithms $host_key_algorithms/" /etc/ssh/sshd_config
    if ! grep -q "^HostKeyAlgorithms" /etc/ssh/sshd_config; then
        echo "HostKeyAlgorithms $host_key_algorithms" >> /etc/ssh/sshd_config
    fi
    green_msg "Host key algorithms configured"
    
    # Key exchange algorithms
    sed -i "s/^#*KexAlgorithms.*/KexAlgorithms $kex_algorithms/" /etc/ssh/sshd_config
    if ! grep -q "^KexAlgorithms" /etc/ssh/sshd_config; then
        echo "KexAlgorithms $kex_algorithms" >> /etc/ssh/sshd_config
    fi
    green_msg "Key exchange algorithms configured"
    
    # Ciphers
    sed -i "s/^#*Ciphers.*/Ciphers $ciphers/" /etc/ssh/sshd_config
    if ! grep -q "^Ciphers" /etc/ssh/sshd_config; then
        echo "Ciphers $ciphers" >> /etc/ssh/sshd_config
    fi
    green_msg "Ciphers configured"
    
    # MACs
    sed -i "s/^#*MACs.*/MACs $macs/" /etc/ssh/sshd_config
    if ! grep -q "^MACs" /etc/ssh/sshd_config; then
        echo "MACs $macs" >> /etc/ssh/sshd_config
    fi
    green_msg "MACs configured"
    
    # Test SSH configuration
    yellow_msg "Testing SSH configuration..."
    if sshd -t; then
        green_msg "SSH configuration is valid"
    else
        red_msg "SSH configuration has errors"
        red_msg "Attempting to restore from backup..."
        
        # Restore from backup if test fails
        if [ -f "/etc/ssh/sshd_config.backup" ]; then
            cp "/etc/ssh/sshd_config.backup" "/etc/ssh/sshd_config"
            yellow_msg "Restored SSH config from backup"
            
            # Test again
            if sshd -t; then
                green_msg "Restored configuration is valid"
            else
                red_msg "Restored configuration also has errors"
                return 1
            fi
        else
            red_msg "No backup found, cannot restore"
            return 1
        fi
    fi
    
    # Restart SSH service safely
    yellow_msg "Restarting SSH service..."
    
    # Try to restart SSH service
    if systemctl restart ssh; then
        green_msg "SSH service restarted successfully"
        
        # Wait a moment and check if service is actually running
        sleep 2
        if systemctl is-active --quiet ssh; then
            green_msg "✅ SSH service is running and stable"
        else
            red_msg "❌ SSH service failed to start properly"
            red_msg "Attempting to restore from backup..."
            
            # Restore from backup if service fails
            if [ -f "/etc/ssh/sshd_config.backup" ]; then
                cp "/etc/ssh/sshd_config.backup" "/etc/ssh/sshd_config"
                yellow_msg "Restored SSH config from backup"
                
                # Try to start service again
                if systemctl start ssh; then
                    green_msg "✅ SSH service started with restored configuration"
                else
                    red_msg "❌ SSH service still fails with restored configuration"
                    return 1
                fi
            else
                red_msg "No backup found, cannot restore"
                return 1
            fi
        fi
    else
        red_msg "Failed to restart SSH service"
        return 1
    fi
    
    # Show SSH status
    show_ssh_status
    
    # Enable and start SSH service
    yellow_msg "Enabling and starting SSH service..."
    if enable_services "ssh"; then
        green_msg "✅ SSH service enabled and started successfully"
    else
        red_msg "❌ Failed to enable/start SSH service"
    fi
    
    green_msg "SSH optimization completed successfully!"
    echo
    sleep 0.5
}

# Get SSH port from configuration
get_ssh_port() {
    local port=$(get_ssh_config "port" "22")
    echo "$port"
}

# Show SSH status
show_ssh_status() {
    yellow_msg 'SSH Service Status:'
    echo
    
    # Service status
    if systemctl is-active --quiet ssh; then
        green_msg "SSH Service: ACTIVE"
    else
        red_msg "SSH Service: INACTIVE"
    fi
    
    # SSH port
    local ssh_port=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}' | head -1)
    echo "SSH Port: ${ssh_port:-22}"
    
    # Password authentication
    if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
        echo "Password Auth: DISABLED"
    else
        echo "Password Auth: ENABLED"
    fi
    
    # Root login
    if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
        echo "Root Login: DISABLED"
    else
        echo "Root Login: ENABLED"
    fi
    
    # Allowed users
    local allowed_users=$(grep "^AllowUsers" /etc/ssh/sshd_config | awk '{$1=""; print $0}' | sed 's/^ *//')
    if [ -n "$allowed_users" ]; then
        echo "Allowed Users: $allowed_users"
    fi
    
    echo
}
