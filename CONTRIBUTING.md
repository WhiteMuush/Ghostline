# Contributing to Ghostline

Thanks for the interest. Ghostline is an interactive Active Directory
enumeration toolkit built on top of well-known security tools. The codebase
is plain Bash and aims to stay small, readable and contributor-friendly.

This guide covers the conventions that make a contribution easy to review
and merge.

---

## Local setup

```bash
git clone https://github.com/WhiteMuush/GhostLine.git
cd GhostLine
sudo ./install.sh        # installs every supported tool system-wide
./ghostline.sh           # launch the interactive menu
```

Ghostline targets **Debian / Ubuntu / Kali**. Other distros may work but
are not part of CI.

Optional local checks before opening a PR:

```bash
# Syntax check on every bash script
find . -name '*.sh' -not -path './.git/*' -exec bash -n {} \;

# Shellcheck (matches what CI runs)
shellcheck -e SC1091 -e SC2034 -e SC2154 \
    ghostline.sh install.sh lib/*.sh lib/modules/*.sh
```

---

## Project layout

```
ghostline.sh               Thin entry point; loads lib/ and drives the loop.
install.sh                 Installs every supported tool. Run with sudo.
lib/core.sh                Colors (TTY-aware), globals, palette.
lib/ui.sh                  ASCII art and menu rendering.
lib/installer.sh           Logging, prompting and install primitives.
lib/modules/config.sh      Target / domain / credentials / output config.
lib/modules/passive.sh     Unauthenticated reconnaissance.
lib/modules/active.sh      Authenticated enumeration.
lib/modules/special.sh     Workflows, vuln scans, secrets dump.
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full description
and [docs/ADDING_A_TOOL.md](docs/ADDING_A_TOOL.md) if you want to plug in
a new tool.

---

## Code conventions

### Shell

- `#!/usr/bin/env bash` shebang on every executable script.
- Strict mode at the entry point only: `set -uo pipefail` for the
  interactive `ghostline.sh`, `set -euo pipefail` for the non-interactive
  `install.sh`. **Do not** add `set -e` to interactive menus — a single
  non-zero exit code kills the whole loop.
- Always quote variable expansions: `"${var}"`, not `$var`.
- Function names are `snake_case` and prefixed by their module:
  `passive_run_nmap`, `active_run_cme`, etc.
- Global state lives in `GHOSTLINE_*` variables defined in `lib/core.sh`.
- Logging goes through `log_step / log_info / log_warn / log_error /
  log_success`. Do not emit raw `echo -e ${RED}...${RESET}` from
  application code.
- User prompts go through `prompt_value / prompt_password / prompt_yesno`.
- Tool presence is checked with `ensure_command` (and `resolve_command`
  for binaries with multiple possible names).
- Use `mapfile -t arr <<<"$STRING"` or `mapfile -t arr < <(cmd)` for
  array splitting. Avoid the legacy `IFS=$'\n' read -r -d '' -a` pattern.

### Language

Every file in the repository is **English only** — code, comments, log
messages, prompts, README, docs, commit messages. PRs that introduce
non-English content will be asked to translate before merge.

### Comments

Default to writing no comments. Only add one when the *why* is
non-obvious. Don't restate what well-named code already says.

### Commit messages

Conventional Commits:

```
type: short imperative summary
```

Common types: `feat`, `fix`, `refactor`, `docs`, `ci`, `chore`, `test`.

---

## CI

Every PR runs three checks:

1. **shellcheck** with warning severity and a small ignore list
   (`SC1091`, `SC2034`, `SC2154`).
2. **bash -n** on every `.sh` for syntax.
3. **Smoke test** that sources the full `lib/` chain and asserts that
   every public function is defined.

All three must pass before review.

---

## Reporting bugs and proposing tools

- Bugs: open an issue with the **Bug report** template.
- New tools: open an issue with the **Tool request** template. Bonus
  points for opening the PR that wires the tool in.
- Security issues: see [SECURITY.md](SECURITY.md).

---

## Authorized use only

Ghostline is for **authorized security testing** (pentest engagements,
CTFs, lab environments). Don't open issues asking for help against
networks you do not own or have written permission to test.
