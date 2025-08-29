#!/bin/bash

# =============================================================================
# XanMod Kernel Module - Installation and configuration
# =============================================================================

# Configuration is loaded centrally in main.sh

# Load sysctl module for BBR configuration
source "resources/modules/optimize/sysctl.sh"

# Install XanMod kernel
install_xanmod() {
    yellow_msg 'Installing XanMod Kernel...'
    echo
    sleep 0.5

    # Check and install XanMod dependencies
    if ! check_and_install_xanmod_deps; then
        red_msg "Failed to install XanMod dependencies. Exiting."
        return 1
    fi

    # Check if XanMod kernel is already installed
    if dpkg -l | grep -q "linux-xanmod"; then
        green_msg "XanMod kernel is already installed"
        return 0
    fi

    # Get CPU level for XanMod kernel (limited to max 3)
    local cpu_level=$(get_cpu_level)
    
    if [ -n "$cpu_level" ]; then
        yellow_msg "CPU Level detected: v$cpu_level (limited to max v3)"
        
        # Limit CPU level to maximum 3
        if [ "$cpu_level" -gt 3 ]; then
            cpu_level=3
            yellow_msg "CPU level limited to v3 (maximum supported)"
        fi
        
        yellow_msg "Installing XanMod kernel v$cpu_level..."
        
        # Call the kernel installation method from dependencies.sh with version
        install_xanmod_kernel "$cpu_level"
        
        if [ $? -eq 0 ]; then
            green_msg "XanMod kernel v$cpu_level installation completed successfully!"
            
            # Apply BBR configuration after successful kernel installation
            yellow_msg "Applying BBR configuration for XanMod kernel..."
            if apply_bbr_after_xanmod; then
                green_msg "BBR configuration applied successfully"
            else
                yellow_msg "Warning: BBR configuration could not be applied"
            fi
        else
            red_msg "XanMod kernel installation failed"
            return 1
        fi
    else
        red_msg "Failed to determine CPU level for XanMod kernel"
        return 1
    fi
    
    echo
    sleep 0.5
}

# Get CPU level for XanMod kernel
get_cpu_level() {
    local cpu_level=0
    
    # Check CPU flags to determine appropriate level
    # Based on XanMod kernel requirements
    
    # Level 1: Basic x86_64 support
    if grep -q "lm" /proc/cpuinfo && \
       grep -q "cmov" /proc/cpuinfo && \
       grep -q "cx8" /proc/cpuinfo && \
       grep -q "fpu" /proc/cpuinfo && \
       grep -q "fxsr" /proc/cpuinfo && \
       grep -q "mmx" /proc/cpuinfo && \
       grep -q "syscall" /proc/cpuinfo && \
       grep -q "sse2" /proc/cpuinfo; then
        cpu_level=1
    fi
    
    # Level 2: Enhanced x86_64 support
    if [ "$cpu_level" -eq 1 ] && \
       grep -q "cx16" /proc/cpuinfo && \
       grep -q "lahf" /proc/cpuinfo && \
       grep -q "popcnt" /proc/cpuinfo && \
       grep -q "sse4_1" /proc/cpuinfo && \
       grep -q "sse4_2" /proc/cpuinfo && \
       grep -q "ssse3" /proc/cpuinfo; then
        cpu_level=2
    fi
    
    # Level 3: Advanced x86_64 support
    if [ "$cpu_level" -eq 2 ] && \
       grep -q "avx" /proc/cpuinfo && \
       grep -q "avx2" /proc/cpuinfo && \
       grep -q "bmi1" /proc/cpuinfo && \
       grep -q "bmi2" /proc/cpuinfo && \
       grep -q "f16c" /proc/cpuinfo && \
       grep -q "fma" /proc/cpuinfo && \
       grep -q "abm" /proc/cpuinfo && \
       grep -q "movbe" /proc/cpuinfo && \
       grep -q "xsave" /proc/cpuinfo; then
        cpu_level=3
    fi
    
    # Level 4: AVX-512 support (not used, limited to 3)
    # if [ "$cpu_level" -eq 3 ] && \
    #    grep -q "avx512f" /proc/cpuinfo && \
    #    grep -q "avx512bw" /proc/cpuinfo && \
    #    grep -q "avx512cd" /proc/cpuinfo && \
    #    grep -q "avx512dq" /proc/cpuinfo && \
    #    grep -q "avx512vl" /proc/cpuinfo; then
    #     cpu_level=4
    # fi
    
    # Return level (0 means unsupported)
    if [ "$cpu_level" -gt 0 ]; then
        echo "$cpu_level"
    else
        echo ""
    fi
}

# Show current kernel information
show_kernel_info() {
    yellow_msg 'Current Kernel Information:'
    echo
    
    echo "Current kernel: $(uname -r)"
    echo "Kernel version: $(uname -v)"
    echo "Architecture: $(uname -m)"
    echo "Hostname: $(uname -n)"
    
    echo
    echo "Available kernels:"
    dpkg -l | grep "linux-image" | awk '{print $2}' | sort
    
    echo
}

# Check XanMod kernel status
check_xanmod_status() {
    yellow_msg 'XanMod Kernel Status:'
    echo
    
    if dpkg -l | grep -q "linux-xanmod"; then
        local installed_kernels=$(dpkg -l | grep "linux-xanmod" | awk '{print $2}')
        green_msg "XanMod kernels installed:"
        echo "$installed_kernels"
        
        local current_kernel=$(uname -r)
        if [[ "$current_kernel" == *"xanmod"* ]]; then
            green_msg "Currently running XanMod kernel: $current_kernel"
        else
            yellow_msg "XanMod kernel installed but not running. Please reboot."
        fi
    else
        red_msg "No XanMod kernels installed"
    fi
    
    echo
}
