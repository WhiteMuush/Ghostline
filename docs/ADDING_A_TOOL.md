# Adding a tool to Ghostline

Most contributions add a new tool to one of the existing modules. The
process is intentionally short — a single function, a single menu line,
optionally a few lines in `install.sh`.

This document walks through the recipe step by step.

---

## Pick a module

| Module                       | Use case                                              |
|------------------------------|-------------------------------------------------------|
| `lib/modules/passive.sh`     | Runs without credentials                              |
| `lib/modules/active.sh`      | Requires a domain user / password                     |
| `lib/modules/special.sh`     | Workflows, vuln scans, post-exploitation              |

If your tool doesn't fit any of the above, open an issue first so we can
agree on whether to create a new module.

---

## Anatomy of a module function

Every module function follows the same five-line shape:

```bash
<module>_run_<tool>() {
    require_target
    [require_domain]                                          # if needed
    [require_credentials]                                     # if needed
    ensure_command "<binary>" "<install hint>" || return 0
    ensure_output_dir

    log_step "Running <tool>..."
    <binary> "${GHOSTLINE_TARGET}" ... \
        | tee "${GHOSTLINE_OUTPUT_DIR}/<output_file>"
    log_success "Results saved"
    press_enter_to_continue
}
```

That's it. The framework handles colors, prompting, missing-tool
warnings and output directory creation.

If the binary may be packaged under several names (for example
`crackmapexec` vs. `cme` vs. `nxc`), use `resolve_command` instead of
`ensure_command`:

```bash
local cme
if ! cme=$(resolve_command "crackmapexec" "cme" "nxc"); then
    log_warn "Neither crackmapexec, cme nor nxc is installed."
    log_info "Hint: pipx install netexec"
    return 0
fi
"$cme" smb "${GHOSTLINE_TARGET}" -u "${GHOSTLINE_USERNAME}" ...
```

---

## Wire it into the menu

Two edits in the same module file:

### 1. Update `generate_<module>_menu` in `lib/ui.sh`

Add one line in the `menu_lines` array for the new entry:

```bash
"${BOLD}${BRIGHT_RED}█${RESET}    ${BRIGHT_RED}[6]${RESET}  My Cool Tool"
```

### 2. Update `handle_<module>_menu` in `lib/modules/<module>.sh`

Add the matching case:

```bash
case "$choice" in
    1) passive_run_nmap ;;
    2) passive_run_enum4linux ;;
    ...
    6) passive_run_my_cool_tool ;;
    0) return ;;
esac
```

---

## Update `install.sh` if the tool needs installing

If the tool ships in the standard apt repos:

```bash
install_my_cool_tool() {
    log_step "Installing my-cool-tool..."
    apt_install my-cool-tool
    log_success "my-cool-tool installed"
}
```

If it's a pipx package:

```bash
install_my_cool_tool() {
    log_step "Installing my-cool-tool..."
    pipx_install my-cool-tool
    log_success "my-cool-tool installed"
}
```

If it's a GitHub project that needs cloning + symlink:

```bash
install_my_cool_tool() {
    log_step "Installing my-cool-tool..."
    local dest="${GHOSTLINE_TOOLS_DIR}/my-cool-tool"
    clone_or_pull "https://github.com/owner/my-cool-tool.git" "$dest"
    install_pip_requirements "$dest"
    chmod +x "${dest}/main.py"
    ln -sf "${dest}/main.py" /usr/local/bin/my-cool-tool
    log_success "my-cool-tool installed"
}
```

Then add the function to the `main` block at the bottom of `install.sh`.

---

## Checklist before opening the PR

- [ ] The new module function follows the five-line shape above.
- [ ] Tool presence is checked with `ensure_command` or `resolve_command`.
- [ ] User input goes through `prompt_value` / `prompt_password`,
      not raw `read`.
- [ ] Logs go through `log_*`, not `echo -e ${RED}...${RESET}`.
- [ ] Every variable expansion is quoted (`"${var}"`, not `$var`).
- [ ] `bash -n` passes locally on the changed `.sh` files.
- [ ] The menu line and the case in `handle_<module>_menu` are updated
      in lockstep.
- [ ] If the tool needs installing, `install.sh` is updated.
- [ ] The `README.md` tool list is updated.

---

## Don't / Do

| Don't                                                  | Do                                                          |
|--------------------------------------------------------|-------------------------------------------------------------|
| `echo -e "${RED}Running...${RESET}"`                   | `log_step "Running..."`                                     |
| `read -p "Target: " TARGET`                            | `target=$(prompt_value "Target")`                           |
| `command -v foo \|\| { echo missing; return; }`        | `ensure_command "foo" "apt install foo" \|\| return 0`      |
| `IFS=$'\n' read -r -d '' -a arr <<<"$STR"`             | `mapfile -t arr <<<"$STR"`                                  |
| `cd /opt/foo && do_stuff && cd -`                      | `(cd /opt/foo \|\| exit 1; do_stuff)`                       |
| `arr=( $(find . -name '*.txt') )`                      | `mapfile -t arr < <(find . -name '*.txt')`                  |
| `$CMD --flag $TARGET`                                  | `"$CMD" --flag "${GHOSTLINE_TARGET}"`                       |
| French comments / log messages / docs                  | English everywhere                                          |
