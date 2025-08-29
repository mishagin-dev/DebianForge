#!/bin/bash

# =============================================================================
# Config Module - Configuration management and parsing
# =============================================================================

# Configuration file path
CONFIG_FILE="resources/config/settings.conf"

# Load configuration from bash-compatible file
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        red_msg "Configuration file not found: $CONFIG_FILE"
        return 1
    fi
    
    # Source the configuration file
    if source "$CONFIG_FILE" 2>/dev/null; then
        green_msg "Configuration loaded successfully from $CONFIG_FILE"
        
        # Verify critical arrays are loaded
        if [ ${#TIMEZONE_IP_SOURCES[@]} -eq 0 ]; then
            red_msg "Warning: TIMEZONE_IP_SOURCES array is empty after loading"
        else
            green_msg "Timezone sources loaded: ${#TIMEZONE_IP_SOURCES[@]} sources"
        fi
        
        # Export all configuration variables for child processes
        export_config_variables
        
        return 0
    else
        red_msg "Failed to load configuration from $CONFIG_FILE"
        return 1
    fi
}

# Export configuration variables for use in all modules
export_config_variables() {
    # System settings
    export SSH_PORT SSH_ALLOW_USERS SSH_DISABLE_PASSWORD_AUTH SSH_DISABLE_ROOT_LOGIN
    export SSH_MAX_AUTH_TRIES SSH_CLIENT_ALIVE_INTERVAL SSH_CLIENT_ALIVE_COUNT_MAX
    export SSH_ALLOW_TCP_FORWARDING SSH_GATEWAY_PORTS SSH_PERMIT_TUNNEL SSH_TCP_KEEP_ALIVE
    export SSH_X11_FORWARDING SSH_PUBKEY_AUTHENTICATION SSH_USE_PAM SSH_USE_DNS
    export SSH_PUBKEY_ALGORITHMS SSH_HOST_KEY_ALGORITHMS SSH_KEX_ALGORITHMS SSH_CIPHERS SSH_MACS
    
    # Swap settings
    export SWAP_SIZE SWAP_PATH
    
    # IPv6 settings
    export DISABLE_IPV6
    
    # UFW settings
    export UFW_DEFAULT_POLICY UFW_STRICT_MODE UFW_ALLOW_PORTS UFW_ALLOW_ICMP UFW_ICMP_TYPES
    
    # System limits
    export LIMITS_NOFILE LIMITS_STACK_SOFT LIMITS_STACK_HARD
    
    # XanMod settings
    export XANMOD_AUTO_DETECT_CPU XANMOD_FORCE_CPU_LEVEL
    
    # Timezone settings
    export TIMEZONE_FALLBACK TIMEZONE_CONSENSUS_THRESHOLD
    # Note: Arrays cannot be exported directly in bash
    # TIMEZONE_IP_SOURCES and TIMEZONE_FALLBACK_LIST will be available through sourcing
    
    green_msg "Configuration variables exported for all modules"
}

# Get configuration value with default
get_config() {
    local var_name="$1"
    local default="$2"
    
    if [ -n "${!var_name}" ]; then
        echo "${!var_name}"
    else
        echo "$default"
    fi
}

# Get system configuration
get_system_config() {
    local key="$1"
    local default="$2"
    
    case "$key" in
        "ssh_port")
            echo "${SSH_PORT:-$default}"
            ;;
        "swap_size")
            echo "${SWAP_SIZE:-$default}"
            ;;
        "swap_path")
            echo "${SWAP_PATH:-$default}"
            ;;
        "disable_ipv6")
            echo "${DISABLE_IPV6:-$default}"
            ;;
        *)
            echo "$default"
            ;;
    esac
}

# Get UFW configuration
get_ufw_config() {
    local key="$1"
    local default="$2"
    
    case "$key" in
        "default_policy")
            echo "${UFW_DEFAULT_POLICY:-$default}"
            ;;
        "strict_mode")
            echo "${UFW_STRICT_MODE:-$default}"
            ;;
        "allow_icmp")
            echo "${UFW_ALLOW_ICMP:-$default}"
            ;;
        "allow_ports")
            echo "${UFW_ALLOW_PORTS[@]:-$default}"
            ;;
        "icmp_types")
            echo "${UFW_ICMP_TYPES[@]:-$default}"
            ;;
        *)
            echo "$default"
            ;;
    esac
}

# Get SSH configuration
get_ssh_config() {
    local key="$1"
    local default="$2"
    
    case "$key" in
        "port")
            echo "${SSH_PORT:-$default}"
            ;;
        "allow_users")
            echo "${SSH_ALLOW_USERS[*]:-$default}"
            ;;
        "disable_password_auth")
            echo "${SSH_DISABLE_PASSWORD_AUTH:-$default}"
            ;;
        "disable_root_login")
            echo "${SSH_DISABLE_ROOT_LOGIN:-$default}"
            ;;
        "max_auth_tries")
            echo "${SSH_MAX_AUTH_TRIES:-$default}"
            ;;
        "client_alive_interval")
            echo "${SSH_CLIENT_ALIVE_INTERVAL:-$default}"
            ;;
        "client_alive_count_max")
            echo "${SSH_CLIENT_ALIVE_COUNT_MAX:-$default}"
            ;;
        "allow_tcp_forwarding")
            echo "${SSH_ALLOW_TCP_FORWARDING:-$default}"
            ;;
        "gateway_ports")
            echo "${SSH_GATEWAY_PORTS:-$default}"
            ;;
        "permit_tunnel")
            echo "${SSH_PERMIT_TUNNEL:-$default}"
            ;;
        "tcp_keep_alive")
            echo "${SSH_TCP_KEEP_ALIVE:-$default}"
            ;;
        "x11_forwarding")
            echo "${SSH_X11_FORWARDING:-$default}"
            ;;
        "pubkey_authentication")
            echo "${SSH_PUBKEY_AUTHENTICATION:-$default}"
            ;;
        "use_pam")
            echo "${SSH_USE_PAM:-$default}"
            ;;
        "use_dns")
            echo "${SSH_USE_DNS:-$default}"
            ;;
        "pubkey_algorithms")
            echo "${SSH_PUBKEY_ALGORITHMS:-$default}"
            ;;
        "host_key_algorithms")
            echo "${SSH_HOST_KEY_ALGORITHMS:-$default}"
            ;;
        "kex_algorithms")
            echo "${SSH_KEX_ALGORITHMS:-$default}"
            ;;
        "ciphers")
            echo "${SSH_CIPHERS:-$default}"
            ;;
        "macs")
            echo "${SSH_MACS:-$default}"
            ;;
        *)
            echo "$default"
            ;;
    esac
}

# Get limits configuration
get_limits_config() {
    local key="$1"
    local default="$2"
    
    case "$key" in
        "nofile")
            echo "${LIMITS_NOFILE:-$default}"
            ;;
        "stack_soft")
            echo "${LIMITS_STACK_SOFT:-$default}"
            ;;
        "stack_hard")
            echo "${LIMITS_STACK_HARD:-$default}"
            ;;
        *)
            echo "$default"
            ;;
    esac
}

# Get XanMod configuration
get_xanmod_config() {
    local key="$1"
    local default="$2"
    
    case "$key" in
        "auto_detect_cpu")
            echo "${XANMOD_AUTO_DETECT_CPU:-$default}"
            ;;
        "force_cpu_level")
            echo "${XANMOD_FORCE_CPU_LEVEL:-$default}"
            ;;
        *)
            echo "$default"
            ;;
    esac
}

# Get timezone configuration
get_timezone_config() {
    local key="$1"
    local default="$2"
    
    case "$key" in
        "fallback_timezone")
            echo "${TIMEZONE_FALLBACK:-$default}"
            ;;
        "ip_sources")
            echo "${TIMEZONE_IP_SOURCES[@]:-$default}"
            ;;
        *)
            echo "$default"
            ;;
    esac
}

# Get audit configuration
get_audit_config() {
    local key="$1"
    local default="$2"
    
    case "$key" in
        "report_directory")
            echo "${AUDIT_REPORT_DIR:-$default}"
            ;;
        "include_system_info")
            echo "${AUDIT_INCLUDE_SYSTEM_INFO:-$default}"
            ;;
        "include_security_check")
            echo "${AUDIT_INCLUDE_SECURITY_CHECK:-$default}"
            ;;
        "include_resource_check")
            echo "${AUDIT_INCLUDE_RESOURCE_CHECK:-$default}"
            ;;
        "include_network_check")
            echo "${AUDIT_INCLUDE_NETWORK_CHECK:-$default}"
            ;;
        "deep_scan")
            echo "${AUDIT_DEEP_SCAN:-$default}"
            ;;
        "check_critical_files")
            echo "${AUDIT_CHECK_CRITICAL_FILES:-$default}"
            ;;
        "check_processes")
            echo "${AUDIT_CHECK_PROCESSES:-$default}"
            ;;
        "check_logs")
            echo "${AUDIT_CHECK_LOGS:-$default}"
            ;;
        "check_integrity")
            echo "${AUDIT_CHECK_INTEGRITY:-$default}"
            ;;
        "check_user_security")
            echo "${AUDIT_CHECK_USER_SECURITY:-$default}"
            ;;
        "check_cron_security")
            echo "${AUDIT_CHECK_CRON_SECURITY:-$default}"
            ;;
        "check_network_connections")
            echo "${AUDIT_CHECK_NETWORK_CONNECTIONS:-$default}"
            ;;
        "check_dns_security")
            echo "${AUDIT_CHECK_DNS_SECURITY:-$default}"
            ;;
        "check_autostart_services")
            echo "${AUDIT_CHECK_AUTOSTART_SERVICES:-$default}"
            ;;
        "report_format")
            echo "${AUDIT_REPORT_FORMAT:-$default}"
            ;;
        "email_reports")
            echo "${AUDIT_EMAIL_REPORTS:-$default}"
            ;;
        "security_threshold")
            echo "${AUDIT_SECURITY_THRESHOLD:-$default}"
            ;;
        "generate_summary")
            echo "${AUDIT_GENERATE_SUMMARY:-$default}"
            ;;
        "show_security_score")
            echo "${AUDIT_SHOW_SECURITY_SCORE:-$default}"
            ;;
        *)
            echo "$default"
            ;;
    esac
}

# Update configuration value
update_config() {
    local var_name="$1"
    local value="$2"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        red_msg "Configuration file not found"
        return 1
    fi
    
    # Create backup
    local backup_file="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_FILE" "$backup_file"
    
    # Update value using sed
    if sed -i "s/^${var_name}=.*/${var_name}=${value}/" "$CONFIG_FILE" 2>/dev/null; then
        green_msg "Configuration updated: $var_name = $value"
        return 0
    else
        red_msg "Failed to update configuration: $var_name = $value"
        return 1
    fi
}

# Show current configuration
show_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        red_msg "Configuration file not found"
        return 1
    fi
    
    yellow_msg 'Current Configuration:'
    echo
    
    # Show the configuration file with syntax highlighting
    cat "$CONFIG_FILE"
}

# Validate configuration
validate_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        red_msg "Configuration file not found"
        return 1
    fi
    
    # Try to source the file to check syntax
    if source "$CONFIG_FILE" 2>/dev/null; then
        green_msg "Configuration file is valid bash syntax"
        return 0
    else
        red_msg "Configuration file contains bash syntax errors"
        return 1
    fi
}

# Check if IPv6 should be disabled
is_ipv6_disabled() {
    local disable_ipv6=$(get_system_config "disable_ipv6" "false")
    [ "$disable_ipv6" = "true" ]
}
