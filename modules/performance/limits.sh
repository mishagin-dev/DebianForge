#!/bin/bash

# =============================================================================
# Limits Module - System limits configuration management
# =============================================================================

# Configuration is loaded centrally in main.sh

# Configuration paths
LIMITS_CONF="/etc/security/limits.conf"
PROFILE_FILE="/etc/profile"
SYSTEMD_CONF_DIR="/etc/systemd/system.conf.d"
SYSTEMD_CONF_FILE="$SYSTEMD_CONF_DIR/99-custom-limits.conf"
LIMITS_SOURCE_DIR="resources/limits.d"

# Configure system limits
configure_limits() {
    yellow_msg 'Configuring System Limits...'
    echo
    sleep 0.5

    # Check if limits.d source directory exists
    if [ ! -d "$LIMITS_SOURCE_DIR" ]; then
        red_msg "❌ Error: Limits source directory not found: $LIMITS_SOURCE_DIR"
        red_msg "   Please ensure the limits.d directory exists with configuration files"
        return 1
    fi
    
    # Check if there are any .conf files in the source directory
    local config_files=$(find "$LIMITS_SOURCE_DIR" -name "*.conf" 2>/dev/null | wc -l)
    if [ "$config_files" -eq 0 ]; then
        red_msg "❌ Error: No configuration files found in $LIMITS_SOURCE_DIR"
        red_msg "   Please ensure there are .conf files in the limits.d directory"
        return 1
    fi
    
    green_msg "Found $config_files configuration files in $LIMITS_SOURCE_DIR"

    # Create backup of current limits.conf
    create_backup "$LIMITS_CONF"
    green_msg "Backup of limits.conf created"
    
    # Check /etc/profile for ulimit commands to avoid conflicts
    check_profile_for_ulimits
    
    # Apply limits configurations from limits.d
    apply_limits_configs
    
    # Apply kernel limits from sysctl configuration
    apply_kernel_limits
    
    # Create systemd configuration for service limits
    create_systemd_limits_config
    
    # Reload limits
    yellow_msg "Reloading system limits..."
    
    # Check if sysctl.conf exists before trying to reload
    if [ -f "/etc/sysctl.conf" ]; then
        sysctl -p
        green_msg "✅ Sysctl configuration reloaded from /etc/sysctl.conf"
    else
        yellow_msg "⚠️  /etc/sysctl.conf not found, skipping sysctl -p"
        yellow_msg "   Kernel parameters will be loaded from sysctl.d files"
    fi
    
    # Re-execute systemd daemon to apply new limits
    yellow_msg "Re-executing systemd daemon to apply new limits..."
    systemctl daemon-reexec
    
    green_msg "System limits configured successfully!"
    echo
    sleep 0.5
}

# Check /etc/profile for ulimit commands to avoid conflicts
check_profile_for_ulimits() {
    yellow_msg "Checking /etc/profile for ulimit commands..."
    
    if [ -f "$PROFILE_FILE" ]; then
        if grep -q "ulimit" "$PROFILE_FILE" 2>/dev/null; then
            yellow_msg "Found ulimit commands in $PROFILE_FILE"
            echo "Consider removing them to avoid conflicts with system limits:"
            grep -n "ulimit" "$PROFILE_FILE" | head -5
            echo
            yellow_msg "System limits will override profile ulimit settings"
        else
            green_msg "No ulimit commands found in $PROFILE_FILE"
        fi
    else
        yellow_msg "Profile file not found: $PROFILE_FILE"
    fi
    
    echo
}

# Apply limits configurations from limits.d
apply_limits_configs() {
    yellow_msg "Applying limits configurations..."
    
    # Check if limits.d source directory exists
    if [ ! -d "$LIMITS_SOURCE_DIR" ]; then
        red_msg "Limits source directory not found: $LIMITS_SOURCE_DIR"
        return 1
    fi
    
    # Create system limits.d directory if it doesn't exist
    mkdir -p "/etc/security/limits.d"
    
    # Copy all .conf files to /etc/security/limits.d/
    local copied_count=0
    local replaced_count=0
    
    for config_file in "$LIMITS_SOURCE_DIR"/*.conf; do
        if [ -f "$config_file" ]; then
            local filename=$(basename "$config_file")
            local target_file="/etc/security/limits.d/$filename"
            
            # Check if target file already exists
            if [ -f "$target_file" ]; then
                yellow_msg "⚠️  Target file exists: $filename"
                
                # Create backup of existing file
                create_backup "$target_file"
                
                # Remove original to avoid conflicts
                rm "$target_file"
                yellow_msg "  Removed original: $filename"
                replaced_count=$((replaced_count + 1))
            fi
            
            # Copy limits configuration to system
            cp "$config_file" "$target_file"
            green_msg "✅ Applied: $filename"
            copied_count=$((copied_count + 1))
        fi
    done
    
    if [ $copied_count -gt 0 ]; then
        green_msg "Applied $copied_count limits configuration files"
        if [ $replaced_count -gt 0 ]; then
            yellow_msg "Replaced $replaced_count existing files (backups created)"
        fi
    else
        yellow_msg "No limits configuration files to apply"
    fi
    
    echo
}

# Apply kernel limits from sysctl configuration
apply_kernel_limits() {
    yellow_msg "Applying kernel limits..."
    
    # Kernel limits are now handled by sysctl.d configuration files
    # All kernel parameters are distributed across specialized sysctl.d files
    green_msg "Kernel limits configuration is handled by specialized sysctl.d files"
}

# Create systemd configuration for service limits
create_systemd_limits_config() {
    yellow_msg "Creating systemd limits configuration..."
    
    # Create systemd configuration directory
    mkdir -p "$SYSTEMD_CONF_DIR"
    
    # Copy systemd limits configuration from limits.d
    local systemd_config="$LIMITS_SOURCE_DIR/99-systemd-limits.conf"
    
    if [ -f "$systemd_config" ]; then
        # Check if target file already exists
        if [ -f "$SYSTEMD_CONF_FILE" ]; then
            yellow_msg "⚠️  Systemd limits config exists: $(basename "$SYSTEMD_CONF_FILE")"
            
            # Create backup of existing file
            create_backup "$SYSTEMD_CONF_FILE"
            
            # Remove original to avoid conflicts
            rm "$SYSTEMD_CONF_FILE"
            yellow_msg "  Removed original systemd limits config"
        fi
        
        # Copy new configuration
        cp "$systemd_config" "$SYSTEMD_CONF_FILE"
        green_msg "✅ Systemd limits configuration applied: $SYSTEMD_CONF_FILE"
    else
        red_msg "Systemd limits configuration file not found: $systemd_config"
        return 1
    fi
    
    echo
}

# Show current limits status
show_limits_status() {
    yellow_msg 'Current System Limits Status:'
    echo
    
    echo "Applied Limits Configuration Files:"
    if [ -d "/etc/security/limits.d" ]; then
        for config_file in /etc/security/limits.d/*.conf; do
            if [ -f "$config_file" ]; then
                local filename=$(basename "$config_file")
                echo "  📄 $filename"
            fi
        done
    else
        echo "  ❌ No limits.d directory found"
    fi
    
    echo
    echo "Systemd Limits Configuration:"
    if [ -f "$SYSTEMD_CONF_FILE" ]; then
        echo "  ✅ $SYSTEMD_CONF_FILE"
    else
        echo "  ❌ Systemd limits configuration not found"
    fi
    
    echo
    echo "Current File Descriptor Limits:"
    echo "  Soft limit: $(ulimit -n)"
    echo "  Hard limit: $(ulimit -Hn)"
    
    echo
    echo "Current Process Limits:"
    echo "  Soft limit: $(ulimit -u)"
    echo "  Hard limit: $(ulimit -Hu)"
    
    echo
    echo "Current Stack Limits:"
    echo "  Soft limit: $(ulimit -s)"
    echo "  Hard limit: $(ulimit -Hs)"
    
    echo
    echo "Kernel Limits:"
    echo "  File max: $(sysctl -n fs.file-max 2>/dev/null || echo 'Not set')"
    echo "  PID max: $(sysctl -n kernel.pid_max 2>/dev/null || echo 'Not set')"
    echo "  Threads max: $(sysctl -n kernel.threads-max 2>/dev/null || echo 'Not set')"
    
    echo
    echo "Sysctl Configuration:"
    if [ -f "/etc/sysctl.conf" ]; then
        echo "  ✅ /etc/sysctl.conf exists"
    else
        echo "  ⚠️  /etc/sysctl.conf not found (using sysctl.d files)"
    fi
    
    # Check for sysctl.d files
    local sysctl_files=$(find /etc/sysctl.d -name "*.conf" 2>/dev/null | wc -l)
    if [ "$sysctl_files" -gt 0 ]; then
        echo "  📁 /etc/sysctl.d: $sysctl_files configuration files"
    else
        echo "  ❌ No sysctl.d configuration files found"
    fi
    
    echo
    echo "Profile ulimit Commands:"
    if [ -f "$PROFILE_FILE" ] && grep -q "ulimit" "$PROFILE_FILE"; then
        echo "  ⚠️  Found ulimit commands in $PROFILE_FILE"
        echo "  These may conflict with system limits"
    else
        echo "  ✅ No ulimit commands found in profile"
    fi
    
    echo
}
