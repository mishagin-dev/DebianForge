#!/bin/bash

# =============================================================================
# Sysctl Module - Kernel parameter configuration management
# =============================================================================

# Configuration is loaded centrally in main.sh

# Apply sysctl configurations
apply_sysctl() {
    yellow_msg 'Applying Sysctl Configurations...'
    echo
    sleep 0.5

    # Create backup of current sysctl.conf
    create_backup "/etc/sysctl.conf"
    green_msg "Backup of sysctl.conf created"
    
    # Copy all sysctl configurations except BBR and IPv6
    copy_sysctl_configs
    
    # Apply IPv6 settings if disabled in configuration
    local disable_ipv6=$(get_config "DISABLE_IPV6" "false")
    if [ "$disable_ipv6" = "true" ]; then
        yellow_msg "IPv6 is disabled in configuration, applying IPv6 disable settings..."
        copy_ipv6_disable_config
    else
        yellow_msg "IPv6 is enabled in configuration, skipping IPv6 disable settings"
    fi
    
    # Apply all sysctl.d configurations
    yellow_msg "Applying sysctl.d configurations..."
    if sysctl --system >/dev/null 2>&1; then
        green_msg "✅ All sysctl parameters applied successfully"
    else
        yellow_msg "⚠️  Some sysctl parameters may not have been applied"
        yellow_msg "   Check system logs for details"
    fi
    
    green_msg "Sysctl configurations applied successfully!"
    echo
    sleep 0.5
}

# Copy all sysctl configurations except BBR and IPv6
copy_sysctl_configs() {
    yellow_msg "Copying sysctl configurations..."
    
    # Check if sysctl.d source directory exists
    local source_dir="resources/sysctl.d"
    if [ ! -d "$source_dir" ]; then
        red_msg "Sysctl source directory not found: $source_dir"
        return 1
    fi
    
    # Copy all .conf files except BBR and IPv6
    local copied_count=0
    for config_file in "$source_dir"/*.conf; do
        if [ -f "$config_file" ]; then
            local filename=$(basename "$config_file")
            
            # Skip BBR and IPv6 configurations
            if [[ "$filename" == *"bbr"* ]] || [[ "$filename" == *"ipv6"* ]]; then
                yellow_msg "Skipping $filename (BBR or IPv6 configuration)"
                continue
            fi
            
            # Copy configuration to system
            cp "$config_file" "/etc/sysctl.d/"
            green_msg "Copied: $filename"
            ((copied_count++))
        fi
    done
    
    if [ $copied_count -gt 0 ]; then
        green_msg "Copied $copied_count sysctl configuration files"
        
        # Apply the copied configurations immediately
        yellow_msg "Applying copied sysctl configurations..."
        if sysctl --system >/dev/null 2>&1; then
            green_msg "✅ Copied sysctl parameters applied successfully"
        else
            yellow_msg "⚠️  Some copied sysctl parameters may not have been applied"
        fi
    else
        yellow_msg "No sysctl configuration files to copy"
    fi
}

# Copy IPv6 disable configuration
copy_ipv6_disable_config() {
    local ipv6_config="resources/sysctl.d/80-ipv6-disable.conf"
    
    if [ -f "$ipv6_config" ]; then
        cp "$ipv6_config" "/etc/sysctl.d/"
        green_msg "IPv6 disable configuration applied"
        
        # Apply IPv6 disable configuration immediately
        yellow_msg "Applying IPv6 disable configuration..."
        if sysctl --system >/dev/null 2>&1; then
            green_msg "✅ IPv6 disable parameters applied successfully"
        else
            yellow_msg "⚠️  IPv6 disable parameters may not have been applied"
        fi
    else
        red_msg "IPv6 disable configuration file not found: $ipv6_config"
        return 1
    fi
}

# Apply BBR configuration after XanMod kernel installation
apply_bbr_after_xanmod() {
    yellow_msg "Applying BBR configuration after XanMod kernel installation..."
    
    # Check if BBR config file exists
    local bbr_config="resources/sysctl.d/90-bbr.conf"
    
    if [ -f "$bbr_config" ]; then
        # Copy BBR configuration to system
        cp "$bbr_config" "/etc/sysctl.d/"
        green_msg "BBR configuration applied"
        
        # Apply all sysctl.d configurations including BBR
        yellow_msg "Applying sysctl.d configurations for BBR..."
        if sysctl --system >/dev/null 2>&1; then
            green_msg "✅ BBR configuration loaded successfully"
        else
            yellow_msg "⚠️  BBR configuration may not have been applied"
            yellow_msg "   Check system logs for details"
        fi
    else
        red_msg "BBR configuration file not found: $bbr_config"
        return 1
    fi
    
    echo
}

# Show current sysctl settings
show_sysctl_status() {
    yellow_msg 'Current Sysctl Status:'
    echo
    
    echo "Applied Configuration Files:"
    if [ -d "/etc/sysctl.d" ]; then
        for config_file in /etc/sysctl.d/*.conf; do
            if [ -f "$config_file" ]; then
                local filename=$(basename "$config_file")
                echo "  📄 $filename"
            fi
        done
    else
        echo "  ❌ No sysctl.d directory found"
    fi
    
    echo
    echo "IPv6 Status:"
    if [ "$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null)" = "1" ]; then
        echo "  ✅ IPv6 disabled"
    else
        echo "  ❌ IPv6 enabled"
    fi
    
    echo
    echo "BBR Congestion Control:"
    if [ "$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)" = "bbr" ]; then
        echo "  ✅ BBR enabled"
    else
        echo "  ❌ BBR not enabled"
    fi
    
    echo
    echo "File Descriptor Limits:"
    echo "  Current: $(sysctl -n fs.file-max 2>/dev/null || echo 'Not set')"
    
    echo
    echo "Network Optimizations:"
    echo "  TCP max syn backlog: $(sysctl -n net.ipv4.tcp_max_syn_backlog 2>/dev/null || echo 'Not set')"
    echo "  TCP max tw buckets: $(sysctl -n net.ipv4.tcp_max_tw_buckets 2>/dev/null || echo 'Not set')"
    
    echo
    echo "Sysctl Application Status:"
    echo "  Last applied: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "  Method: sysctl --system (applies all /etc/sysctl.d/*.conf files)"
    
    echo
}
