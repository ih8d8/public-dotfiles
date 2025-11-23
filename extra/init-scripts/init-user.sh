#!/usr/bin/env bash

# init-user.sh - Initialize user environment after Arch Linux installation
# Usage: ./init-user.sh [CHROOT_TARGET] [USERNAME] [SECONDARY_LANGUAGE]
# SECONDARY_LANGUAGE: locale code from /etc/locale.gen (e.g., de_DE, ar_SA)

set -euo pipefail

# Configuration
readonly CHROOT_TARGET="${1:-/mnt}"
readonly USERNAME="${2}"
readonly SECONDARY_LANGUAGE="${3:-}"

# Source shared utilities scripts
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${SCRIPT_DIR}/utils.sh"

# Replace PLACEHOLDER_USERNAME with actual USERNAME in dotfiles
replace_placeholder_username() {
    log_info "Replacing PLACEHOLDER_USERNAME with ${USERNAME} in dotfiles"
    
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local source_dotfiles_dir="${script_dir}/../.."
    local files_to_update=(
        "${source_dotfiles_dir}/gtk/.gtkrc-2.0"
        "${source_dotfiles_dir}/systemd/.config/systemd/user/check-battery.service"
        "${source_dotfiles_dir}/systemd/.config/systemd/user/tailreceive.service"
    )
    
    for file in "${files_to_update[@]}"; do
        if [[ -f "${file}" ]]; then
            if grep -q "PLACEHOLDER_USERNAME" "${file}"; then
                sed -i "s/PLACEHOLDER_USERNAME/${USERNAME}/g" "${file}"
                log_info "Updated ${file}"
            else
                log_info "No PLACEHOLDER_USERNAME found in ${file}, seems to already contain actual username"
            fi
        else
            log_warn "File not found: ${file}"
        fi
    done
}

# Map locale code to XKB keyboard layout
# Takes a locale code (e.g., de_DE) and returns the corresponding XKB layout
locale_to_xkb_layout() {
    local locale="$1"
    
    # Extract language code (first part before underscore)
    local lang_code="${locale%%_*}"
    # Extract country code (part after underscore, before any dot or @)
    local country_code="${locale#*_}"
    country_code="${country_code%%.*}"
    country_code="${country_code%%@*}"
    
    # Mapping of locale language/country codes to XKB keyboard layouts
    # Based on common mappings from /etc/locale.gen to XKB layouts
    case "${lang_code}" in
        # Arabic - various countries use 'ara' layout
        ar) echo "ara" ;;
        # Azerbaijani
        az) echo "az" ;;
        # Belarusian
        be) echo "by" ;;
        # Bulgarian
        bg) echo "bg" ;;
        # Bengali/Bangla
        bn) echo "bd" ;;
        # Tibetan
        bo) echo "bt" ;;
        # Bosnian
        bs) echo "ba" ;;
        # Catalan - uses Spanish layout
        ca) echo "es" ;;
        # Czech
        cs) echo "cz" ;;
        # Welsh
        cy) echo "gb" ;;
        # Danish
        da) echo "dk" ;;
        # German
        de) echo "de" ;;
        # Dzongkha (Bhutan)
        dz) echo "bt" ;;
        # Greek
        el) echo "gr" ;;
        # English - use country code
        en)
            case "${country_code}" in
                GB) echo "gb" ;;
                *) echo "us" ;;
            esac
            ;;
        # Spanish
        es) echo "es" ;;
        # Estonian
        et) echo "ee" ;;
        # Basque
        eu) echo "es" ;;
        # Persian/Farsi
        fa) echo "ir" ;;
        # Finnish
        fi) echo "fi" ;;
        # French
        fr) echo "fr" ;;
        # Irish
        ga) echo "ie" ;;
        # Scottish Gaelic
        gd) echo "gb" ;;
        # Galician
        gl) echo "es" ;;
        # Gujarati
        gu) echo "in" ;;
        # Hebrew
        he) echo "il" ;;
        # Hindi
        hi) echo "in" ;;
        # Croatian
        hr) echo "hr" ;;
        # Hungarian
        hu) echo "hu" ;;
        # Armenian
        hy) echo "am" ;;
        # Indonesian
        id) echo "id" ;;
        # Icelandic
        is) echo "is" ;;
        # Italian
        it) echo "it" ;;
        # Japanese
        ja) echo "jp" ;;
        # Georgian
        ka) echo "ge" ;;
        # Kazakh
        kk) echo "kz" ;;
        # Khmer
        km) echo "kh" ;;
        # Kannada
        kn) echo "in" ;;
        # Korean
        ko) echo "kr" ;;
        # Kurdish
        ku) echo "tr" ;;
        # Kyrgyz
        ky) echo "kg" ;;
        # Lao
        lo) echo "la" ;;
        # Lithuanian
        lt) echo "lt" ;;
        # Latvian
        lv) echo "lv" ;;
        # Macedonian
        mk) echo "mk" ;;
        # Malayalam
        ml) echo "in" ;;
        # Mongolian
        mn) echo "mn" ;;
        # Marathi
        mr) echo "in" ;;
        # Malay
        ms) echo "my" ;;
        # Maltese
        mt) echo "mt" ;;
        # Burmese
        my) echo "mm" ;;
        # Norwegian
        nb|nn|no) echo "no" ;;
        # Nepali
        ne) echo "np" ;;
        # Dutch
        nl) echo "nl" ;;
        # Oriya
        or) echo "in" ;;
        # Punjabi
        pa) echo "in" ;;
        # Polish
        pl) echo "pl" ;;
        # Pashto
        ps) echo "af" ;;
        # Portuguese
        pt) echo "pt" ;;
        # Romanian
        ro) echo "ro" ;;
        # Russian
        ru) echo "ru" ;;
        # Sinhala
        si) echo "lk" ;;
        # Slovak
        sk) echo "sk" ;;
        # Slovenian
        sl) echo "si" ;;
        # Albanian
        sq) echo "al" ;;
        # Serbian
        sr) echo "rs" ;;
        # Swedish
        sv) echo "se" ;;
        # Tamil
        ta) echo "in" ;;
        # Telugu
        te) echo "in" ;;
        # Tajik
        tg) echo "tj" ;;
        # Thai
        th) echo "th" ;;
        # Turkmen
        tk) echo "tm" ;;
        # Turkish
        tr) echo "tr" ;;
        # Tatar
        tt) echo "ru" ;;
        # Uyghur
        ug) echo "cn" ;;
        # Ukrainian
        uk) echo "ua" ;;
        # Urdu
        ur) echo "pk" ;;
        # Uzbek
        uz) echo "uz" ;;
        # Vietnamese
        vi) echo "vn" ;;
        # Chinese
        zh)
            case "${country_code}" in
                TW|HK) echo "tw" ;;
                *) echo "cn" ;;
            esac
            ;;
        # Default to US layout
        *) echo "us" ;;
    esac
}

# Set secondary keyboard layout in hyprland.conf (modifies source dotfiles in place)
set_secondary_keyboard_layout() {
    local locale="$1"
    
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local source_dotfiles_dir="${script_dir}/../.."
    local hyprland_conf="${source_dotfiles_dir}/hyprland/.config/hypr/hyprland.conf"
    
    local xkb_layout
    if [[ -z "${locale}" ]]; then
        log_info "No secondary language specified, setting keyboard layout to 'us'"
        xkb_layout="us"
    else
        xkb_layout=$(locale_to_xkb_layout "${locale}")
        log_info "Setting secondary keyboard layout to '${xkb_layout}' based on locale '${locale}'"
    fi
    
    # Update the $SECONDARY_KB_LAYOUT variable in hyprland.conf
    if [[ -f "${hyprland_conf}" ]]; then
        sed -i "s/^\\\$SECONDARY_KB_LAYOUT = .*$/\$SECONDARY_KB_LAYOUT = ${xkb_layout}/" "${hyprland_conf}"
        log_success "Secondary keyboard layout set to '${xkb_layout}'"
    else
        log_warn "Hyprland config not found at ${hyprland_conf}"
    fi
}

# Copy dotfiles repository
copy_dotfiles() {
    log_info "Copying dotfiles repository"
    
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local source_dotfiles_dir="${script_dir}/../../../dotfiles"
    local target_dotfiles_dir="/home/${USERNAME}/.dotfiles"
    
    # Remove existing and create target
    chroot_exec rm -rf "${target_dotfiles_dir}"
    
    # Copy dotfiles
    cp -r "${source_dotfiles_dir}" "${CHROOT_TARGET}${target_dotfiles_dir}"
    
    chroot_exec chown -R "${USERNAME}:wheel" "${target_dotfiles_dir}"
    log_success "Dotfiles copied successfully"
}

# Device-specific setup
setup_device_config() {
    log_info "Setting up device configuration"
    
    # Create a script to run device detection and configuration in a single chroot
    local device_setup_script="/mnt/device-setup-$$.sh"
    cat > "${device_setup_script}" << 'EOF'
#!/usr/bin/env bash
USERNAME="$1"

if fastfetch | grep -q ThinkPad; then
    echo "ThinkPad detected"
    # Enable tp-battery-mode service if it exists
    if systemctl list-unit-files | grep -q "tp-battery-mode.service"; then
        systemctl enable tp-battery-mode.service
    fi
    # Copy ThinkPad configuration files
    sudo -u "${USERNAME}" cp "/home/${USERNAME}/.dotfiles/hyprland/.config/hypr/thinkpad.conf" "/home/${USERNAME}/.dotfiles/hyprland/.config/hypr/hypr-monitor.conf"
    sudo -u "${USERNAME}" cp "/home/${USERNAME}/.dotfiles/waybar/.config/waybar/thinkpad.jsonc" "/home/${USERNAME}/.dotfiles/waybar/.config/waybar/language.jsonc"
elif fastfetch | grep -q IdeaPad; then
    echo "IdeaPad detected"
    # Copy IdeaPad configuration files
    sudo -u "${USERNAME}" cp "/home/${USERNAME}/.dotfiles/hyprland/.config/hypr/ideapad.conf" "/home/${USERNAME}/.dotfiles/hyprland/.config/hypr/hypr-monitor.conf"
    sudo -u "${USERNAME}" cp "/home/${USERNAME}/.dotfiles/waybar/.config/waybar/ideapad.jsonc" "/home/${USERNAME}/.dotfiles/waybar/.config/waybar/language.jsonc"
else
    echo "Unknown device type, using default configuration"
    sudo -u "${USERNAME}" cp "/home/${USERNAME}/.dotfiles/hyprland/.config/hypr/vm.conf" "/home/${USERNAME}/.dotfiles/hyprland/.config/hypr/hypr-monitor.conf"
    sudo -u "${USERNAME}" cp "/home/${USERNAME}/.dotfiles/waybar/.config/waybar/vm.jsonc" "/home/${USERNAME}/.dotfiles/waybar/.config/waybar/language.jsonc"
fi
EOF
    
    chmod +x "${device_setup_script}"
    
    chroot_exec bash "/$(basename "${device_setup_script}")" "${USERNAME}"
    
    # Clean up the temporary script
    rm -f "${device_setup_script}"
    
    log_success "Device configuration applied"
}

# Setup dotfiles with stow
setup_dotfiles() {
    log_info "Setting up dotfiles with stow"
    
    # Files and directories to remove before stow
    local files_to_remove=(
        "/home/${USERNAME}/.bashrc"
        "/home/${USERNAME}/.bash_profile"
        "/home/${USERNAME}/.config/hypr"
        "/home/${USERNAME}/.config/alacritty"
        "/home/${USERNAME}/.config/dunst"
        "/home/${USERNAME}/.config/gammastep"
        "/home/${USERNAME}/.config/htop"
        "/home/${USERNAME}/.config/gtk-3.0"
        "/home/${USERNAME}/.config/gtk-4.0"
        "/home/${USERNAME}/.config/Kvantum"
        "/home/${USERNAME}/.config/mpv"
        "/home/${USERNAME}/.config/nvim"
        "/home/${USERNAME}/.config/rofi"
        "/home/${USERNAME}/.config/SpeedCrunch"
        "/home/${USERNAME}/.config/waybar"
        "/home/${USERNAME}/.config/wlogout"
        "/home/${USERNAME}/.config/wofi"
        "/home/${USERNAME}/.config/yazi"
        "/home/${USERNAME}/.config/zellij"
        "/home/${USERNAME}/.config/pcmanfm"
        "/home/${USERNAME}/.config/libfm"
        "/home/${USERNAME}/.config/systemd"
    )
    
    # Remove existing files/directories that conflict with stow
    for file in "${files_to_remove[@]}"; do
        chroot_exec_user "${USERNAME}" rm -rf "${file}"
    done
    
    # Remove bash files from .local/bin separately (requires shell expansion)
    chroot_exec_user "${USERNAME}" bash -c "rm -f /home/${USERNAME}/.local/bin/* 2>/dev/null || true"
    chroot_exec_user "${USERNAME}" bash -c "cd /home/${USERNAME}/.dotfiles && ls -I extra | xargs -I{} -- stow -v {}"
    
    log_success "Dotfiles setup completed"
}

# Fix file permissions
fix_permissions() {
    log_info "Fixing file permissions"
    
    chroot_exec chown -R "${USERNAME}:wheel" "/home/${USERNAME}"
    chroot_exec test -d "/home/${USERNAME}/.local/bin" && chroot_exec find "/home/${USERNAME}/.local/bin" -type f -exec chmod +x {} \;
    
    log_success "File permissions fixed"
}

# Main function
main() {
    log_info "Starting user initialization"
    log_info "Target: ${CHROOT_TARGET}, User: ${USERNAME}"
    
    [[ "${CHROOT_TARGET}" != "/" && ! -d "${CHROOT_TARGET}/etc" ]] && error "Invalid chroot target"
    
    setup_temporary_sudoers
    trap cleanup_temporary_sudoers EXIT
    
    set_secondary_keyboard_layout "${SECONDARY_LANGUAGE}"
    replace_placeholder_username
    copy_dotfiles
    setup_dotfiles
    fix_permissions
    setup_device_config
    
    log_success "User initialization completed!"
}

main "${@}"
