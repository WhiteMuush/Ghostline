#!/usr/bin/env bash
# lib/installer.sh — Logging, prompting and install primitives.
# Sourced by both the runtime entry point and install.sh.

if [[ -n "${GHOSTLINE_INSTALLER_LOADED:-}" ]]; then
    return 0
fi
GHOSTLINE_INSTALLER_LOADED=1

# ---------------------------------------------------------------------------
# Logging — color-coded, with a consistent prefix.
# ---------------------------------------------------------------------------
log_step()    { printf '%b[*]%b %s\n' "${BLUE}"   "${RESET}" "$*"; }
log_info()    { printf '%b[i]%b %s\n' "${CYAN}"   "${RESET}" "$*"; }
log_warn()    { printf '%b[!]%b %s\n' "${YELLOW}" "${RESET}" "$*" >&2; }
log_error()   { printf '%b[-]%b %s\n' "${RED}"    "${RESET}" "$*" >&2; }
log_success() { printf '%b[+]%b %s\n' "${GREEN}"  "${RESET}" "$*"; }

# ---------------------------------------------------------------------------
# Prompting helpers — keep behavior consistent across modules.
# ---------------------------------------------------------------------------
prompt_value() {
    local label="$1"
    local default="${2:-}"
    local response
    if [[ -n "$default" ]]; then
        read -rp "${label} [${default}]: " response
        response="${response:-$default}"
    else
        read -rp "${label}: " response
    fi
    printf '%s' "$response"
}

prompt_password() {
    local label="$1"
    local response
    read -rsp "${label}: " response
    echo ""
    printf '%s' "$response"
}

prompt_yesno() {
    local label="$1"
    local default="${2:-n}"
    local hint
    case "$default" in
        y|Y) hint="Y/n" ;;
        *)   hint="y/N" ;;
    esac
    local response
    read -rp "${label} [${hint}]: " response
    response="${response:-$default}"
    [[ "$response" =~ ^[Yy]([Ee][Ss])?$ ]]
}

press_enter_to_continue() {
    read -rp "Press Enter to continue..." _
}

# ---------------------------------------------------------------------------
# Runtime — verify a binary is on PATH or warn cleanly.
# Returns 0 if the command exists, 1 otherwise.
# ---------------------------------------------------------------------------
ensure_command() {
    local cmd="$1"
    local hint="${2:-}"
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    fi
    log_warn "Required command not found: ${cmd}"
    if [[ -n "$hint" ]]; then
        log_info "Hint: ${hint}"
    else
        log_info "Try running 'sudo ./install.sh' first."
    fi
    return 1
}

# Resolve the first available command from a list of alternatives.
# Echoes the resolved path on stdout, or returns 1 if none are found.
resolve_command() {
    local candidate
    for candidate in "$@"; do
        if command -v "$candidate" >/dev/null 2>&1; then
            command -v "$candidate"
            return 0
        fi
    done
    return 1
}

# ---------------------------------------------------------------------------
# Network capability probes
# ---------------------------------------------------------------------------

# has_raw_socket
# Returns 0 only when a raw socket can actually be opened, so nmap SYN scans,
# OS detection, etc. work. Returns non-zero for an unprivileged user or a
# rootless podman box, where CAP_NET_RAW can appear set in CapEff yet stay
# ineffective over the host network namespace. Because that bit lies in the
# rootless case, the only reliable test is to open a socket for real; the
# verdict is cached for the session. With no interpreter to try, it assumes no
# raw socket (safe: a connect scan works everywhere).
has_raw_socket() {
    case "${_GHOSTLINE_RAW_SOCKET:-}" in
        yes) return 0 ;;
        no)  return 1 ;;
    esac
    local rc=1
    if command -v python3 >/dev/null 2>&1; then
        python3 - <<'PY' 2>/dev/null
import socket, sys
try:
    socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_TCP).close()
except OSError:
    sys.exit(1)
PY
        rc=$?
    elif command -v perl >/dev/null 2>&1; then
        perl -e 'use Socket; socket(my $s, AF_INET, SOCK_RAW, getprotobyname("tcp")) or exit 1;' 2>/dev/null
        rc=$?
    fi
    if [[ $rc -eq 0 ]]; then _GHOSTLINE_RAW_SOCKET=yes; else _GHOSTLINE_RAW_SOCKET=no; fi
    return "$rc"
}

# safe_nmap [args...]
# Runs nmap so it never dies on "Couldn't open a raw socket": with no raw
# socket available it prepends --unprivileged, forcing a TCP connect scan.
# Pass ordinary nmap arguments; do not add -sS/-sU/-O, which cannot run
# unprivileged and would conflict with the fallback.
safe_nmap() {
    local -a priv=()
    if ! has_raw_socket; then
        priv+=(--unprivileged)
        if [[ -z "${_GHOSTLINE_NMAP_NOTICE:-}" ]]; then
            log_warn "No raw socket available; nmap will run an unprivileged TCP connect scan."
            _GHOSTLINE_NMAP_NOTICE=1
        fi
    fi
    nmap "${priv[@]}" "$@"
}

# ---------------------------------------------------------------------------
# Install-time primitives — used by install.sh.
# ---------------------------------------------------------------------------
apt_install() {
    apt install -y "$@"
}

pipx_install() {
    local package="$1"
    pipx install "$package" --force 2>&1 | grep -v "WARNING" || true
}

# Best-effort pip install with progressive fallbacks for modern Debian/Kali.
pip_install() {
    local package="$1"
    python3 -m pip install --user --ignore-installed "$package" 2>/dev/null \
        || python3 -m pip install --break-system-packages --ignore-installed "$package" 2>/dev/null \
        || python3 -m pip install --user "$package" 2>/dev/null \
        || python3 -m pip install --break-system-packages "$package" 2>/dev/null
}

install_pip_requirements() {
    local req_dir="$1"
    local req_file="${req_dir}/requirements.txt"
    [[ -f "$req_file" ]] || return 0
    local pkg
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
        pip_install "$pkg"
    done < "$req_file"
}

# Clone a repo into <dest> or git pull --ff-only if it already exists.
clone_or_pull() {
    local url="$1"
    local dest="$2"
    if [[ -d "${dest}/.git" ]]; then
        (cd "$dest" || return 1; git pull --ff-only) >/dev/null 2>&1
    else
        git clone "$url" "$dest" >/dev/null 2>&1
    fi
}

# Source check used by install.sh.
require_root() {
    if [[ ${EUID} -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)."
        exit 1
    fi
}
