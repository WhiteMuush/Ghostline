![Ghostline](https://github.com/user-attachments/assets/d71682ce-9cd3-4151-9f36-0a7b29d5985f)

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg"></a>
  <a href=".github/workflows/ci.yml"><img alt="CI" src="https://github.com/WhiteMuush/Ghostline/actions/workflows/ci.yml/badge.svg"></a>
  <a href="docs/CONTRIBUTING.md"><img alt="PRs welcome" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg"></a>
  <a href="https://github.com/koalaman/shellcheck"><img alt="Shellcheck" src="https://img.shields.io/badge/lint-shellcheck-blue.svg"></a>
</p>

**Ghostline** drives a full Active Directory enumeration from one bash menu.
Set a target once, then run passive recon with no credentials or authenticated
enumeration when you have them, and every tool writes to the same timestamped
folder.

## Quick start

```bash
git clone https://github.com/WhiteMuush/Ghostline.git
cd Ghostline && chmod +x ghostline.sh
sudo ./install.sh   # Debian / Ubuntu / Kali: pulls every supported tool
./ghostline.sh
```

On a Debian/Kali host Ghostline runs natively. On Fedora, Arch or an atomic
distro (Bazzite, Silverblue) it offers a shared Debian box (podman/docker) and
reuses it across toolkits. Inside that box nmap falls back to an unprivileged
connect scan automatically, so a scan never dies on a missing raw socket. See
[docs/DISTRO_COMPAT.md](docs/DISTRO_COMPAT.md).

<img width="1533" height="813" alt="Ghostline menu" src="https://github.com/user-attachments/assets/18893b4d-298e-4551-88fc-75314cfc9d21" />

## What it runs

Set your target, domain and (optional) credentials once in the Configuration
menu; they show in every header and drive the tools below.

| Phase | Tools |
|---|---|
| **Passive** (no creds) | Nmap, enum4linux-ng, rpcclient, ldapsearch, dnsrecon |
| **Active** (creds) | BloodHound (bloodhound-python), CrackMapExec / NetExec, adidnsdump, Impacket (GetNPUsers), ridenum |
| **Special** | Automated full workflow, SMB vuln scan, domain secrets dump (secretsdump), results viewer |

Empty output from an anonymous module usually means the DC is hardened, a valid
finding, not a bug. Retry with credentials via Active Enumeration.

## Output

Every run writes to a timestamped folder (`ad_enum_YYYYMMDD_HHMMSS/`): Nmap in
all three formats, SMB/RPC/LDAP/DNS enumeration, CrackMapExec shares and users,
AD-integrated DNS, AS-REP roastable accounts, SMB vuln scan, domain secrets and
BloodHound `.json` files ready to upload.

## Project layout

```
ghostline.sh          entry point (~50 lines)
install.sh            installs every supported tool
lib/
├── core.sh           TTY-aware colors, palette, globals
├── ui.sh             ASCII art and menu rendering
├── installer.sh      logging, prompting, install primitives
├── compat.sh         native-or-box runtime (shared module)
└── modules/          config, passive, active, special
docs/                 ARCHITECTURE, ADDING_A_TOOL, CONTRIBUTING, SECURITY
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the internals.

## Contributing

PRs welcome, see [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for setup and the
checklist, and [docs/ADDING_A_TOOL.md](docs/ADDING_A_TOOL.md) to plug in a new
tool in under a page. Bug reports and tool requests use the
[issue templates](.github/ISSUE_TEMPLATE/); security issues go private via
[docs/SECURITY.md](docs/SECURITY.md).

## License

[MIT](LICENSE). Use only against systems you own or have explicit written
permission to test.
