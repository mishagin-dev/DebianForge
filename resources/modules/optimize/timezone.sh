#!/bin/bash

# =============================================================================
# Timezone Module - Automatic timezone detection and configuration
# Uses configuration from resources/config/settings.conf:
# - TIMEZONE_IP_SOURCES: IP sources for location detection
# - TIMEZONE_FALLBACK_LIST: Common timezones for fallback detection
# =============================================================================

# Set timezone based on VPS IP address location
set_timezone() {
    yellow_msg 'Setting TimeZone based on External IP address...'
    sleep 0.5

    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        yellow_msg "jq not available, using fallback timezone detection..."
        set_timezone_fallback
        return
    fi

    get_location_info() {
        # Get IP from the current source (passed as parameter)
        local source="$1"
        local location_info

        # Validate source parameter
        if [ -z "$source" ]; then
            red_msg "Error: Empty source parameter"
            return 1
        fi

        # Get IP from the source
        local ip=$(curl -s "$source")
        if [ -n "$ip" ]; then
            # Get location information from IP
            location_info=$(curl -s "http://ip-api.com/json/$ip")
            if [ -n "$location_info" ]; then
                echo "$location_info"
                return 0
            fi
        fi

        return 1
    }

    # Fetch location information from all configured sources
    local timezones=()
    local successful_requests=0
    
    # Check if TIMEZONE_IP_SOURCES array is available
    if [ ${#TIMEZONE_IP_SOURCES[@]} -eq 0 ]; then
        red_msg "❌ Error: TIMEZONE_IP_SOURCES array is empty. Check configuration loading."
        set_timezone_fallback
        return
    fi
    
    local max_attempts=${#TIMEZONE_IP_SOURCES[@]}
    yellow_msg "Fetching location information from $max_attempts sources..."
    
    for source in "${TIMEZONE_IP_SOURCES[@]}"; do
        yellow_msg "Trying source: $source"
        local location_info=$(get_location_info "$source")
        
        if [ -n "$location_info" ]; then
            local timezone=$(echo "$location_info" | jq -r '.timezone' 2>/dev/null)
            
            if [ -n "$timezone" ] && [ "$timezone" != "null" ]; then
                timezones+=("$timezone")
                successful_requests=$((successful_requests + 1))
                green_msg "✅ Got timezone: $timezone from $source"
            else
                yellow_msg "⚠️  Invalid timezone from $source"
            fi
        else
            yellow_msg "⚠️  Failed to get location from $source"
        fi
        
        # Small delay between requests to avoid rate limiting
        sleep 0.5
    done
    
    # Analyze results
    if [ ${#timezones[@]} -eq 0 ]; then
        red_msg "No valid timezones received from any source. Using fallback method."
        set_timezone_fallback
        return
    fi
    
    yellow_msg "Received ${#timezones[@]} valid timezones from $successful_requests sources"
    
    # Find the most common timezone (consensus)
    local consensus_timezone=""
    local max_count=0
    
    for tz in "${timezones[@]}"; do
        local count=0
        for check_tz in "${timezones[@]}"; do
            if [ "$tz" = "$check_tz" ]; then
                count=$((count + 1))
            fi
        done
        
        if [ $count -gt $max_count ]; then
            max_count=$count
            consensus_timezone="$tz"
        fi
    done
    
    # Check if we have a consensus (use threshold from config)
    local consensus_threshold="${TIMEZONE_CONSENSUS_THRESHOLD:-2}"
    if [ $max_count -ge $consensus_threshold ]; then
        yellow_msg "Consensus reached: $max_count sources agree on timezone: $consensus_timezone"
        timedatectl set-timezone "$consensus_timezone"
        green_msg "✅ Timezone set to $consensus_timezone (consensus method)"
    else
        yellow_msg "No consensus reached (need at least $consensus_threshold sources to agree). Using fallback method."
        set_timezone_fallback
    fi

    echo
    sleep 0.5
}

# Fallback timezone detection method
set_timezone_fallback() {
    yellow_msg "Using fallback timezone detection..."
    
    # Try to detect timezone from system
    local detected_tz=""
    
    # Method 1: Try to get timezone from /etc/timezone
    if [ -f "/etc/timezone" ]; then
        detected_tz=$(cat /etc/timezone | tr -d '[:space:]')
        if [ -n "$detected_tz" ]; then
            yellow_msg "Detected timezone from /etc/timezone: $detected_tz"
        fi
    fi
    
    # Method 2: Try to get timezone from timedatectl
    if [ -z "$detected_tz" ]; then
        detected_tz=$(timedatectl show --property=Timezone --value 2>/dev/null | tr -d '[:space:]')
        if [ -n "$detected_tz" ]; then
            yellow_msg "Detected timezone from timedatectl: $detected_tz"
        fi
    fi
    
    # Method 3: Try to detect from common locations
    if [ -z "$detected_tz" ]; then
        # Use fallback timezone list from configuration
        local fallback_tz=("${TIMEZONE_FALLBACK_LIST[@]}")
        for tz in "${fallback_tz[@]}"; do
            if timedatectl list-timezones | grep -q "^$tz$"; then
                detected_tz="$tz"
                yellow_msg "Using fallback timezone from config: $detected_tz"
                break
            fi
        done
    fi
    
    # Set the detected timezone or fallback to UTC
    if [ -n "$detected_tz" ]; then
        timedatectl set-timezone "$detected_tz"
        green_msg "✅ Timezone set to $detected_tz (fallback method)"
    else
        timedatectl set-timezone "UTC"
        green_msg "✅ Timezone set to UTC (fallback method)"
    fi
}

# Main timezone configuration function (called from main.sh)
configure_timezone() {
    yellow_msg 'Configuring Timezone...'
    echo
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        red_msg "This operation requires root privileges"
        return 1
    fi
    
    # Run timezone configuration
    set_timezone
    
    green_msg "Timezone configuration completed!"
    echo
}
