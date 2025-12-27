# GhostLine

**GhostLine** is an interactive bash toolkit that automates Active Directory enumeration by integrating 10+ professional security tools into a beautiful, easy-to-use interface. Inspired by the aesthetics of "Feed Your Spider", it provides both passive and active reconnaissance capabilities.

### Why GhostLine?

- **Beautiful Interface**: ASCII art and colored menus inspired by modern security tools
- **All-in-One**: No need to remember dozens of commands
- **Organized Results**: All outputs automatically saved in timestamped directories
- **Automated Workflows**: Run complete reconnaissance with a single command
- **Structured Navigation**: Hierarchical menus for easy access to specific tools

---

## Features

### Configuration Management
- Persistent target configuration (IP/Hostname, Domain, Credentials)
- Custom output directory naming
- Configuration displayed in all menus

### Passive Enumeration (No Credentials Required)
- Network scanning (Nmap)
- SMB enumeration (enum4linux-ng)
- RPC null session attacks (rpcclient)
- Anonymous LDAP queries (ldapsearch)
- DNS enumeration (dnsrecon)

### Active Enumeration (Credentials Required)
- BloodHound data collection
- Comprehensive SMB enumeration (CrackMapExec)
- AD-integrated DNS dumping (adidnsdump)
- Kerberos pre-auth attacks (GetNPUsers)
- RID cycling enumeration (ridenum)

### Special Actions
- Automated full workflow
- SMB vulnerability scanning
- Domain secrets extraction (secretsdump)
- Results viewer

---

## Installation

### Prerequisites

GhostLine requires the following tools to be installed:

```bash
# Install all tools at once with the installation script
sudo ./install.sh
```

Or install manually:

```bash
# Debian/Ubuntu/Kali
sudo apt update
sudo apt install -y \
    nmap \
    samba-common-bin \
    ldap-utils \
    dnsrecon \
    python3 \
    python3-pip \
    pipx

# Install Python tools
pipx install crackmapexec
pipx install bloodhound
pipx install impacket

# Install from GitHub
git clone https://github.com/cddmp/enum4linux-ng.git /opt/enum4linux-ng
git clone https://github.com/dirkjanm/adidnsdump.git /opt/adidnsdump
git clone https://github.com/trustedsec/ridenum.git /opt/ridenum
```

### Installing GhostLine

```bash
# Clone the repository
git clone https://github.com/WhiteMuush/GhostLine.git
cd GhostLine

# Make executable
chmod +x ghostline.sh

# Run
./ghostline.sh
```

---

## Quick Start

### Basic Usage

```bash
# Launch GhostLine
./ghostline.sh

# 1. Configure your target
Main Menu → [1] Configuration Menu
    → [1] Set Target: 192.168.1.10
    → [2] Set Domain: corp.local
    → [0] Back

# 2. Run automated reconnaissance
Main Menu → [4] Special Actions
    → [1] Auto Workflow

# 3. View results
Main Menu → [4] Special Actions
    → [4] View Results
```

### With Credentials

```bash
# 1. Configure credentials
Main Menu → [1] Configuration Menu
    → [3] Set Credentials
        Username: john.doe
        Password: ********

# 2. Run BloodHound collection
Main Menu → [3] Active Enumeration
    → [1] BloodHound Collection

# Results saved in: ad_enum_YYYYMMDD_HHMMSS/
```

---

##  Usage Examples

### Example 1: Initial Reconnaissance (No Credentials)

```bash
./ghostline.sh

# Configuration
[1] Configuration Menu
    [1] Set Target: 10.10.10.100
    [0] Back

# Automated passive scan
[4] Special Actions
    [1] Auto Workflow

# Output:
# ✓ Nmap scan completed
# ✓ SMB enumeration completed
# ✓ RPC null session tested
# ✓ LDAP anonymous bind tested
# ✓ Results saved in: ad_enum_20231220_143022/
```

### Example 2: Authenticated Enumeration

```bash
# Configuration
[1] Configuration Menu
    [1] Set Target: dc01.corp.local
    [2] Set Domain: corp.local
    [3] Set Credentials
        Username: john.doe
        Password: P@ssw0rd123

# Collect BloodHound data
[3] Active Enumeration
    [1] BloodHound Collection

# Output:
# ✓ Collecting domain data...
# ✓ JSON files generated: computers.json, users.json, groups.json
# ✓ Import into BloodHound GUI
```

### Example 3: Vulnerability Assessment

```bash
# SMB vulnerability scan
[4] Special Actions
    [2] SMB Vulnerabilities Scan

# Output:
# | smb-vuln-ms17-010:
# |   VULNERABLE:
# |   Remote Code Execution vulnerability in SMBv1
# |     State: VULNERABLE
# |     IDs:  CVE:CVE-2017-0143
```

### Example 4: Complete Pentest Workflow

```bash
# 1. Configure everything
[1] Configuration → Set all parameters

# 2. Passive reconnaissance
[2] Passive Enumeration → Run all options [1-5]

# 3. Active enumeration (if creds obtained)
[3] Active Enumeration → Run all options [1-5]

# 4. Advanced attacks
[4] Special Actions → [2] SMB Vulns → [3] Secrets Dump

# 5. Review results
[4] Special Actions → [4] View Results
```

---

##  Output Structure

All results are saved in a timestamped directory:

```
ad_enum_20231220_143022/
├── nmap_ad.nmap           # Nmap normal output
├── nmap_ad.xml            # Nmap XML (importable)
├── nmap_ad.gnmap          # Nmap greppable
├── enum4linux-ng.txt      # Full SMB enumeration
├── rpcclient.txt          # RPC enumeration results
├── ldap.txt               # LDAP query results
├── dnsrecon.txt           # DNS records
├── cme_shares.txt         # CrackMapExec shares
├── cme_users.txt          # CrackMapExec users
├── dns.csv                # AD-integrated DNS dump
├── asreproast.txt         # AS-REP roastable accounts
├── ridenum.txt            # RID enumeration
├── smb_vulns.nmap         # SMB vulnerability scan
├── secrets.txt            # Domain secrets (NTLM hashes)
└── *.json                 # BloodHound data files
```

### Importing Results

**BloodHound:**
```bash
# Import JSON files into BloodHound
neo4j console
# Then in BloodHound GUI: Upload Data → Select .json files
```

**Nmap XML:**
```bash
# Open in various tools
xsltproc nmap_ad.xml -o report.html
nmap -iL nmap_ad.xml --resume
```

---
##  Contributing

Contributions are welcome! Here's how you can help:

### Reporting Bugs
Open an issue with:
- GhostLine version
- Operating system
- Steps to reproduce
- Expected vs actual behavior

### Suggesting Features
Open an issue with:
- Feature description
- Use case
- Expected benefits

---

### Tools Integrated
- [Nmap](https://nmap.org/) by Gordon Lyon
- [enum4linux-ng](https://github.com/cddmp/enum4linux-ng) by cddmp
- [Impacket](https://github.com/SecureAuthCorp/impacket) by SecureAuth Corporation
- [BloodHound](https://github.com/BloodHoundAD/BloodHound) by SpecterOps
- [CrackMapExec](https://github.com/byt3bl33d3r/CrackMapExec) by byt3bl33d3r
- [adidnsdump](https://github.com/dirkjanm/adidnsdump) by dirkjanm
- [ridenum](https://github.com/trustedsec/ridenum) by TrustedSec

---

Same script in powershell coming soon !