# AGENTS.md

## Purpose

This repository manages personal dotfiles with chezmoi. Dotfiles are
configuration files for Unix-like systems that customize applications, shells,
and developer tooling.

Key goals:

- Centralize configuration management.
- Version-control settings and templates.
- Make new-system setup repeatable.
- Keep behavior consistent across machines while allowing platform-specific
  differences.

## Repository map

- `dot_*` and `private_*` paths are chezmoi source-state files that map to home
  directory dotfiles and private files.
- `.chezmoi*` files configure chezmoi behavior, templates, external sources, and
  ignore rules.
- `run_onchange_*.tmpl` scripts run when relevant managed inputs change.
- `dot_env/` materializes as `~/.env/`; one-off sensitive environment files
  should be added with `chezmoi add --encrypt`, not via plaintext source files.
- `encrypted_*.asc` files contain encrypted secrets; do not decrypt or rewrite
  them unless explicitly asked.
- `Makefile` contains developer/maintenance commands for this repository.
- This file is project documentation and should stay ignored by chezmoi so it is
  not applied into `$HOME`.

## Package management

Package installation is managed declaratively through onchange scripts and
supporting data/templates. It covers:

- macOS CLI/dev packages via MacPorts and selected Homebrew formulae.
- Linux CLI/dev packages via Homebrew, including Fedora Silverblue/atomic
  systems and Ubuntu. Avoid adding apt/dnf/rpm-ostree package sections unless
  there is a host-level package that Homebrew/Flatpak cannot reasonably cover.
- Linux GUI applications via Flatpak when Flatpak is available.
- `uv` tool installations for Python command-line tools.
- npm global tools such as Pi, installed with explicit safety flags where used.

Linux Homebrew package declarations use `{name, binary}` objects. The install
script checks `command -v <binary>` and skips `brew install <name>` when an
acceptable binary already exists from the base OS, toolbox, or another manager.

`llm` is intentionally not managed in this repository anymore.

## Bootstrap assumptions

For a new desktop Linux machine, the intended bootstrap is:

1. Install Homebrew.
2. Install chezmoi.
3. Clone/init this repository as the chezmoi source state.
4. Prepare GPG/YubiKey before first full apply:
   - import the public key from `dot_0x5AB6D0DF0F9A3055.asc`
   - run `gpg --card-status` with the YubiKey inserted so GPG can discover the
     smartcard-backed secret key stubs
5. Run `chezmoi apply`.

The GPG private key is expected to live on a YubiKey, not in this repository and
not as an importable private-key file. On Fedora Silverblue or other atomic
systems, host-level smartcard/pcscd setup may be required before GPG decryption
works.

## Pi agent resource management

Pi global configuration under `~/.pi/agent` is managed selectively:

- Personal active resources live in the external repository
  `~/.pi/contrib/dzmitry`, managed by `.chezmoiexternal.toml`.
- Active Pi resources under `~/.pi/agent/{extensions,skills,prompts}` are tracked
  as symlinks into that external repository.
- Prefer HTTPS URLs for public externals to simplify first-machine bootstrap;
  use SSH only when an external is private.
- Pi extension/skill npm dependencies are installed by
  `run_onchange_pi_agent_deps.sh.tmpl` using `npm ci --ignore-scripts` in active
  resource directories with `package-lock.json`.

Stable API keys should live in `.encrypted_keys.toml.asc` and be injected into
managed templates. Volatile OAuth/session credentials should not be tracked.
`~/.pi/agent/auth.json` is treated as a bootstrap template for stable API-key
providers, not as a full live-session backup.

## Portability conventions

- Prefer OS-aware templates over hardcoded host paths.
- Guard optional shell tools with `command -v` or file-existence checks.
- Avoid hardcoded `/Users/dzmitry`, `/home/dzmitry`, `/opt/local`, or similar
  host-specific paths in cross-platform files. If a host-specific path is needed,
  keep it inside an OS-specific template branch.

## Working guidelines for agents

- This repository is public: do not commit secrets, private tokens, host-specific
  sensitive details, or other private information in plaintext. Use encrypted
  chezmoi files/templates for sensitive values.
- Check `git status --short` before edits and preserve unrelated local changes.
- Prefer managing home-directory file changes through the `chezmoi` CLI (for
  example, `chezmoi add ~/.local/bin/zpi`) instead of hand-copying into the
  source tree. Direct edits are fine for repository-only documentation such as
  this file.
- Prefer small, targeted edits to chezmoi source files.
- When changing templates, validate with the relevant `make` target when
  possible, especially `make check_data` or `make check_template`.
- Do not introduce broad home-directory searches; inspect only this repository
  or explicit paths.
