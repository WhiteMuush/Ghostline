#!/usr/bin/env bash
# lib/ui.sh — ASCII art, menus and banner rendering.

if [[ -n "${GHOSTLINE_UI_LOADED:-}" ]]; then
    return 0
fi
GHOSTLINE_UI_LOADED=1

# ---------------------------------------------------------------------------
# Decorative ASCII raven displayed alongside each menu.
# ---------------------------------------------------------------------------
GHOSTLINE_ASCII_ART=$(cat <<'ASCII'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⢖⣠⣄⡀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣾⣿⣿⠎⠀⠀⠹⡀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⣿⣿⣿⣿⢿⣤⠴⠒⢦⡇⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⣿⣿⣿⣿⠿⠛⠁⠸⡇⠀⠀⠀⡇⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣿⣿⣿⣿⠿⠋⠁⠀⠀⠀⠀⣧⠀⠀⠀⡇⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣶⠂⠾⠿⣿⣿⡿⠛⠁⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⢠⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣷⣤⡀⠈⠉⠑⠒⠤⢀⡀⠀⠀⠀⠀⣿⠀⠀⠀⣼⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠟⠿⠿⢿⣿⣿⣆⠀⠀⠀⠀⠀⠈⠑⢄⠀⠀⣿⠀⠀⠀⡏⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⡏⡄⠀⠀⠀⠈⠻⣿⣧⠀⠀⠀⠀⠀⠀⠀⢳⠀⣿⠀⠀⠀⡇⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⡀⣷⠄⠀⠀⠀⠀⠙⢿⣇⡀⠀⠀⠀⠀⠀⠀⣷⡇⠀⠀⢸⡇⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⡿⠐⣁⣀⣀⢀⣾⣤⢤⣶⣿⣿⣦⡀⠀⠀⠀⠀⢸⠇⠀⠀⡾⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⣿⣇⣾⣿⣿⣿⡇⠀⠻⣽⣿⣿⣿⡿⠿⣦⠀⠀⠀⡟⠀⠀⢰⠇⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⡟⣌⡻⠛⠁⢰⠸⡔⣤⣉⡩⠐⠁⠀⢸⡇⠀⢰⠃⠀⠀⡎⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣇⠀⠉⠀⠀⠀⠀⠀⠈⠙⠻⣶⢶⣶⣾⠇⢀⡏⠀⠀⠰⢣⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⢋⣿⣿⣿⣿⣿⣿⣿⣷⠀⠤⠒⠒⠓⠘⠀⢴⢏⡟⠈⣿⠀⡞⠀⠀⢀⡇⠀⠣⡀⠀
⠀⠀⠀⠀⠀⠀⣼⣿⡿⠁⣸⣿⣿⣿⣿⣿⣿⣿⣿⠀⡰⠞⠛⠛⠛⠳⠶⠿⠁⣰⣿⣼⠃⠀⠀⡼⢿⣶⡀⡇⠀
⠀⠀⠀⠀⠀⣼⣿⠟⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⣿⠟⠋⠉⠉⠁⠀⠀⢠⣿⣿⠃⠀⠀⠰⠁⠘⢿⠔⢀⣠
⠀⠀⠀⠀⣰⣿⡟⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣏⠻⠖⠂⠈⠒⠂⢀⣠⣿⣿⠏⠀⠀⢀⣧⣶⡶⢖⣿⠇⡿
⠀⠀⠀⢠⣿⡟⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣿⣏⠩⠭⣼⣿⣿⠏⠀⠀⠀⡼⠛⢉⣴⣿⠏⣸⡇
⠀⠀⢀⣾⡟⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⣿⣿⠏⠀⠀⠀⡼⢁⣴⣿⡿⠁⣰⣿⠁
⠀⠀⣸⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠿⠿⠿⠛⢛⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⣰⣿⣿⡿⠋⠀⣰⣿⡟⢠
⠀⠀⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⢠⣿⡿⠛⠁⠀⣼⣿⣿⣧⣿
⠀⢸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⡿⠟⢻⠐⠉⠑⠤⣀⢠⣿⣿⠀⠀⢀⣾⣿⣿⣿⣿⣿
⠀⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⢱⠹⠉⢉⠉⠓⠶⠤⠍⠛⢻⡄⣠⣿⣿⣿⣿⣿⣿⣿
⢸⠀⠀⠀⠀⠀⠀⢀⣤⣴⡖⠤⣀⠀⠀⠀⣼⣿⣿⣿⠉⠉⠑⠛⠛⠛⠳⢄⣀⠈⢹⠤⣿⣿⣿⣿⣿⣿⣿⣿⣿
ASCII
)

# ---------------------------------------------------------------------------
# Title screens for each menu.
# ---------------------------------------------------------------------------
generate_main_menu() {
    local -a menu_lines=(
        "${BRIGHT_RED}  ▄██████▄     ▄█    █▄     ▄██████▄     ▄████████     ███      ▄█        ▄█  ███▄▄▄▄      ▄████████${RESET}"
        "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███   ███    ███ ▀█████████▄ ███       ███  ███▀▀▀██▄   ███    ███${RESET}"
        "${BRIGHT_RED}  ███    █▀    ███    ███   ███    ███   ███    █▀     ▀███▀▀██ ███       ███▌ ███   ███   ███    █▀${RESET}"
        "${BRIGHT_RED} ▄███         ▄███▄▄▄▄███▄▄ ███    ███   ███            ███   ▀ ███       ███▌ ███   ███  ▄███▄▄▄${RESET}"
        "${BRIGHT_RED}▀▀███ ████▄  ▀▀███▀▀▀▀███▀  ███    ███ ▀███████████     ███     ███       ███▌ ███   ███ ▀▀███▀▀▀${RESET}"
        "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███          ███     ███     ███       ███  ███   ███   ███    █▄${RESET}"
        "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███    ▄█    ███     ███     ███▌    ▄ ███  ███   ███   ███    ███${RESET}"
        "${BRIGHT_RED}  ████████▀    ███    █▀     ▀██████▀   ▄████████▀     ▄████▀   █████▄▄██ █▀    ▀█   █▀    ██████████${RESET}"
        " "
        "${BRIGHT_RED}█"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_MAGENTA}Configuration:${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    Target: ${BRIGHT_MAGENTA}${GHOSTLINE_TARGET:-Not set}${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    Domain: ${BRIGHT_MAGENTA}${GHOSTLINE_DOMAIN:-Not set}${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    User:   ${BRIGHT_MAGENTA}${GHOSTLINE_USERNAME:-Not set}${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_MAGENTA}Hunt for Active Directory intelligence:${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[1]${RESET}  Configuration Menu"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[2]${RESET}  Passive Enumeration"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[3]${RESET}  Active Enumeration"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[4]${RESET}  Special Actions"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[0]${RESET}  Exit"
        "${BOLD}${BRIGHT_RED}█${RESET}"
    )
    printf '%s\n' "${menu_lines[@]}"
}

generate_config_menu() {
    local -a menu_lines=(
        "${BRIGHT_RED}  ▄████████  ▄██████▄  ███▄▄▄▄      ▄████████  ▄█     ▄██████▄  ${RESET}"
        "${BRIGHT_RED}  ███    ███ ███    ███ ███▀▀▀██▄   ███    ███ ███    ███    ███ ${RESET}"
        "${BRIGHT_RED}  ███    █▀  ███    ███ ███   ███   ███    █▀  ███▌   ███    █▀  ${RESET}"
        "${BRIGHT_RED}  ███        ███    ███ ███   ███  ▄███▄▄▄     ███▌  ▄███        ${RESET}"
        "${BRIGHT_RED}  ███        ███    ███ ███   ███ ▀▀███▀▀▀     ███▌ ▀▀███ ████▄  ${RESET}"
        "${BRIGHT_RED}  ███    █▄  ███    ███ ███   ███   ███        ███    ███    ███ ${RESET}"
        "${BRIGHT_RED}  ███    ███ ███    ███ ███   ███   ███        ███    ███    ███ ${RESET}"
        "${BRIGHT_RED}  ████████▀   ▀██████▀   ▀█   █▀    ███        █▀     ████████▀  ${RESET}"
        " "
        "${BRIGHT_MAGENTA}Configure your hunting parameters${RESET}"
        " "
        "${BOLD}${BRIGHT_RED}█${RESET}    Current Configuration:"
        "${BOLD}${BRIGHT_RED}█${RESET}    Target: ${BRIGHT_MAGENTA}${GHOSTLINE_TARGET:-Not set}${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    Domain: ${BRIGHT_MAGENTA}${GHOSTLINE_DOMAIN:-Not set}${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    User:   ${BRIGHT_MAGENTA}${GHOSTLINE_USERNAME:-Not set}${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    Output: ${BRIGHT_MAGENTA}${GHOSTLINE_OUTPUT_DIR}${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[1]${RESET}  Set Target (IP/Hostname)"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[2]${RESET}  Set Domain"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[3]${RESET}  Set Credentials"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[4]${RESET}  Set Output Directory"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[0]${RESET}  Back to Main Menu"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
    )
    printf '%s\n' "${menu_lines[@]}"
}

generate_passive_menu() {
    local -a menu_lines=(
        "${BRIGHT_RED}  ▄███████▄    ▄████████    ▄████████    ▄████████  ▄█    ███   ▄█    █▄     ▄████████${RESET}"
        "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███   ███    ███ ███  ▀█████████▄ ███    ███   ███    ███${RESET}"
        "${BRIGHT_RED}  ███    ███   ███    ███   ███    █▀    ███    █▀  ███▌    ▀███▀▀██ ███    ███   ███    █▀ ${RESET}"
        "${BRIGHT_RED}  ███    ███   ███    ███   ███          ███        ███▌     ███   ▀ ███    ███  ▄███▄▄▄    ${RESET}"
        "${BRIGHT_RED}▀█████████▀  ▀███████████ ▀███████████ ▀███████████ ███▌     ███     ███    ███ ▀▀███▀▀▀    ${RESET}"
        "${BRIGHT_RED}  ███          ███    ███          ███          ███ ███      ███     ███    ███   ███    █▄ ${RESET}"
        "${BRIGHT_RED}  ███          ███    ███    ▄█    ███    ▄█    ███ ███      ███     ███    ███   ███    ███${RESET}"
        "${BRIGHT_RED} ▄████▀        ███    █▀   ▄████████▀   ▄████████▀  █▀      ▄████▀    ▀██████▀    ██████████${RESET}"
        " "
        "${BRIGHT_MAGENTA}Silent reconnaissance without credentials${RESET}"
        " "
        "${BOLD}${BRIGHT_RED}█${RESET}    Target: ${BRIGHT_MAGENTA}${GHOSTLINE_TARGET:-Not set}${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[1]${RESET}  Nmap Scan (Port Discovery)"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[2]${RESET}  Enum4linux-ng (SMB Enumeration)"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[3]${RESET}  RPC Client (Null Session)"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[4]${RESET}  LDAP Search (Anonymous)"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[5]${RESET}  DNS Enumeration"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[0]${RESET}  Back to Main Menu"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
    )
    printf '%s\n' "${menu_lines[@]}"
}

generate_active_menu() {
    local -a menu_lines=(
        "${BRIGHT_RED}    ▄████████  ▄████████     ███      ▄█    ███   ▄█    █▄     ▄████████${RESET}"
        "${BRIGHT_RED}   ███    ███ ███    ███ ▀█████████▄ ███  ▀█████████▄ ███    ███   ███    ███${RESET}"
        "${BRIGHT_RED}   ███    ███ ███    █▀     ▀███▀▀██ ███▌    ▀███▀▀██ ███    ███   ███    █▀ ${RESET}"
        "${BRIGHT_RED}   ███    ███ ███            ███   ▀ ███▌     ███   ▀ ███    ███  ▄███▄▄▄    ${RESET}"
        "${BRIGHT_RED} ▀███████████ ███            ███     ███▌     ███     ███    ███ ▀▀███▀▀▀    ${RESET}"
        "${BRIGHT_RED}   ███    ███ ███    █▄      ███     ███      ███     ███    ███   ███    █▄ ${RESET}"
        "${BRIGHT_RED}   ███    ███ ███    ███     ███     ███      ███     ███    ███   ███    ███${RESET}"
        "${BRIGHT_RED}   ███    █▀  ████████▀     ▄████▀   █▀      ▄████▀    ▀██████▀    ██████████${RESET}"
        " "
        "${BRIGHT_MAGENTA}Authenticated enumeration with credentials${RESET}"
        " "
        "${BOLD}${BRIGHT_RED}█${RESET}    Credentials: ${BRIGHT_MAGENTA}${GHOSTLINE_USERNAME:-Not set}${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[1]${RESET}  BloodHound Collection"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[2]${RESET}  CrackMapExec (Full Enum)"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[3]${RESET}  AD DNS Dump"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[4]${RESET}  GetNPUsers (ASREPRoast)"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[5]${RESET}  RID Enumeration"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[0]${RESET}  Back to Main Menu"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
    )
    printf '%s\n' "${menu_lines[@]}"
}

generate_special_menu() {
    local -a menu_lines=(
        "${BRIGHT_RED}  ▄████████    ▄███████▄    ▄████████  ▄████████  ▄█     ▄████████  ▄█       ${RESET}"
        "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███ ███    ███ ███    ███    ███ ███       ${RESET}"
        "${BRIGHT_RED}  ███    █▀    ███    ███   ███    █▀  ███    █▀  ███▌   ███    ███ ███       ${RESET}"
        "${BRIGHT_RED}  ███          ███    ███  ▄███▄▄▄     ███        ███▌   ███    ███ ███       ${RESET}"
        "${BRIGHT_RED}▀███████████ ▀█████████▀  ▀▀███▀▀▀     ███        ███▌ ▀███████████ ███       ${RESET}"
        "${BRIGHT_RED}         ███   ███          ███    █▄  ███    █▄  ███    ███    ███ ███       ${RESET}"
        "${BRIGHT_RED}   ▄█    ███   ███          ███    ███ ███    ███ ███    ███    ███ ███▌    ▄ ${RESET}"
        "${BRIGHT_RED} ▄████████▀   ▄████▀        ██████████ ████████▀  █▀     ███    █▀  █████▄▄██ ${RESET}"
        " "
        "${BRIGHT_MAGENTA}Advanced operations and automated workflows${RESET}"
        " "
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[1]${RESET}  Auto Workflow (Full Scan)"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[2]${RESET}  SMB Vulnerabilities Scan"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[3]${RESET}  Secrets Dump (Requires Admin)"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[4]${RESET}  View Results"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[0]${RESET}  Back to Main Menu"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
        "${BOLD}${BRIGHT_RED}█${RESET}"
    )
    printf '%s\n' "${menu_lines[@]}"
}

# ---------------------------------------------------------------------------
# Splash screen displayed when the toolkit boots.
# ---------------------------------------------------------------------------
GHOSTLINE_INFO_PANEL=(
    "${BRIGHT_RED}  ▄██████▄     ▄█    █▄     ▄██████▄     ▄████████     ███      ▄█        ▄█  ███▄▄▄▄      ▄████████${RESET}"
    "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███   ███    ███ ▀█████████▄ ███       ███  ███▀▀▀██▄   ███    ███${RESET}"
    "${BRIGHT_RED}  ███    █▀    ███    ███   ███    ███   ███    █▀     ▀███▀▀██ ███       ███▌ ███   ███   ███    █▀${RESET}"
    "${BRIGHT_RED} ▄███         ▄███▄▄▄▄███▄▄ ███    ███   ███            ███   ▀ ███       ███▌ ███   ███  ▄███▄▄▄${RESET}"
    "${BRIGHT_RED}▀▀███ ████▄  ▀▀███▀▀▀▀███▀  ███    ███ ▀███████████     ███     ███       ███▌ ███   ███ ▀▀███▀▀▀${RESET}"
    "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███          ███     ███     ███       ███  ███   ███   ███    █▄${RESET}"
    "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███    ▄█    ███     ███     ███▌    ▄ ███  ███   ███   ███    ███${RESET}"
    "${BRIGHT_RED}  ████████▀    ███    █▀     ▀██████▀   ▄████████▀     ▄████▀   █████▄▄██ █▀    ▀█   █▀    ██████████${RESET}"
    ""
    "${BRIGHT_MAGENTA}${BOLD}Active Directory OSINT Toolkit${RESET}"
    "${DIM}by Melvin PETIT${RESET}"
)

_strip_ansi() {
    sed -E 's/\x1B\[[0-9;?]*[ -/]*[@-~]//g; s/\x1B\][^\a]*\a//g'
}

display_title_middle_screen() {
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)

    local -a lines=( "${GHOSTLINE_INFO_PANEL[@]}" )
    local h=${#lines[@]}

    local max_w=0 raw visible_len line
    for line in "${lines[@]}"; do
        raw=$(printf "%s" "$line" | _strip_ansi)
        visible_len=${#raw}
        (( visible_len > max_w )) && max_w=$visible_len
    done

    local top=$(( (rows - h) / 2 ))
    (( top < 0 )) && top=0
    local left=$(( (cols - max_w) / 2 ))
    (( left < 0 )) && left=0

    printf "\033c"
    local i
    for ((i=0; i<top; i++)); do
        printf "\n"
    done

    for line in "${lines[@]}"; do
        printf "%*s%s\n" "$left" "" "$line"
    done
}

# ---------------------------------------------------------------------------
# Side-by-side rendering of the raven ASCII art and the active menu.
# ---------------------------------------------------------------------------
display_banner_with_menu() {
    local menu_type="$1"
    local -a ascii_lines menu_lines

    mapfile -t ascii_lines <<< "$GHOSTLINE_ASCII_ART"

    case "$menu_type" in
        main)    mapfile -t menu_lines < <(generate_main_menu) ;;
        config)  mapfile -t menu_lines < <(generate_config_menu) ;;
        passive) mapfile -t menu_lines < <(generate_passive_menu) ;;
        active)  mapfile -t menu_lines < <(generate_active_menu) ;;
        special) mapfile -t menu_lines < <(generate_special_menu) ;;
        *)
            log_error "Unknown menu type: ${menu_type}"
            return 1
            ;;
    esac

    local ascii_count=${#ascii_lines[@]}
    local menu_count=${#menu_lines[@]}
    local max_lines=$(( ascii_count > menu_count ? ascii_count : menu_count ))

    local max_ascii_width=0 line
    for line in "${ascii_lines[@]}"; do
        (( ${#line} > max_ascii_width )) && max_ascii_width=${#line}
    done

    local spacing="    "
    local i
    for ((i=0; i<max_lines; i++)); do
        local ascii_line="${ascii_lines[i]:-}"
        local menu_line="${menu_lines[i]:-}"

        local colored_ascii="${BRIGHT_RED}${ascii_line}${RESET}"
        local pad=$(( max_ascii_width - ${#ascii_line} ))
        (( pad < 0 )) && pad=0

        printf "   %b%*s%s%b\n" \
            "$colored_ascii" \
            "$pad" "" \
            "$spacing" \
            "$menu_line"
    done
    echo ""
    printf "  %bCreator: \e]8;;https://github.com/WhiteMuush\aMelvin PETIT\e]8;;\a   %b%bAuthorized targets only%b\n" \
        "${BRIGHT_RED}" \
        "${BRIGHT_RED}" "${BOLD}" "${RESET}"
    echo ""
}

# Prompt rendered under each submenu. Hardcoded indent matches the menu layout.
prompt_menu_choice() {
    local label="$1"
    echo -ne "                                                 ${BOLD}${BRIGHT_RED}▪ ${label} : ${RESET}"
}
