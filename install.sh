#!/usr/bin/env bash
# install.sh — Install every dependency required by Ghostline.
# Designed for Debian/Ubuntu/Kali. Run with sudo.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# shellcheck source=lib/core.sh
source "${SCRIPT_DIR}/lib/core.sh"
# shellcheck source=lib/installer.sh
source "${SCRIPT_DIR}/lib/installer.sh"

require_root

# ---------------------------------------------------------------------------
# Disable known broken apt repositories.
# ---------------------------------------------------------------------------
disable_broken_repos() {
    log_step "Cleaning up broken apt repositories..."
    mkdir -p /etc/apt/sources.list.d/disabled

    if ls /etc/apt/sources.list.d/*winehq* >/dev/null 2>&1; then
        mv /etc/apt/sources.list.d/*winehq* /etc/apt/sources.list.d/disabled/ \
            2>/dev/null || true
    fi

    if grep -r "zara" /etc/apt/sources.list.d/ >/dev/null 2>&1; then
        while IFS= read -r file; do
            mv "$file" /etc/apt/sources.list.d/disabled/ 2>/dev/null || true
        done < <(grep -rl "zara" /etc/apt/sources.list.d/)
    fi

    log_success "Repositories cleaned"
}

# ---------------------------------------------------------------------------
# Resolve an ldap-utils-equivalent package available on the current distro.
# ---------------------------------------------------------------------------
resolve_ldap_package() {
    local pkg
    pkg=$(apt-cache search "ldap" 2>/dev/null \
        | grep -E "ldap.*utils|openldap.*client" \
        | head -1 \
        | awk '{print $1}')
    if [[ -z "$pkg" ]]; then
        pkg="ldap-utils"
    fi
    printf '%s' "$pkg"
}

install_base_dependencies() {
    log_step "Installing base dependencies..."

    local ldap_pkg
    ldap_pkg=$(resolve_ldap_package)

    apt update -y 2>&1 | grep -v "NO_PUBKEY\|not signed" || true

    apt_install \
        git \
        python3 \
        python3-pip \
        python3-venv \
        python3-full \
        pipx \
        samba \
        samba-common-bin \
        smbclient \
        "${ldap_pkg}" \
        nmap \
        dnsrecon \
        dnsenum \
        curl \
        wget \
        build-essential \
        libsasl2-dev \
        libldap2-dev \
        libssl-dev 2>&1 | grep -v "WARNING" || true

    log_success "Base dependencies installed"

    export PATH="${PATH}:/root/.local/bin:${HOME}/.local/bin"
    pipx ensurepath 2>/dev/null || true
}

install_enum4linux_ng() {
    log_step "Installing enum4linux-ng..."
    local dest="${GHOSTLINE_TOOLS_DIR}/enum4linux-ng"
    clone_or_pull "https://github.com/cddmp/enum4linux-ng.git" "$dest"
    install_pip_requirements "$dest"
    chmod +x "${dest}/enum4linux-ng.py"
    ln -sf "${dest}/enum4linux-ng.py" /usr/local/bin/enum4linux-ng
    log_success "enum4linux-ng installed"
}

install_crackmapexec() {
    log_step "Installing CrackMapExec..."
    if apt_install crackmapexec 2>/dev/null; then
        log_success "CrackMapExec installed via apt"
    else
        pipx_install crackmapexec
        log_success "CrackMapExec installed via pipx"
    fi
}

install_adidnsdump() {
    log_step "Installing adidnsdump..."
    local dest="${GHOSTLINE_TOOLS_DIR}/adidnsdump"
    clone_or_pull "https://github.com/dirkjanm/adidnsdump.git" "$dest"
    install_pip_requirements "$dest"
    (cd "$dest" || exit 1; pip_install ".")
    log_success "adidnsdump installed"
}

install_bloodhound_py() {
    log_step "Installing BloodHound.py..."
    pipx_install bloodhound || pip_install bloodhound
    log_success "BloodHound.py installed"
}

install_ridenum() {
    log_step "Installing ridenum..."
    local dest="${GHOSTLINE_TOOLS_DIR}/ridenum"
    clone_or_pull "https://github.com/trustedsec/ridenum.git" "$dest"
    chmod +x "${dest}/ridenum.py"
    ln -sf "${dest}/ridenum.py" /usr/local/bin/ridenum
    log_success "ridenum installed"
}

install_impacket() {
    log_step "Installing Impacket..."
    pipx_install impacket || pip_install impacket
    log_success "Impacket installed"
}

install_kerbrute() {
    log_step "Installing Kerbrute..."
    local arch kerbrute_arch
    arch=$(uname -m)
    case "$arch" in
        x86_64)         kerbrute_arch="amd64" ;;
        aarch64|arm64)  kerbrute_arch="arm64" ;;
        armv7l)         kerbrute_arch="arm" ;;
        *)
            log_warn "Architecture not supported for Kerbrute: ${arch}"
            kerbrute_arch="amd64"
            ;;
    esac

    local version="1.0.3"
    local url="https://github.com/ropnop/kerbrute/releases/download/v${version}/kerbrute_linux_${kerbrute_arch}"
    local dest="${GHOSTLINE_TOOLS_DIR}/kerbrute"

    (cd "${GHOSTLINE_TOOLS_DIR}" || exit 1
        wget -q "$url" -O kerbrute 2>/dev/null \
            || curl -sL "$url" -o kerbrute)

    if [[ -f "$dest" ]]; then
        chmod +x "$dest"
        ln -sf "$dest" /usr/local/bin/kerbrute
        log_success "Kerbrute installed"
    else
        log_warn "Failed to download Kerbrute"
    fi
}

install_ldapdomaindump() {
    log_step "Installing ldapdomaindump..."
    pip_install ldapdomaindump
    log_success "ldapdomaindump installed"
}

configure_path() {
    log_step "Configuring PATH..."
    if ! grep -q ".local/bin" /root/.bashrc 2>/dev/null; then
        echo 'export PATH="$PATH:$HOME/.local/bin:/root/.local/bin"' >> /root/.bashrc
    fi

    if [[ -n "${SUDO_USER:-}" ]]; then
        local user_home
        user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        if [[ -f "${user_home}/.bashrc" ]]; then
            if ! grep -q ".local/bin" "${user_home}/.bashrc"; then
                echo 'export PATH="$PATH:$HOME/.local/bin"' >> "${user_home}/.bashrc"
                chown "${SUDO_USER}:${SUDO_USER}" "${user_home}/.bashrc"
            fi
        fi
    fi

    export PATH="${PATH}:${HOME}/.local/bin:/root/.local/bin"
}

print_summary() {
    echo ""
    echo "========================================================================"
    log_success "Installation complete."
    echo "========================================================================"
    echo ""
    echo "Installed tools:"
    printf "  [1]  enum4linux-ng    -> %s\n" "/usr/local/bin/enum4linux-ng"
    printf "  [2]  ldapsearch       -> %s\n" "$(command -v ldapsearch 2>/dev/null || echo 'install manually')"
    printf "  [3]  nmap + NSE       -> %s\n" "$(command -v nmap 2>/dev/null || echo 'not found')"
    printf "  [4]  rpcclient        -> %s\n" "$(command -v rpcclient 2>/dev/null || echo 'not found')"
    printf "  [5]  CrackMapExec     -> %s\n" "$(command -v crackmapexec 2>/dev/null || command -v cme 2>/dev/null || echo "${HOME}/.local/bin/")"
    printf "  [6]  adidnsdump       -> %s\n" "$(command -v adidnsdump 2>/dev/null || echo "${HOME}/.local/bin/")"
    printf "  [7]  BloodHound.py    -> %s\n" "$(command -v bloodhound-python 2>/dev/null || echo "${HOME}/.local/bin/")"
    printf "  [8]  ridenum          -> %s\n" "/usr/local/bin/ridenum"
    printf "  [9]  Impacket         -> %s\n" "$(command -v secretsdump.py 2>/dev/null || command -v impacket-secretsdump 2>/dev/null || echo "${HOME}/.local/bin/")"
    printf "  [10] dnsrecon/dnsenum -> %s\n" "$(command -v dnsrecon 2>/dev/null || echo 'not found')"
    printf "  [11] Kerbrute         -> %s\n" "/usr/local/bin/kerbrute"
    printf "  [12] ldapdomaindump   -> %s\n" "$(command -v ldapdomaindump 2>/dev/null || echo "${HOME}/.local/bin/")"
    echo "  [13] GetUserSPNs.py     -> (included in Impacket)"
    echo ""
    echo "IMPORTANT:"
    echo "  Reload your shell: source ~/.bashrc"
    echo "  Or restart your terminal."
    echo ""
    echo "========================================================================"
}

main() {
    disable_broken_repos
    install_base_dependencies
    install_enum4linux_ng
    install_crackmapexec
    install_adidnsdump
    install_bloodhound_py
    install_ridenum
    install_impacket
    install_kerbrute
    install_ldapdomaindump
    configure_path
    print_summary
}

main "$@"
