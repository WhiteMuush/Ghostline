# Security Policy

Ghostline is an **offensive security toolkit**. It is meant to be run by
authorized testers against Active Directory environments they own or
have explicit written permission to test. Misuse is the responsibility
of the operator.

## Scope of this policy

This policy covers vulnerabilities **in the Ghostline wrapper itself** —
the entry point, the library, the menus and the installer. Examples:

- Command injection via a configuration field that isn't properly quoted.
- Path traversal in the output directory handling.
- Credentials accidentally written to disk or logs.
- Privilege escalation through the installer.

It does **not** cover vulnerabilities in the third-party tools
Ghostline wraps (`nmap`, `enum4linux-ng`, `bloodhound-python`,
`crackmapexec`, `impacket`, etc.). Report those upstream.

## Reporting a vulnerability

**Please do not open a public issue.** Use one of the private channels:

1. [GitHub Security Advisories](https://github.com/WhiteMuush/Ghostline/security/advisories/new)
   — preferred, lets us collaborate on a fix.
2. Direct contact via the email address on the maintainer's GitHub
   profile.

Include:

- The Ghostline version (commit SHA or release tag).
- A clear description of the issue and the impact.
- A reproduction recipe — exact menu path, target setup, payload.
- (Optional) a suggested fix.

## What to expect

- Acknowledgement within 7 days.
- A discussion of the impact and the proposed fix.
- Coordinated disclosure once a patch is ready. Credit goes to the
  reporter unless they prefer to stay anonymous.
