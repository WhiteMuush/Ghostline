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
