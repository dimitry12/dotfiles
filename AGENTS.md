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

Package installation is managed declaratively through the unified onchange
script and supporting templates. It covers:

- Platform-specific package managers, such as MacPorts on macOS.
- Cross-platform shell-based installations where appropriate.
- `uv` tool installations for Python command-line tools.
- `llm` plugin installation for extending Datasette `llm` functionality.

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
