#!/bin/bash

# =============================================================================
# Additional Libraries Module - System libraries and utilities
# =============================================================================

# Install additional libraries and utilities
install_additional_libraries() {
    yellow_msg 'Installing Additional Libraries and Utilities...'
    echo
    
    local library_packages=(
        # System libraries
        "bc"
        "binutils"
        "binutils-common"
        "binutils-x86-64-linux-gnu"
        "debian-keyring"
        "jq"
        "libsodium-dev"
        "libsqlite3-dev"
        "libssl-dev"
        "packagekit"
        "qrencode"
        "socat"
    )
    
    install_package_list "Additional Libraries" "${library_packages[@]}"
}
