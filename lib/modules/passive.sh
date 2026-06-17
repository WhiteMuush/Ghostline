#!/usr/bin/env bash
# lib/modules/passive.sh — Passive reconnaissance (no credentials required).

if [[ -n "${GHOSTLINE_MODULE_PASSIVE_LOADED:-}" ]]; then
    return 0
fi
GHOSTLINE_MODULE_PASSIVE_LOADED=1

passive_run_nmap() {
    printf '\n%bNmap Scan%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    ensure_command "nmap" "sudo apt install nmap" || return 0
    ensure_output_dir
    log_step "Scanning AD ports on ${GHOSTLINE_TARGET}..."
    nmap -p 88,135,139,389,445,464,636,3268,3269,5985 -sV -sC \
        -oA "${GHOSTLINE_OUTPUT_DIR}/nmap_ad" "${GHOSTLINE_TARGET}"
    log_success "Results saved to ${GHOSTLINE_OUTPUT_DIR}/nmap_ad.*"
    press_enter_to_continue
}

passive_run_enum4linux() {
    printf '\n%bEnum4linux-ng%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    ensure_command "enum4linux-ng" "sudo ./install.sh" || return 0
    ensure_output_dir
    log_step "Running enum4linux-ng..."
    enum4linux-ng -A "${GHOSTLINE_TARGET}" \
        | tee "${GHOSTLINE_OUTPUT_DIR}/enum4linux-ng.txt"
    log_success "Results saved"
    press_enter_to_continue
}

passive_run_rpc() {
    printf '\n%bRPC Client%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    ensure_command "rpcclient" "sudo apt install samba-common-bin" || return 0
    ensure_output_dir
    log_step "Attempting RPC null session..."
    {
        echo "srvinfo"
        echo "enumdomusers"
        echo "enumdomgroups"
        echo "exit"
    } | rpcclient -U "" "${GHOSTLINE_TARGET}" -N \
        | tee "${GHOSTLINE_OUTPUT_DIR}/rpcclient.txt"
    log_success "Results saved"
    press_enter_to_continue
}

passive_run_ldap() {
    printf '\n%bLDAP Search%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    require_domain
    ensure_command "ldapsearch" "sudo apt install ldap-utils" || return 0
    ensure_output_dir
    local base_dn
    base_dn=$(domain_to_basedn "${GHOSTLINE_DOMAIN}")
    log_step "Querying LDAP (base ${base_dn})..."
    ldapsearch -x -H "ldap://${GHOSTLINE_TARGET}" -b "${base_dn}" "(objectclass=*)" \
        | tee "${GHOSTLINE_OUTPUT_DIR}/ldap.txt"
    log_success "Results saved"
    press_enter_to_continue
}

passive_run_dns() {
    printf '\n%bDNS Enumeration%b\n' "${BRIGHT_MAGENTA}" "${RESET}"
    require_target
    require_domain
    ensure_command "dnsrecon" "sudo apt install dnsrecon" || return 0
    ensure_output_dir
    log_step "Running dnsrecon..."
    dnsrecon -d "${GHOSTLINE_DOMAIN}" -n "${GHOSTLINE_TARGET}" \
        | tee "${GHOSTLINE_OUTPUT_DIR}/dnsrecon.txt"
    log_success "Results saved"
    press_enter_to_continue
}

handle_passive_menu() {
    local choice
    while true; do
        clear
        display_banner_with_menu "passive"
        prompt_menu_choice "Passive Recon"
        read -r choice

        case "$choice" in
            1) passive_run_nmap ;;
            2) passive_run_enum4linux ;;
            3) passive_run_rpc ;;
            4) passive_run_ldap ;;
            5) passive_run_dns ;;
            0) return ;;
            *)
                printf '\n%bInvalid choice!%b\n' "${BRIGHT_RED}" "${RESET}"
                sleep 1
                ;;
        esac
    done
}
