# GhostLine

**GhostLine** is an interactive bash toolkit that automates Active Directory enumeration by integrating 10+ professional security tools into a beautiful, easy-to-use interface. Inspired by the aesthetics of "Feed Your Spider", it provides both passive and active reconnaissance capabilities.

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

![GhostlineImage](image.png)

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

- [Nmap](https://github.com/nmap/nmap) — by Gordon Lyon  
  Network discovery and security auditing tool. Used with NSE scripts for SMB, LDAP, Kerberos and AD enumeration.

- [enum4linux-ng](https://github.com/cddmp/enum4linux-ng) — by cddmp  
  Modern SMB enumeration tool (users, groups, shares, policies).

- [ldapsearch (OpenLDAP)](https://git.openldap.org/openldap/openldap)  
  Native LDAP query utility for extracting domain objects and attributes.

- [rpcclient (Samba)](https://github.com/samba-team/samba)  
  RPC interaction tool for querying domain users, groups and SIDs via SMB.

- [CrackMapExec](https://github.com/Porchetta-Industries/CrackMapExec) — by byt3bl33d3r  
  Swiss army knife for Active Directory: SMB, LDAP, WinRM, MSSQL, and more.

- [Impacket](https://github.com/SecureAuthCorp/impacket) — by SecureAuth Corporation  
  Collection of Python scripts for low-level network protocol interaction. Includes tools such as GetUserSPNs.py and secretsdump.py.

- [BloodHound](https://github.com/BloodHoundAD/BloodHound) — by SpecterOps  
  Graph-based Active Directory attack path analysis. Uses bloodhound-python as the data ingestor.

- [bloodhound-python](https://github.com/fox-it/BloodHound.py) — data ingestor  
  CLI collector used by BloodHound.

- [adidnsdump](https://github.com/dirkjanm/adidnsdump) — by dirkjanm  
  Enumerates Active Directory–integrated DNS records via LDAP.

- [ridenum](https://github.com/trustedsec/ridenum) — by TrustedSec  
  RID cycling tool for enumerating domain users.

- [dnsrecon](https://github.com/darkoperator/dnsrecon) — by DarkOperator  
  DNS reconnaissance tool (alternative: dnsenum).

- [Kerbrute](https://github.com/ropnop/kerbrute) — by ropnop  
  Kerberos-based user enumeration and password spraying tool.

- [ldapdomaindump](https://github.com/dirkjanm/ldapdomaindump) — by dirkjanm  
  Dumps LDAP domain information into human-readable reports.

---

Same script in powershell coming soon !