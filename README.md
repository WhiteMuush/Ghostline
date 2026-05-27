![Gif](https://github.com/user-attachments/assets/d71682ce-9cd3-4151-9f36-0a7b29d5985f)

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg"></a>
  <a href=".github/workflows/ci.yml"><img alt="CI" src="https://github.com/WhiteMuush/GhostLine/actions/workflows/ci.yml/badge.svg"></a>
  <a href="CONTRIBUTING.md"><img alt="PRs welcome" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg"></a>
  <a href="https://github.com/koalaman/shellcheck"><img alt="Shellcheck" src="https://img.shields.io/badge/lint-shellcheck-blue.svg"></a>
</p>

**Ghostline** is an interactive bash toolkit that automates Active Directory
enumeration by integrating 10+ professional security tools into a single,
easy-to-use menu. It supports both passive reconnaissance (no credentials)
and active enumeration (with credentials).

## Features

### Configuration management
- Persistent target configuration (IP / hostname, domain, credentials).
- Custom output directory naming.
- Configuration displayed in every menu header.

### Passive enumeration (no credentials required)
- Network scanning (Nmap).
- SMB enumeration (enum4linux-ng).
- RPC null session attacks (rpcclient).
- Anonymous LDAP queries (ldapsearch).
- DNS enumeration (dnsrecon).

### Active enumeration (credentials required)
- BloodHound data collection.
- Comprehensive SMB enumeration (CrackMapExec).
- AD-integrated DNS dumping (adidnsdump).
- Kerberos pre-auth attacks (GetNPUsers).
- RID cycling enumeration (ridenum).

### Special actions
- Automated full workflow.
- SMB vulnerability scanning.
- Domain secrets extraction (secretsdump).
- Results viewer.

---

<img width="1533" height="813" alt="Screenshot" src="https://github.com/user-attachments/assets/18893b4d-298e-4551-88fc-75314cfc9d21" />

## Installation

### Prerequisites

Ghostline targets Debian / Ubuntu / Kali and bundles an installer for every
supported tool:

```bash
sudo ./install.sh
```

Or install manually:

```bash
# Debian / Ubuntu / Kali
sudo apt update
sudo apt install -y \
    nmap \
    samba-common-bin \
    ldap-utils \
    dnsrecon \
    python3 \
    python3-pip \
    pipx

# Python tools
pipx install crackmapexec
pipx install bloodhound
pipx install impacket

# GitHub-hosted tools
git clone https://github.com/cddmp/enum4linux-ng.git /opt/enum4linux-ng
git clone https://github.com/dirkjanm/adidnsdump.git  /opt/adidnsdump
git clone https://github.com/trustedsec/ridenum.git   /opt/ridenum
```

### Installing Ghostline

```bash
git clone https://github.com/WhiteMuush/GhostLine.git
cd GhostLine
chmod +x ghostline.sh
./ghostline.sh
```

---

## Quick start

### Basic usage

```bash
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

### With credentials

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

## Project layout

```
ghostline.sh               Entry point (~50 lines).
install.sh                 Installs every supported tool.
lib/
├── core.sh                Colors (TTY-aware), palette, globals.
├── ui.sh                  ASCII art and menu rendering.
├── installer.sh           Logging, prompting, install primitives.
└── modules/
    ├── config.sh          Target / domain / credentials / output.
    ├── passive.sh         Unauthenticated reconnaissance.
    ├── active.sh          Authenticated enumeration.
    └── special.sh         Workflows, vuln scans, secrets dump.
docs/
├── ARCHITECTURE.md        Layout, boot sequence, helpers, CI.
└── ADDING_A_TOOL.md       Recipe for plugging in a new tool.
.github/
├── workflows/ci.yml       shellcheck + bash -n + smoke test.
├── ISSUE_TEMPLATE/        Structured bug and tool-request forms.
└── PULL_REQUEST_TEMPLATE.md
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for details and
[CONTRIBUTING.md](CONTRIBUTING.md) for the contribution workflow.

---

## Output structure

All results are saved in a timestamped directory:

```
ad_enum_20231220_143022/
├── nmap_ad.nmap           Nmap normal output
├── nmap_ad.xml            Nmap XML (importable)
├── nmap_ad.gnmap          Nmap greppable
├── enum4linux-ng.txt      Full SMB enumeration
├── rpcclient.txt          RPC enumeration results
├── ldap.txt               LDAP query results
├── dnsrecon.txt           DNS records
├── cme_shares.txt         CrackMapExec shares
├── cme_users.txt          CrackMapExec users
├── dns.csv                AD-integrated DNS dump
├── asreproast.txt         AS-REP roastable accounts
├── ridenum.txt            RID enumeration
├── smb_vulns.nmap         SMB vulnerability scan
├── secrets.txt            Domain secrets (NTLM hashes)
└── *.json                 BloodHound data files
```

### Importing results

**BloodHound:**

```bash
neo4j console
# Then in BloodHound GUI: Upload Data → select the .json files
```

**Nmap XML:**

```bash
xsltproc nmap_ad.xml -o report.html
nmap -iL nmap_ad.xml --resume
```

---

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the
local setup, the conventions and the PR checklist. To plug in a new tool,
[docs/ADDING_A_TOOL.md](docs/ADDING_A_TOOL.md) walks through the recipe in
under a page.

- Bug reports and tool requests use the templates in
  [.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/).
- Security issues should be reported privately — see
  [SECURITY.md](SECURITY.md).

---

## Tools integrated

- [Nmap](https://github.com/nmap/nmap) — by Gordon Lyon
  Network discovery and security auditing tool. Used with NSE scripts for
  SMB, LDAP, Kerberos and AD enumeration.
- [enum4linux-ng](https://github.com/cddmp/enum4linux-ng) — by cddmp
  Modern SMB enumeration tool (users, groups, shares, policies).
- [ldapsearch (OpenLDAP)](https://git.openldap.org/openldap/openldap)
  Native LDAP query utility for extracting domain objects and attributes.
- [rpcclient (Samba)](https://github.com/samba-team/samba)
  RPC interaction tool for querying domain users, groups and SIDs via SMB.
- [CrackMapExec](https://github.com/Porchetta-Industries/CrackMapExec) — by byt3bl33d3r
  Swiss army knife for Active Directory: SMB, LDAP, WinRM, MSSQL, and more.
- [Impacket](https://github.com/SecureAuthCorp/impacket) — by SecureAuth
  Collection of Python scripts for low-level network protocol interaction.
  Includes `GetUserSPNs.py` and `secretsdump.py`.
- [BloodHound](https://github.com/BloodHoundAD/BloodHound) — by SpecterOps
  Graph-based Active Directory attack path analysis. Uses bloodhound-python
  as the data ingestor.
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

## License

Ghostline is released under the [MIT License](LICENSE). Use only against
systems you own or have explicit written permission to test.
