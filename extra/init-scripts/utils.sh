#!/usr/bin/env bash

# utils.sh - Shared utility functions for init scripts

# Logging functions
log() {
    local level="${1}"; shift
    echo "[${level}] ${*}"
}
log_info() { log "INFO" "${@}"; }
log_warn() { log "WARN" "${@}"; }
log_error() { log "ERROR" "${@}"; }
log_success() { log "SUCCESS" "${@}"; }
error() { log_error "${1}"; exit 1; }

# Chroot execution functions
chroot_exec() {
    if [[ "${CHROOT_TARGET}" != "/" ]]; then
        log_info "Executing in chroot: ${*}"
        arch-chroot "${CHROOT_TARGET}" "${@}"
    else
        "${@}"
    fi
}

chroot_exec_user() {
    local user="${1}"; shift
    if [[ "${CHROOT_TARGET}" != "/" ]]; then
        arch-chroot "${CHROOT_TARGET}" sudo -u "${user}" "${@}"
    else
        sudo -u "${user}" "${@}"
    fi
}

# Setup temporary sudoers
setup_temporary_sudoers() {
    local sudoers_file
    if [[ "${CHROOT_TARGET}" != "/" ]]; then
        sudoers_file="${CHROOT_TARGET}/etc/sudoers.d/99-init-script-temp"
    else
        sudoers_file="/etc/sudoers.d/99-init-script-temp"
    fi
    
    log_info "Creating temporary sudoers file"
    echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" | sudo tee "${sudoers_file}" > /dev/null
    sudo chmod 440 "${sudoers_file}"
    log_success "Temporary sudoers created"
}

cleanup_temporary_sudoers() {
    local sudoers_file
    if [[ "${CHROOT_TARGET}" != "/" ]]; then
        sudoers_file="${CHROOT_TARGET}/etc/sudoers.d/99-init-script-temp"
    else
        sudoers_file="/etc/sudoers.d/99-init-script-temp"
    fi
    
    [[ -f "${sudoers_file}" ]] && sudo rm -f "${sudoers_file}" && log_info "Cleaned up temporary sudoers"
}
