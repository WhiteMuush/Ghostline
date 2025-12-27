#!/bin/bash

################################################################################
# Script d'installation des outils d'énumération Active Directory
# Version simplifiée - Installation uniquement
################################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[*]${NC} $1"; }
print_success() { echo -e "${GREEN}[+]${NC} $1"; }
print_error() { echo -e "${RED}[-]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

################################################################################
# VÉRIFICATION ROOT
################################################################################

if [[ $EUID -ne 0 ]]; then
    print_error "Ce script doit être exécuté en tant que root (sudo)"
    exit 1
fi

################################################################################
# CORRECTION DES DÉPÔTS PROBLÉMATIQUES
################################################################################

print_status "Correction des dépôts problématiques..."

# Créer le dossier de sauvegarde
mkdir -p /etc/apt/sources.list.d/disabled 2>/dev/null

# Désactiver WineHQ
if ls /etc/apt/sources.list.d/*winehq* 1> /dev/null 2>&1; then
    mv /etc/apt/sources.list.d/*winehq* /etc/apt/sources.list.d/disabled/ 2>/dev/null || true
fi

# Désactiver Docker avec version incorrecte
if grep -r "zara" /etc/apt/sources.list.d/ 2>/dev/null; then
    grep -rl "zara" /etc/apt/sources.list.d/ | while read file; do
        mv "$file" /etc/apt/sources.list.d/disabled/ 2>/dev/null || true
    done
fi

print_success "Dépôts corrigés"

################################################################################
# MISE À JOUR DU SYSTÈME
################################################################################

print_status "Mise à jour du système..."
apt update -y 2>&1 | grep -v "NO_PUBKEY\|pas signé" || true
print_success "Système mis à jour"

################################################################################
# INSTALLATION DES DÉPENDANCES DE BASE
################################################################################

print_status "Installation des dépendances de base..."

# Recherche du paquet LDAP disponible
LDAP_PKG=$(apt-cache search "ldap" 2>/dev/null | grep -E "ldap.*utils|openldap.*client" | head -1 | awk '{print $1}')
[ -z "$LDAP_PKG" ] && LDAP_PKG="ldap-utils"

apt install -y \
    git \
    python3 \
    python3-pip \
    python3-venv \
    python3-full \
    pipx \
    samba \
    samba-common-bin \
    smbclient \
    "${LDAP_PKG}" \
    nmap \
    dnsrecon \
    dnsenum \
    curl \
    wget \
    build-essential \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev 2>&1 | grep -v "WARNING" || true

print_success "Dépendances de base installées"

# Configuration pipx
export PATH="$PATH:/root/.local/bin:$HOME/.local/bin"
pipx ensurepath 2>/dev/null || true

################################################################################
# FONCTION D'INSTALLATION PYTHON
################################################################################

pip_install() {
    local package=$1
    python3 -m pip install --user --ignore-installed "$package" 2>/dev/null || \
    python3 -m pip install --break-system-packages --ignore-installed "$package" 2>/dev/null || \
    python3 -m pip install --user "$package" 2>/dev/null || \
    python3 -m pip install --break-system-packages "$package" 2>/dev/null
}

################################################################################
# 1. ENUM4LINUX-NG
################################################################################

print_status "Installation de enum4linux-ng..."

cd /opt
if [ -d "enum4linux-ng" ]; then
    cd enum4linux-ng && git pull
else
    git clone https://github.com/cddmp/enum4linux-ng.git
    cd enum4linux-ng
fi

if [ -f "requirements.txt" ]; then
    while IFS= read -r pkg; do
        [ -z "$pkg" ] || [[ "$pkg" =~ ^# ]] && continue
        pip_install "$pkg"
    done < requirements.txt
fi

chmod +x enum4linux-ng.py
ln -sf /opt/enum4linux-ng/enum4linux-ng.py /usr/local/bin/enum4linux-ng

print_success "enum4linux-ng installé"

################################################################################
# 2. CRACKMAPEXEC
################################################################################

print_status "Installation de CrackMapExec..."

if apt install -y crackmapexec 2>/dev/null; then
    print_success "CrackMapExec installé via apt"
else
    pipx install crackmapexec --force 2>&1 | grep -v "WARNING" || true
    print_success "CrackMapExec installé via pipx"
fi

################################################################################
# 3. ADIDNSDUMP
################################################################################

print_status "Installation de adidnsdump..."

cd /opt
if [ -d "adidnsdump" ]; then
    cd adidnsdump && git pull
else
    git clone https://github.com/dirkjanm/adidnsdump.git
    cd adidnsdump
fi

if [ -f "requirements.txt" ]; then
    while IFS= read -r pkg; do
        [ -z "$pkg" ] || [[ "$pkg" =~ ^# ]] && continue
        pip_install "$pkg"
    done < requirements.txt
fi

pip_install "."

print_success "adidnsdump installé"

################################################################################
# 4. BLOODHOUND.PY
################################################################################

print_status "Installation de BloodHound.py..."

pipx install bloodhound --force 2>&1 | grep -v "WARNING" || pip_install "bloodhound"

print_success "BloodHound.py installé"

################################################################################
# 5. RIDENUM
################################################################################

print_status "Installation de ridenum..."

cd /opt
if [ -d "ridenum" ]; then
    cd ridenum && git pull
else
    git clone https://github.com/trustedsec/ridenum.git
fi

chmod +x /opt/ridenum/ridenum.py
ln -sf /opt/ridenum/ridenum.py /usr/local/bin/ridenum

print_success "ridenum installé"

################################################################################
# 6. IMPACKET
################################################################################

print_status "Installation de Impacket..."

pipx install impacket --force 2>&1 | grep -v "WARNING" || pip_install "impacket"

print_success "Impacket installé"

################################################################################
# 7. KERBRUTE
################################################################################

print_status "Installation de Kerbrute..."

# Détecter l'architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        KERBRUTE_ARCH="amd64"
        ;;
    aarch64|arm64)
        KERBRUTE_ARCH="arm64"
        ;;
    armv7l)
        KERBRUTE_ARCH="arm"
        ;;
    *)
        print_warning "Architecture non supportée pour Kerbrute: $ARCH"
        KERBRUTE_ARCH="amd64"
        ;;
esac

# Télécharger la dernière version
KERBRUTE_VERSION="1.0.3"
KERBRUTE_URL="https://github.com/ropnop/kerbrute/releases/download/v${KERBRUTE_VERSION}/kerbrute_linux_${KERBRUTE_ARCH}"

cd /opt
wget -q "$KERBRUTE_URL" -O kerbrute 2>/dev/null || curl -sL "$KERBRUTE_URL" -o kerbrute

if [ -f "kerbrute" ]; then
    chmod +x kerbrute
    ln -sf /opt/kerbrute /usr/local/bin/kerbrute
    print_success "Kerbrute installé"
else
    print_warning "Échec du téléchargement de Kerbrute"
fi

################################################################################
# 8. LDAPDOMAINDUMP
################################################################################

print_status "Installation de ldapdomaindump..."

pip_install "ldapdomaindump"

print_success "ldapdomaindump installé"

################################################################################
# CONFIGURATION FINALE
################################################################################

print_status "Configuration du PATH..."

# Ajout au bashrc
if ! grep -q ".local/bin" /root/.bashrc 2>/dev/null; then
    echo 'export PATH="$PATH:$HOME/.local/bin:/root/.local/bin"' >> /root/.bashrc
fi

if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo ~$SUDO_USER)
    if [ -f "$USER_HOME/.bashrc" ]; then
        if ! grep -q ".local/bin" "$USER_HOME/.bashrc"; then
            echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$USER_HOME/.bashrc"
            chown $SUDO_USER:$SUDO_USER "$USER_HOME/.bashrc"
        fi
    fi
fi

export PATH="$PATH:$HOME/.local/bin:/root/.local/bin"

################################################################################
# RÉSUMÉ
################################################################################

echo ""
echo "========================================================================"
echo -e "${GREEN}✓ Installation terminée avec succès!${NC}"
echo "========================================================================"
echo ""
echo "Outils installés:"
echo "  [1] enum4linux-ng       -> /usr/local/bin/enum4linux-ng"
echo "  [2] ldapsearch          -> $(which ldapsearch 2>/dev/null || echo 'À installer manuellement')"
echo "  [3] nmap + NSE          -> $(which nmap 2>/dev/null || echo 'Non trouvé')"
echo "  [4] rpcclient           -> $(which rpcclient 2>/dev/null || echo 'Non trouvé')"
echo "  [5] CrackMapExec        -> $(which crackmapexec 2>/dev/null || which cme 2>/dev/null || echo '~/.local/bin/')"
echo "  [6] adidnsdump          -> $(which adidnsdump 2>/dev/null || echo '~/.local/bin/')"
echo "  [7] BloodHound.py       -> $(which bloodhound-python 2>/dev/null || echo '~/.local/bin/')"
echo "  [8] ridenum             -> /usr/local/bin/ridenum"
echo "  [9] Impacket            -> $(which secretsdump.py 2>/dev/null || which impacket-secretsdump 2>/dev/null || echo '~/.local/bin/')"
echo "  [10] dnsrecon/dnsenum   -> $(which dnsrecon 2>/dev/null || echo 'Non trouvé')"
echo "  [11] Kerbrute           -> /usr/local/bin/kerbrute"
echo "  [12] ldapdomaindump     -> $(which ldapdomaindump 2>/dev/null || echo '~/.local/bin/')"
echo "  [13] GetUserSPNs.py     -> (Included in Impacket)"
echo ""
echo "IMPORTANT:"
echo "  Rechargez votre shell: source ~/.bashrc"
echo "  Ou redémarrez votre terminal"
echo ""
echo "========================================================================"