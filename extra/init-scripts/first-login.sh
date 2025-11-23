#!/usr/bin/env bash

# first-login.sh - Script to run on first user login

set -euo pipefail

# Logging function
log() {
    echo "[${1}] ${*:2}"
}

log_info() { log "INFO" "${@}"; }
log_error() { log "ERROR" "${@}"; }
log_success() { log "SUCCESS" "${@}"; }
log_warn() { log "WARN" "${@}"; }

# Enable services
enable_services() {
    log_info "Enabling systemd user services"
    
    # Enable a list of user systemd units, logging outcome for each
    local -a user_services=(
        "check-battery.service"
        "check-battery.timer"
        "tailreceive.service"
    )

    # Enable each user service
    for svc in "${user_services[@]}"; do
        if systemctl --user enable --now "${svc}"; then
            log_success "Enabled user service: ${svc}"
        else
            log_warn "Failed to enable user service: ${svc}"
        fi
    done
}

# Set theme
set_theme() {
    local theme="${1:-Dracula}"
    log_info "Setting theme to ${theme}"

    if [[ -x "${HOME}/.local/bin/set-theme" ]]; then
        "${HOME}/.local/bin/set-theme" "${theme}"
        log_success "Theme set successfully to ${theme}"
    else
        log_error "set-theme script not found at ${HOME}/.local/bin/set-theme"
        exit 1
    fi
}

# Setup tmux plugins
setup_tmux_plugins() {
    log_info "Installing tmux plugins"
    
    # Check if TPM install script is available
    local tpm_install_script="/usr/share/tmux-plugin-manager/bin/install_plugins"
    if [[ ! -f "${tpm_install_script}" ]]; then
        log_warn "TPM install script not found at ${tpm_install_script}, skipping plugin installation"
        return 1
    fi
    
    # Install plugins by running TPM install script
    if "${tpm_install_script}" &> /dev/null; then
        log_success "tmux plugins installed successfully"
    else
        log_warn "Failed to install tmux plugins automatically"
        log_info "You can manually install plugins later with: prefix + I"
    fi
}

# Main execution
main() {
    # Enable systemd user services
    enable_services
    
    # Set theme
    set_theme "Dracula"

    # Setup tmux plugins
    setup_tmux_plugins
    
    # Create completion marker
    touch "${HOME}/.first-login-completed"
    log_info "First login script completed"
}

# Run main function
main "${@}"