#!/usr/bin/env bash
# lib/modules/config.sh — Target, domain, credentials and output configuration.

if [[ -n "${GHOSTLINE_MODULE_CONFIG_LOADED:-}" ]]; then
    return 0
fi
GHOSTLINE_MODULE_CONFIG_LOADED=1

# ---------------------------------------------------------------------------
# Quick checks used by enumeration modules. Each prompts the user if the
# corresponding global is empty.
# ---------------------------------------------------------------------------
require_target() {
    if [[ -z "${GHOSTLINE_TARGET}" ]]; then
        log_warn "No target set."
        GHOSTLINE_TARGET=$(prompt_value "Enter target IP/hostname")
    fi
}

require_domain() {
    if [[ -z "${GHOSTLINE_DOMAIN}" ]]; then
        log_info "No domain set."
        GHOSTLINE_DOMAIN=$(prompt_value "Enter domain (e.g. domain.local)")
    fi
}

require_credentials() {
    if [[ -z "${GHOSTLINE_USERNAME}" || -z "${GHOSTLINE_PASSWORD}" ]]; then
        log_warn "Credentials not set."
        GHOSTLINE_USERNAME=$(prompt_value "Username")
        GHOSTLINE_PASSWORD=$(prompt_password "Password")
    fi
}

ensure_output_dir() {
    mkdir -p "${GHOSTLINE_OUTPUT_DIR}"
}

# ---------------------------------------------------------------------------
# Configuration menu actions.
# ---------------------------------------------------------------------------
config_set_target() {
    printf '\n%bSetting Target%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    GHOSTLINE_TARGET=$(prompt_value "Target IP/hostname")
    log_success "Target set: ${GHOSTLINE_TARGET}"
    press_enter_to_continue
}

config_set_domain() {
    printf '\n%bSetting Domain%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    GHOSTLINE_DOMAIN=$(prompt_value "Domain name")
    log_success "Domain set: ${GHOSTLINE_DOMAIN}"
    press_enter_to_continue
}

config_set_credentials() {
    printf '\n%bSetting Credentials%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    GHOSTLINE_USERNAME=$(prompt_value "Username")
    GHOSTLINE_PASSWORD=$(prompt_password "Password")
    log_success "Credentials configured"
    press_enter_to_continue
}

config_set_output_dir() {
    printf '\n%bSetting Output Directory%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    local custom_dir
    custom_dir=$(prompt_value "Directory name" "${GHOSTLINE_OUTPUT_DIR}")
    GHOSTLINE_OUTPUT_DIR="${custom_dir}"
    mkdir -p "${GHOSTLINE_OUTPUT_DIR}"
    log_success "Output: ${GHOSTLINE_OUTPUT_DIR}"
    press_enter_to_continue
}

handle_config_menu() {
    local choice
    while true; do
        clear
        display_banner_with_menu "config"
        prompt_menu_choice "Configure"
        read -r choice

        case "$choice" in
            1) config_set_target ;;
            2) config_set_domain ;;
            3) config_set_credentials ;;
            4) config_set_output_dir ;;
            0) return ;;
            *)
                printf '\n%bInvalid choice!%b\n' "${BRIGHT_RED}" "${RESET}"
                sleep 1
                ;;
        esac
    done
}
