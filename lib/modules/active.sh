#!/usr/bin/env bash
# lib/modules/active.sh — Authenticated enumeration (credentials required).

if [[ -n "${GHOSTLINE_MODULE_ACTIVE_LOADED:-}" ]]; then
    return 0
fi
GHOSTLINE_MODULE_ACTIVE_LOADED=1

active_run_bloodhound() {
    printf '\n%bBloodHound Collection%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    require_domain
    require_credentials
    ensure_command "bloodhound-python" "pipx install bloodhound" || return 0
    ensure_output_dir
    log_step "Collecting BloodHound data..."
    bloodhound-python \
        -u "${GHOSTLINE_USERNAME}" -p "${GHOSTLINE_PASSWORD}" \
        -d "${GHOSTLINE_DOMAIN}" -ns "${GHOSTLINE_TARGET}" \
        -c all --zip -o "${GHOSTLINE_OUTPUT_DIR}"
    log_success "JSON files generated"
    press_enter_to_continue
}

active_run_cme() {
    printf '\n%bCrackMapExec%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    require_credentials
    local cme
    if ! cme=$(resolve_command "crackmapexec" "cme" "nxc"); then
        log_warn "Neither crackmapexec, cme nor nxc is installed."
        log_info "Hint: pipx install crackmapexec  (or  pipx install netexec)"
        return 0
    fi
    ensure_output_dir
    log_step "Running ${cme##*/} enumeration..."
    "$cme" smb "${GHOSTLINE_TARGET}" \
        -u "${GHOSTLINE_USERNAME}" -p "${GHOSTLINE_PASSWORD}" --shares \
        | tee "${GHOSTLINE_OUTPUT_DIR}/cme_shares.txt"
    "$cme" smb "${GHOSTLINE_TARGET}" \
        -u "${GHOSTLINE_USERNAME}" -p "${GHOSTLINE_PASSWORD}" --users \
        | tee "${GHOSTLINE_OUTPUT_DIR}/cme_users.txt"
    log_success "Results saved"
    press_enter_to_continue
}

active_run_adidns() {
    printf '\n%bAD DNS Dump%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    require_domain
    require_credentials
    ensure_command "adidnsdump" "pip install adidnsdump" || return 0
    ensure_output_dir
    log_step "Dumping DNS records..."
    adidnsdump \
        -u "${GHOSTLINE_DOMAIN}\\${GHOSTLINE_USERNAME}" \
        -p "${GHOSTLINE_PASSWORD}" \
        "${GHOSTLINE_TARGET}" -r \
        --output "${GHOSTLINE_OUTPUT_DIR}/dns.csv"
    log_success "DNS records saved"
    press_enter_to_continue
}

active_run_getnpusers() {
    printf '\n%bGetNPUsers (ASREPRoast)%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    require_domain
    local getnp
    if ! getnp=$(resolve_command "GetNPUsers.py" "impacket-GetNPUsers"); then
        log_warn "GetNPUsers.py / impacket-GetNPUsers is not installed."
        log_info "Hint: pipx install impacket"
        return 0
    fi
    ensure_output_dir
    log_step "Searching for AS-REP roastable accounts..."
    "$getnp" "${GHOSTLINE_DOMAIN}/" -dc-ip "${GHOSTLINE_TARGET}" -no-pass \
        | tee "${GHOSTLINE_OUTPUT_DIR}/asreproast.txt"
    log_success "Results saved"
    press_enter_to_continue
}

active_run_ridenum() {
    printf '\n%bRID Enumeration%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    ensure_command "ridenum" "sudo ./install.sh" || return 0
    ensure_output_dir
    log_step "Enumerating RIDs (500..10000)..."
    ridenum "${GHOSTLINE_TARGET}" 500 10000 \
        | tee "${GHOSTLINE_OUTPUT_DIR}/ridenum.txt"
    log_success "Results saved"
    press_enter_to_continue
}

handle_active_menu() {
    local choice
    while true; do
        clear
        display_banner_with_menu "active"
        prompt_menu_choice "Active Enum"
        read -r choice

        case "$choice" in
            1) active_run_bloodhound ;;
            2) active_run_cme ;;
            3) active_run_adidns ;;
            4) active_run_getnpusers ;;
            5) active_run_ridenum ;;
            0) return ;;
            *)
                printf '\n%bInvalid choice!%b\n' "${BRIGHT_RED}" "${RESET}"
                sleep 1
                ;;
        esac
    done
}
