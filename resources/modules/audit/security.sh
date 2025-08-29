#!/bin/bash

# =============================================================================
# Audit Security Module - Security settings and configuration analysis
# =============================================================================

# Configuration is loaded centrally in main.sh

# Check basic security settings
check_basic_security() {
    local report_file="$1"
    
    echo "=== Basic Security Settings ===" >> "$report_file"
    
    # Check SSH configuration
    if [ -f "/etc/ssh/sshd_config" ]; then
        if grep -q "PasswordAuthentication no" /etc/ssh/sshd_config; then
            echo "SSH Password Auth: DISABLED [PASS]" >> "$report_file"
        else
            echo "SSH Password Auth: ENABLED [FAIL]" >> "$report_file"
        fi
        
        if grep -q "PermitRootLogin no" /etc/ssh/sshd_config; then
            echo "SSH Root Login: DISABLED [PASS]" >> "$report_file"
        else
            echo "SSH Root Login: ENABLED [FAIL]" >> "$report_file"
        fi
        
        local ssh_port=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}' | head -1)
        if [ "$ssh_port" != "22" ]; then
            echo "SSH Port: $ssh_port (Changed from default) [PASS]" >> "$report_file"
        else
            echo "SSH Port: 22 (Default) [WARN]" >> "$report_file"
        fi
    else
        echo "SSH Config: NOT FOUND [FAIL]" >> "$report_file"
    fi
    
    # Check UFW status
    if command_exists ufw; then
        local ufw_status=$(ufw status | grep "Status:" | awk '{print $2}')
        echo "UFW Status: $ufw_status" >> "$report_file"
        
        if [ "$ufw_status" = "active" ]; then
            local ufw_rules=$(ufw status numbered | grep -c "ALLOW\|DENY")
            echo "UFW Rules: $ufw_rules active rules" >> "$report_file"
        fi
    else
        echo "UFW: NOT INSTALLED [FAIL]" >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Check advanced security settings
check_advanced_security() {
    local report_file="$1"
    
    echo "=== Advanced Security Settings ===" >> "$report_file"
    
    # Check IPv6 status
    if is_ipv6_disabled; then
        echo "IPv6: DISABLED [PASS]" >> "$report_file"
    else
        echo "IPv6: ENABLED [WARN]" >> "$report_file"
    fi
    
    # Check kernel parameters
    local tcp_syncookies=$(sysctl -n net.ipv4.tcp_syncookies 2>/dev/null)
    if [ "$tcp_syncookies" = "1" ]; then
        echo "TCP SYN Cookies: ENABLED [PASS]" >> "$report_file"
    else
        echo "TCP SYN Cookies: DISABLED [FAIL]" >> "$report_file"
    fi
    
    # Check core dumps
    local core_pattern=$(sysctl -n kernel.core_pattern 2>/dev/null)
    if [ "$core_pattern" = "|/usr/share/apport/apport %p %s %c %d %P %E" ] || [ "$core_pattern" = "core" ]; then
        echo "Core Dumps: ENABLED [WARN]" >> "$report_file"
    else
        echo "Core Dumps: DISABLED [PASS]" >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Check user security
check_user_security() {
    local report_file="$1"
    
    echo "=== User Security ===" >> "$report_file"
    
    # Check users with UID 0
    local uid0_users=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)
    if [ "$(echo "$uid0_users" | wc -l)" -eq 1 ] && echo "$uid0_users" | grep -q "^root$"; then
        echo "UID 0 Users: Only root [PASS]" >> "$report_file"
    else
        echo "UID 0 Users: Multiple users with root privileges [FAIL]" >> "$report_file"
        echo "$uid0_users" | while read user; do
            echo "  - $user" >> "$report_file"
        done
    fi
    
    # Check users without passwords
    local no_passwd_users=$(awk -F: '$2 == "" {print $1}' /etc/shadow 2>/dev/null)
    if [ -n "$no_passwd_users" ]; then
        echo "Users without passwords: [FAIL]" >> "$report_file"
        echo "$no_passwd_users" | while read user; do
            echo "  - $user" >> "$report_file"
        done
    else
        echo "Users without passwords: None [PASS]" >> "$report_file"
    fi
    
    # Check sudo users
    local sudo_users=$(getent group sudo | cut -d: -f4 | tr ',' '\n' | grep -v '^$')
    if [ -n "$sudo_users" ]; then
        echo "Sudo users:" >> "$report_file"
        echo "$sudo_users" | while read user; do
            echo "  - $user" >> "$report_file"
        done
    fi
    
    echo "" >> "$report_file"
}

# Check cron security
check_cron_security() {
    local report_file="$1"
    
    echo "=== Cron Security ===" >> "$report_file"
    
    # Check system cron
    if [ -f "/etc/crontab" ]; then
        echo "System cron (/etc/crontab):" >> "$report_file"
        cat /etc/crontab | grep -v '^#' | grep -v '^$' | while read line; do
            if [ -n "$line" ]; then
                echo "  - $line" >> "$report_file"
            fi
        done
    fi
    
    # Check cron directories
    for cron_dir in /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.monthly /etc/cron.weekly; do
        if [ -d "$cron_dir" ]; then
            local files=$(find "$cron_dir" -type f -executable 2>/dev/null)
            if [ -n "$files" ]; then
                echo "Executable files in $cron_dir:" >> "$report_file"
                echo "$files" | while read file; do
                    echo "  - $file" >> "$report_file"
                done
            fi
        fi
    done
    
    echo "" >> "$report_file"
}

# Check critical files
check_critical_files() {
    local report_file="$1"
    
    echo "=== Critical Files Security ===" >> "$report_file"
    
    # Check file permissions
    local critical_files=("/etc/passwd" "/etc/shadow" "/etc/sudoers" "/etc/ssh/sshd_config")
    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            local perms=$(stat -c "%a" "$file")
            local owner=$(stat -c "%U" "$file")
            echo "$file: $perms ($owner)" >> "$report_file"
            
            # Check for world-writable
            if [ "$((perms % 10))" -ge 2 ]; then
                echo "  [WARN] World-writable permissions" >> "$report_file"
            fi
        fi
    done
    
    # Check SUID/SGID files
    local suid_files=$(find /usr/bin /usr/sbin /bin /sbin -type f -perm -4000 2>/dev/null | head -10)
    if [ -n "$suid_files" ]; then
        echo "SUID files (first 10):" >> "$report_file"
        echo "$suid_files" | while read file; do
            echo "  - $file" >> "$report_file"
        done
    fi
    
    echo "" >> "$report_file"
}
