#!/usr/bin/env bash
# lib/modules/special.sh — Automated workflow, SMB vulns, secrets dump, results.

if [[ -n "${GHOSTLINE_MODULE_SPECIAL_LOADED:-}" ]]; then
    return 0
fi
GHOSTLINE_MODULE_SPECIAL_LOADED=1

special_run_workflow() {
    printf '\n%b%bAUTO WORKFLOW%b\n' "${BRIGHT_MAGENTA}" "${BOLD}" "${RESET}"
    require_target
    ensure_output_dir
    log_step "Running automated enumeration workflow..."
    echo ""

    if ensure_command "nmap" "sudo apt install nmap"; then
        log_step "Phase 1: Network Scan"
        nmap -p 88,135,139,389,445 -sV "${GHOSTLINE_TARGET}" \
            -oA "${GHOSTLINE_OUTPUT_DIR}/nmap" 2>/dev/null
    fi

    if ensure_command "enum4linux-ng" "sudo ./install.sh"; then
        log_step "Phase 2: SMB Enumeration"
        enum4linux-ng -A "${GHOSTLINE_TARGET}" \
            > "${GHOSTLINE_OUTPUT_DIR}/enum4linux.txt" 2>/dev/null
    fi

    if ensure_command "rpcclient" "sudo apt install samba-common-bin"; then
        log_step "Phase 3: RPC Enumeration"
        { echo "enumdomusers"; echo "exit"; } \
            | rpcclient -U "" "${GHOSTLINE_TARGET}" -N \
            > "${GHOSTLINE_OUTPUT_DIR}/rpc.txt" 2>/dev/null
    fi

    if [[ -n "${GHOSTLINE_DOMAIN}" ]] && ensure_command "ldapsearch" "sudo apt install ldap-utils"; then
        log_step "Phase 4: LDAP Query"
        local base_dn
        base_dn=$(domain_to_basedn "${GHOSTLINE_DOMAIN}")
        ldapsearch -x -H "ldap://${GHOSTLINE_TARGET}" -b "${base_dn}" "(objectclass=user)" \
            > "${GHOSTLINE_OUTPUT_DIR}/ldap.txt" 2>/dev/null
    fi

    echo ""
    log_success "Workflow complete. Results in ${GHOSTLINE_OUTPUT_DIR}/"
    press_enter_to_continue
}

special_run_smb_vulns() {
    printf '\n%bSMB Vulnerabilities%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    ensure_command "nmap" "sudo apt install nmap" || return 0
    ensure_output_dir
    log_step "Scanning for SMB vulnerabilities..."
    nmap -p 445 --script 'smb-vuln*' "${GHOSTLINE_TARGET}" \
        -oA "${GHOSTLINE_OUTPUT_DIR}/smb_vulns"
    log_success "Vulnerability scan complete"
    press_enter_to_continue
}

special_run_secretsdump() {
    printf '\n%bSecrets Dump%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    require_domain
    require_credentials
    local secretsdump
    if ! secretsdump=$(resolve_command "secretsdump.py" "impacket-secretsdump"); then
        log_warn "secretsdump.py / impacket-secretsdump is not installed."
        log_info "Hint: pipx install impacket"
        return 0
    fi
    ensure_output_dir
    printf '%b%b! This requires elevated privileges!%b\n' \
        "${BRIGHT_RED}" "${BOLD}" "${RESET}"
    log_step "Dumping secrets..."
    "$secretsdump" \
        "${GHOSTLINE_DOMAIN}/${GHOSTLINE_USERNAME}:${GHOSTLINE_PASSWORD}@${GHOSTLINE_TARGET}" \
        | tee "${GHOSTLINE_OUTPUT_DIR}/secrets.txt"
    log_success "Secrets saved"
    press_enter_to_continue
}

special_view_results() {
    printf '\n%bResults Viewer%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    if [[ ! -d "${GHOSTLINE_OUTPUT_DIR}" ]]; then
        log_warn "No results directory found at ${GHOSTLINE_OUTPUT_DIR}"
    else
        log_info "Files in ${GHOSTLINE_OUTPUT_DIR}:"
        ls -lh "${GHOSTLINE_OUTPUT_DIR}"
    fi
    press_enter_to_continue
}

handle_special_menu() {
    local choice
    while true; do
        clear
        display_banner_with_menu "special"
        prompt_menu_choice "Special Ops"
        read -r choice

        case "$choice" in
            1) special_run_workflow ;;
            2) special_run_smb_vulns ;;
            3) special_run_secretsdump ;;
            4) special_view_results ;;
            0) return ;;
            *)
                printf '\n%bInvalid choice!%b\n' "${BRIGHT_RED}" "${RESET}"
                sleep 1
                ;;
        esac
    done
}
