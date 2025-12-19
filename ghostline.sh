#!/bin/bash

################################################################################
# AD Enumeration Toolkit
# Interactive toolkit for Active Directory enumeration
# Styled with Feed Your Spider aesthetics
################################################################################

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================
readonly RESET="$(tput sgr0)"
readonly BOLD="$(tput bold)"

readonly RED="$(tput setaf 1)"
readonly GREEN="$(tput setaf 2)"
readonly MAGENTA="$(tput setaf 5)"

readonly BRIGHT_RED="$(tput setaf 9)"
readonly BRIGHT_GREEN="$(tput setaf 10)"
readonly BRIGHT_MAGENTA="$(tput setaf 13)"

# ============================================================================
# ASCII ART BANNER
# ============================================================================
readonly ASCII_ART=$(cat <<'ASCII'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣶⣶⣶⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣺⣷⣿⣿⣿⣷⣿⣷⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣤⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠷⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣤⣝⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣶⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣀⡀⠀⠀⠀⠀⠀
⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀
⠀⠀⠰⢾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠀⠀⠀⠀⠀
⠀⠀⣘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⠀⠀⠀⠀⠀
⠀⠀⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⠀⠀⠀⠀⠀
⠀⢘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀
⢀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀
⠰⢾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⠀⠀⠀
⠈⢛⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣃⠀⠀
⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⠀
⠀⠀⠐⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡯⠀
⠀⠀⠀⠘⢛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣏⡀
⠀⠀⠀⠀⠀⠉⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄
⠀⠀⠀⠀⠀⠀⠘⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠓⠀
⠀⠀⠀⠀⠀⠀⠀⠈⢩⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⠁⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠂⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⡅⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡶⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠂⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡃⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣥⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⠈⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀
⠀⠀⠀⠀⠀⠀⠰⢶⣿⣿⣿⣿⣿⣿⣿⣿⣿⡷⠀⠀⠀⠶⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀
⠀⠀⠀⠀⠀⠀⢘⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⢘⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀
⠀⠀⠀⠀⠀⠀⢨⣽⣿⣿⣿⣿⣿⣿⣿⣿⡍⠀⠀⠀⠀⠨⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀
⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⢾⣿⣿⣿⣿⣿⣿⣿⣷⣖⠀
⠀⠀⠀⠀⠀⠀⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣟⠀
⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⡿⠂⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⠷⠀
⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣟⡀
⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠄⠀⠀⠀⠀⠀⠐⢈⣿⣿⣿⣿⣿⣿⣿⣿⡅⠀⠀⠀⠀⠀⠀⠀⠀
ASCII
)

# ============================================================================
# CONFIGURATION
# ============================================================================
TARGET=""
DOMAIN=""
USERNAME=""
PASSWORD=""
OUTPUT_DIR="ad_enum_$(date +%Y%m%d_%H%M%S)"

# ============================================================================
# MENU GENERATION
# ============================================================================
generate_menu() {
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
        "${BRIGHT_MAGENTA}Creator: \e]8;;https://github.com/WhiteMuush\aMelvin PETIT\e]8;;\a   ${BRIGHT_RED}${BOLD}Authorized targets only${RESET}"
        " "
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_MAGENTA}Configuration:${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    Target: ${BRIGHT_MAGENTA}${TARGET:-Not set}${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    Domain: ${BRIGHT_MAGENTA}${DOMAIN:-Not set}${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    User:   ${BRIGHT_MAGENTA}${USERNAME:-Not set}${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_MAGENTA}Hunt for Active Directory intelligence:${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[1]${RESET}  Set Target"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[2]${RESET}  Set Domain"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[3]${RESET}  Set Credentials"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[4]${RESET}  Set Output Directory"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_MAGENTA}Passive Enumeration:${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[5]${RESET}  Nmap Scan"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[6]${RESET}  Enum4linux-ng"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[7]${RESET}  RPC Client"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[8]${RESET}  LDAP Search"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[9]${RESET}  DNS Enumeration"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_MAGENTA}Active Enumeration:${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[10]${RESET} BloodHound Collection"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[11]${RESET} CrackMapExec"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[12]${RESET} AD DNS Dump"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[13]${RESET} GetNPUsers (ASREPRoast)"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[14]${RESET} RID Enumeration"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_MAGENTA}Special Actions:${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[15]${RESET} Auto Workflow"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[16]${RESET} SMB Vulnerabilities"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[17]${RESET} Secrets Dump"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}    ${BRIGHT_RED}[0]${RESET}  Exit"
        "${BOLD}${BRIGHT_MAGENTA}||${RESET}"
        ""
    )
    printf '%s\n' "${menu_lines[@]}"
}

# ============================================================================
# TITLE SCREEN
# ============================================================================
readonly INFO_PANEL=(
    "${BRIGHT_RED}  ▄██████▄     ▄█    █▄     ▄██████▄     ▄████████     ███      ▄█        ▄█  ███▄▄▄▄      ▄████████${RESET}"
    "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███   ███    ███ ▀█████████▄ ███       ███  ███▀▀▀██▄   ███    ███${RESET}"
    "${BRIGHT_RED}  ███    █▀    ███    ███   ███    ███   ███    █▀     ▀███▀▀██ ███       ███▌ ███   ███   ███    █▀${RESET}"
    "${BRIGHT_RED} ▄███         ▄███▄▄▄▄███▄▄ ███    ███   ███            ███   ▀ ███       ███▌ ███   ███  ▄███▄▄▄${RESET}"
    "${BRIGHT_RED}▀▀███ ████▄  ▀▀███▀▀▀▀███▀  ███    ███ ▀███████████     ███     ███       ███▌ ███   ███ ▀▀███▀▀▀${RESET}"
    "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███          ███     ███     ███       ███  ███   ███   ███    █▄${RESET}"
    "${BRIGHT_RED}  ███    ███   ███    ███   ███    ███    ▄█    ███     ███     ███▌    ▄ ███  ███   ███   ███    ███${RESET}"
    "${BRIGHT_RED}  ████████▀    ███    █▀     ▀██████▀   ▄████████▀     ▄████▀   █████▄▄██ █▀    ▀█   █▀    ██████████${RESET}"
    ""
    "${BRIGHT_MAGENTA}${BOLD}Active Directory Osint Toolkit${RESET}"
)

display_title_middle_screen() {
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)

    local -a lines=( "${INFO_PANEL[@]}" )
    local h=${#lines[@]}

    strip_esc() {
        sed -E 's/\x1B\[[0-9;?]*[ -/]*[@-~]//g; s/\x1B\][^\a]*\a//g'
    }

    local max_w=0 raw visible_len line
    for line in "${lines[@]}"; do
        raw=$(printf "%s" "$line" | strip_esc)
        visible_len=${#raw}
        (( visible_len > max_w )) && max_w=$visible_len
    done

    local top=$(( (rows - h) / 2 ))
    (( top < 0 )) && top=0
    local left=$(( (cols - max_w) / 2 ))
    (( left < 0 )) && left=0

    printf "\033c"
    for ((i=0; i<top; i++)); do printf "\n"; done

    for line in "${lines[@]}"; do
        printf "%*s%s\n" "$left" "" "$line"
    done
}

# ============================================================================
# DISPLAY BANNER WITH MENU
# ============================================================================
display_banner_with_menu() {
    local -a ascii_lines menu_lines
    
    IFS=$'\n' read -r -d '' -a ascii_lines <<< "$ASCII_ART" || true
    IFS=$'\n' read -r -d '' -a menu_lines <<< "$(generate_menu)" || true
    
    local ascii_count=${#ascii_lines[@]}
    local menu_count=${#menu_lines[@]}
    local max_lines=$((ascii_count > menu_count ? ascii_count : menu_count))
    
    local max_ascii_width=0
    for line in "${ascii_lines[@]}"; do
        ((${#line} > max_ascii_width)) && max_ascii_width=${#line}
    done
    
    local spacing="    "
    
    for ((i=0; i<max_lines; i++)); do
        local ascii_line="${ascii_lines[i]:-}"
        local menu_line="${menu_lines[i]:-}"
        
        local colored_ascii="${BRIGHT_RED}${ascii_line}${RESET}"
        local pad=$((max_ascii_width - ${#ascii_line}))
        ((pad < 0)) && pad=0
        
        printf "   %b%*s%s%b\n" \
            "$colored_ascii" \
            "$pad" "" \
            "$spacing" \
            "$menu_line"
    done
    
    echo ""
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
check_target() {
    if [ -z "$TARGET" ]; then
        echo -e "${BRIGHT_RED}No target set!${RESET}"
        read -p "Enter target IP/hostname: " TARGET
    fi
}

check_domain() {
    if [ -z "$DOMAIN" ]; then
        echo -e "${BRIGHT_MAGENTA}No domain set${RESET}"
        read -p "Enter domain (e.g., domain.local): " DOMAIN
    fi
}

check_credentials() {
    if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
        echo -e "${BRIGHT_RED}Credentials not set!${RESET}"
        read -p "Username: " USERNAME
        read -sp "Password: " PASSWORD
        echo ""
    fi
}

# ============================================================================
# MENU HANDLERS
# ============================================================================
handle_menu_choice() {
    local choice=$1
    
    case $choice in
        1)
            echo -e "\n${BRIGHT_MAGENTA}Setting Target${RESET}"
            read -p "Target IP/hostname: " TARGET
            echo -e "${BRIGHT_GREEN}✓ Target set: ${TARGET}${RESET}"
            ;;
        2)
            echo -e "\n${BRIGHT_MAGENTA}Setting Domain${RESET}"
            read -p "Domain name: " DOMAIN
            echo -e "${BRIGHT_GREEN}✓ Domain set: ${DOMAIN}${RESET}"
            ;;
        3)
            echo -e "\n${BRIGHT_MAGENTA}Setting Credentials${RESET}"
            read -p "Username: " USERNAME
            read -sp "Password: " PASSWORD
            echo ""
            echo -e "${BRIGHT_GREEN}✓ Credentials configured${RESET}"
            ;;
        4)
            echo -e "\n${BRIGHT_MAGENTA}Setting Output Directory${RESET}"
            read -p "Directory name (default: $OUTPUT_DIR): " custom_dir
            [ -n "$custom_dir" ] && OUTPUT_DIR="$custom_dir"
            mkdir -p "$OUTPUT_DIR"
            echo -e "${BRIGHT_GREEN}✓ Output: ${OUTPUT_DIR}${RESET}"
            ;;
        5)
            echo -e "\n${BRIGHT_MAGENTA}Nmap Scan${RESET}"
            check_target
            mkdir -p "$OUTPUT_DIR"
            echo -e "${BRIGHT_MAGENTA}Scanning AD ports on ${TARGET}...${RESET}"
            nmap -p 88,135,139,389,445,464,636,3268,3269,5985 -sV -sC -oA "$OUTPUT_DIR/nmap_ad" "$TARGET"
            echo -e "${BRIGHT_GREEN}✓ Results saved to ${OUTPUT_DIR}/nmap_ad.*${RESET}"
            ;;
        6)
            echo -e "\n${BRIGHT_MAGENTA}Enum4linux-ng${RESET}"
            check_target
            mkdir -p "$OUTPUT_DIR"
            echo -e "${BRIGHT_MAGENTA}Running enum4linux-ng...${RESET}"
            enum4linux-ng -A "$TARGET" | tee "$OUTPUT_DIR/enum4linux-ng.txt"
            echo -e "${BRIGHT_GREEN}✓ Results saved${RESET}"
            ;;
        7)
            echo -e "\n${BRIGHT_MAGENTA}RPC Client${RESET}"
            check_target
            mkdir -p "$OUTPUT_DIR"
            echo -e "${BRIGHT_MAGENTA}Attempting RPC null session...${RESET}"
            {
                echo "srvinfo"
                echo "enumdomusers"
                echo "enumdomgroups"
                echo "exit"
            } | rpcclient -U "" "$TARGET" -N | tee "$OUTPUT_DIR/rpcclient.txt"
            echo -e "${BRIGHT_GREEN}✓ Results saved${RESET}"
            ;;
        8)
            echo -e "\n${BRIGHT_MAGENTA}LDAP Search${RESET}"
            check_target
            check_domain
            mkdir -p "$OUTPUT_DIR"
            BASE_DN=$(echo "$DOMAIN" | sed 's/\./,dc=/g' | sed 's/^/dc=/')
            echo -e "${BRIGHT_MAGENTA}Querying LDAP...${RESET}"
            ldapsearch -x -H ldap://"$TARGET" -b "$BASE_DN" "(objectclass=*)" | tee "$OUTPUT_DIR/ldap.txt"
            echo -e "${BRIGHT_GREEN}✓ Results saved${RESET}"
            ;;
        9)
            echo -e "\n${BRIGHT_MAGENTA}DNS Enumeration${RESET}"
            check_target
            check_domain
            mkdir -p "$OUTPUT_DIR"
            echo -e "${BRIGHT_MAGENTA}Running dnsrecon...${RESET}"
            dnsrecon -d "$DOMAIN" -n "$TARGET" | tee "$OUTPUT_DIR/dnsrecon.txt"
            echo -e "${BRIGHT_GREEN}✓ Results saved${RESET}"
            ;;
        10)
            echo -e "\n${BRIGHT_MAGENTA}BloodHound Collection${RESET}"
            check_target
            check_domain
            check_credentials
            mkdir -p "$OUTPUT_DIR"
            echo -e "${BRIGHT_MAGENTA}Collecting BloodHound data...${RESET}"
            bloodhound-python -u "$USERNAME" -p "$PASSWORD" -d "$DOMAIN" -ns "$TARGET" -c all --zip -o "$OUTPUT_DIR"
            echo -e "${BRIGHT_GREEN}✓ JSON files generated${RESET}"
            ;;
        11)
            echo -e "\n${BRIGHT_MAGENTA}CrackMapExec${RESET}"
            check_target
            check_credentials
            mkdir -p "$OUTPUT_DIR"
            CME_CMD=$(command -v crackmapexec || command -v cme)
            echo -e "${BRIGHT_MAGENTA}Running CME enumeration...${RESET}"
            $CME_CMD smb "$TARGET" -u "$USERNAME" -p "$PASSWORD" --shares | tee "$OUTPUT_DIR/cme_shares.txt"
            $CME_CMD smb "$TARGET" -u "$USERNAME" -p "$PASSWORD" --users | tee "$OUTPUT_DIR/cme_users.txt"
            echo -e "${BRIGHT_GREEN}✓ Results saved${RESET}"
            ;;
        12)
            echo -e "\n${BRIGHT_MAGENTA}AD DNS Dump${RESET}"
            check_target
            check_domain
            check_credentials
            mkdir -p "$OUTPUT_DIR"
            echo -e "${BRIGHT_MAGENTA}Dumping DNS records...${RESET}"
            adidnsdump -u "$DOMAIN\\$USERNAME" -p "$PASSWORD" "$TARGET" -r --output "$OUTPUT_DIR/dns.csv"
            echo -e "${BRIGHT_GREEN}✓ DNS records saved${RESET}"
            ;;
        13)
            echo -e "\n${BRIGHT_MAGENTA}GetNPUsers (ASREPRoast)${RESET}"
            check_target
            check_domain
            mkdir -p "$OUTPUT_DIR"
            GETNP_CMD=$(command -v GetNPUsers.py || command -v impacket-GetNPUsers)
            echo -e "${BRIGHT_MAGENTA}Searching for AS-REP roastable accounts...${RESET}"
            $GETNP_CMD "$DOMAIN/" -dc-ip "$TARGET" -no-pass | tee "$OUTPUT_DIR/asreproast.txt"
            echo -e "${BRIGHT_GREEN}✓ Results saved${RESET}"
            ;;
        14)
            echo -e "\n${BRIGHT_MAGENTA}RID Enumeration${RESET}"
            check_target
            mkdir -p "$OUTPUT_DIR"
            echo -e "${BRIGHT_MAGENTA}Enumerating RIDs...${RESET}"
            ridenum "$TARGET" 500 10000 | tee "$OUTPUT_DIR/ridenum.txt"
            echo -e "${BRIGHT_GREEN}✓ Results saved${RESET}"
            ;;
        15)
            echo -e "\n${BRIGHT_MAGENTA}${BOLD}AUTO WORKFLOW${RESET}"
            check_target
            mkdir -p "$OUTPUT_DIR"
            echo -e "${BRIGHT_MAGENTA}Running automated enumeration workflow...${RESET}"
            echo ""
            
            echo -e "${BRIGHT_MAGENTA}► Phase 1: Network Scan${RESET}"
            nmap -p 88,135,139,389,445 -sV "$TARGET" -oA "$OUTPUT_DIR/nmap" 2>/dev/null
            
            echo -e "${BRIGHT_MAGENTA}► Phase 2: SMB Enumeration${RESET}"
            enum4linux-ng -A "$TARGET" > "$OUTPUT_DIR/enum4linux.txt" 2>/dev/null
            
            echo -e "${BRIGHT_MAGENTA}► Phase 3: RPC Enumeration${RESET}"
            { echo "enumdomusers"; echo "exit"; } | rpcclient -U "" "$TARGET" -N > "$OUTPUT_DIR/rpc.txt" 2>/dev/null
            
            [ -n "$DOMAIN" ] && {
                echo -e "${BRIGHT_MAGENTA}► Phase 4: LDAP Query${RESET}"
                BASE_DN=$(echo "$DOMAIN" | sed 's/\./,dc=/g' | sed 's/^/dc=/')
                ldapsearch -x -H ldap://"$TARGET" -b "$BASE_DN" "(objectclass=user)" > "$OUTPUT_DIR/ldap.txt" 2>/dev/null
            }
            
            echo ""
            echo -e "${BRIGHT_GREEN}✓ Workflow complete! All results in ${OUTPUT_DIR}/${RESET}"
            ;;
        16)
            echo -e "\n${BRIGHT_MAGENTA}SMB Vulnerabilities${RESET}"
            check_target
            mkdir -p "$OUTPUT_DIR"
            echo -e "${BRIGHT_MAGENTA}Scanning for SMB vulnerabilities...${RESET}"
            nmap -p 445 --script smb-vuln* "$TARGET" -oA "$OUTPUT_DIR/smb_vulns"
            echo -e "${BRIGHT_GREEN}✓ Vulnerability scan complete${RESET}"
            ;;
        17)
            echo -e "\n${BRIGHT_MAGENTA}Secrets Dump${RESET}"
            check_target
            check_domain
            check_credentials
            mkdir -p "$OUTPUT_DIR"
            SECRETSDUMP=$(command -v secretsdump.py || command -v impacket-secretsdump)
            echo -e "${BRIGHT_RED}${BOLD}⚠ This requires elevated privileges!${RESET}"
            echo -e "${BRIGHT_MAGENTA}Dumping secrets...${RESET}"
            $SECRETSDUMP "$DOMAIN/$USERNAME:$PASSWORD@$TARGET" | tee "$OUTPUT_DIR/secrets.txt"
            echo -e "${BRIGHT_GREEN}✓ Secrets saved${RESET}"
            ;;
        0)
            echo -e "\n${BRIGHT_MAGENTA}Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "\n${BRIGHT_RED}Invalid choice!${RESET}"
            ;;
    esac
    
    if [[ $choice != "0" ]]; then
        echo -e "\n${BRIGHT_MAGENTA}Press Enter to continue...${RESET}"
        read -r
    fi
}

# ============================================================================
# MAIN LOOP
# ============================================================================
main_loop() {
    display_title_middle_screen
    sleep 2
    
    while true; do
        clear
        display_banner_with_menu
        echo -ne "                                                 ${BOLD}${BRIGHT_RED}▪ Choose your line, sir : ${RESET}"
        read -r choice
        
        handle_menu_choice "$choice"
    done
}

main_loop