#!/bin/bash

# =============================================================================
# Audit Integrity Module - System integrity and package validation
# =============================================================================

# Configuration is loaded centrally in main.sh

# Check system integrity
check_system_integrity() {
    local report_file="$1"
    
    echo "=== System Integrity ===" >> "$report_file"
    
    # Check important file modifications
    local important_files=("/etc/passwd" "/etc/shadow" "/etc/sudoers" "/etc/ssh/sshd_config")
    echo "Important File Modifications:" >> "$report_file"
    
    for file in "${important_files[@]}"; do
        if [ -f "$file" ]; then
            local mod_time=$(stat -c "%y" "$file")
            echo "  - $file: $mod_time" >> "$report_file"
        fi
    done
    
    # Check for unauthorized packages
    if command_exists dpkg; then
        local foreign_packages=$(dpkg -l | grep "^ii" | grep -v "linux-image" | wc -l)
        echo "Installed Packages: $foreign_packages" >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Check package integrity
check_package_integrity() {
    local report_file="$1"
    
    echo "=== Package Integrity ===" >> "$report_file"
    
    # Check for broken packages
    if command_exists dpkg; then
        local broken_packages=$(dpkg -l | grep "^iU\|^rc" | wc -l)
        if [ "$broken_packages" -gt 0 ]; then
            echo "Broken/Unconfigured Packages: $broken_packages [WARN]" >> "$report_file"
        else
            echo "Broken/Unconfigured Packages: None [PASS]" >> "$report_file"
        fi
    fi
    
    # Check for security updates
    if command_exists apt; then
        local security_updates=$(apt list --upgradable 2>/dev/null | grep -c "security")
        if [ "$security_updates" -gt 0 ]; then
            echo "Security Updates Available: $security_updates [WARN]" >> "$report_file"
        else
            echo "Security Updates Available: None [PASS]" >> "$report_file"
        fi
    fi
    
    echo "" >> "$report_file"
}

# Check file system integrity
check_filesystem_integrity() {
    local report_file="$1"
    
    echo "=== Filesystem Integrity ===" >> "$report_file"
    
    # Check for read-only filesystems
    local ro_fs=$(mount | grep "ro," | wc -l)
    if [ "$ro_fs" -gt 0 ]; then
        echo "Read-only Filesystems: $ro_fs [INFO]" >> "$report_file"
        mount | grep "ro," | while read line; do
            echo "  - $line" >> "$report_file"
        done
    fi
    
    # Check for suspicious mount points
    local suspicious_mounts=$(mount | grep -E "(tmpfs|proc|sysfs|devpts)" | wc -l)
    echo "System Mounts: $suspicious_mounts [INFO]" >> "$report_file"
    
    echo "" >> "$report_file"
}

# Check configuration file integrity
check_config_integrity() {
    local report_file="$1"
    
    echo "=== Configuration File Integrity ===" >> "$report_file"
    
    # Check for world-writable config files
    local config_dirs=("/etc" "/etc/ssh" "/etc/ufw" "/etc/systemd")
    
    for config_dir in "${config_dirs[@]}"; do
        if [ -d "$config_dir" ]; then
            local world_writable=$(find "$config_dir" -type f -perm -002 2>/dev/null | wc -l)
            if [ "$world_writable" -gt 0 ]; then
                echo "World-writable files in $config_dir: $world_writable [WARN]" >> "$report_file"
            fi
        fi
    done
    
    echo "" >> "$report_file"
}

# Check boot integrity
check_boot_integrity() {
    local report_file="$1"
    
    echo "=== Boot Integrity ===" >> "$report_file"
    
    # Check bootloader configuration
    if [ -f "/boot/grub/grub.cfg" ]; then
        echo "GRUB Configuration:" >> "$report_file"
        echo "  - File exists and readable" >> "$report_file"
        
        # Check for password protection
        if grep -q "password" /boot/grub/grub.cfg; then
            echo "  - Password protection: ENABLED [PASS]" >> "$report_file"
        else
            echo "  - Password protection: DISABLED [WARN]" >> "$report_file"
        fi
    fi
    
    # Check kernel modules
    if [ -f "/proc/modules" ]; then
        local loaded_modules=$(wc -l < /proc/modules)
        echo "Loaded Kernel Modules: $loaded_modules" >> "$report_file"
    fi
    
    echo "" >> "$report_file"
}

# Check service integrity
check_service_integrity() {
    local report_file="$1"
    
    echo "=== Service Integrity ===" >> "$report_file"
    
    # Check for masked services
    local masked_services=$(systemctl list-unit-files --state=masked | grep "\.service$" | wc -l)
    if [ "$masked_services" -gt 0 ]; then
        echo "Masked Services: $masked_services [INFO]" >> "$report_file"
        systemctl list-unit-files --state=masked | grep "\.service$" | head -5 | while read line; do
            echo "  - $line" >> "$report_file"
        done
    fi
    
    # Check for static services
    local static_services=$(systemctl list-unit-files --state=static | grep "\.service$" | wc -l)
    echo "Static Services: $static_services [INFO]" >> "$report_file"
    
    echo "" >> "$report_file"
}

# Check user file integrity
check_user_file_integrity() {
    local report_file="$1"
    
    echo "=== User File Integrity ===" >> "$report_file"
    
    # Check for suspicious user files
    local suspicious_patterns=(
        ".bashrc"
        ".profile"
        ".ssh/authorized_keys"
        ".ssh/known_hosts"
    )
    
    echo "User File Checks:" >> "$report_file"
    for pattern in "${suspicious_patterns[@]}"; do
        local user_files=$(find /home -name "$pattern" 2>/dev/null | wc -l)
        if [ "$user_files" -gt 0 ]; then
            echo "  - $pattern: $user_files files found" >> "$report_file"
        fi
    done
    
    echo "" >> "$report_file"
}
