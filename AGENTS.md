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

## Configuration management style

Prefer managing durable configuration as files when the backing store is a
stable, documented file format. Good examples include Flatpak override files,
`.desktop` autostart entries, launcher scripts under `~/.local/bin`, niri KDL,
and Waybar JSON/CSS. Use commands or onchange scripts only for settings whose
authoritative API is not a plain file, such as GNOME dconf/GSettings, package
installation, or per-machine portal consent.

Avoid replacing whole generated settings files when they mix portable user
preferences with machine/session-specific state. For example, Flatpak app
GSettings keyfiles can contain XDG Desktop Portal restore tokens; set individual
portable keys with `gsettings` instead of source-controlling the entire keyfile.

## Desktop speech-to-text decision notes

Linux dictation was evaluated primarily on Fedora Silverblue GNOME Wayland,
where direct text injection into another app is intentionally restricted by
Wayland. The preferred architecture is XDG Desktop Portals: GNOME owns consent
and the global shortcut, and the app uses the Remote Desktop portal to type into
the focused app.

Handy was removed from this repository for now. Although it is popular and works
well in some environments, the current GNOME Wayland path required fragile
compositor/input workarounds (`wtype` is unsupported by Mutter, while
`ydotool`/`dotool` require privileged input plumbing). Reconsider Handy only if
upstream Flatpak/portal support matures enough to avoid those workarounds.

Speed of Sound is the current Linux speech-to-text choice because it works with
GNOME Wayland through XDG Desktop Portals and can be installed from Flathub. Its
network access is denied with a managed Flatpak override for offline/privacy
use. The Remote Desktop portal consent and restore token are intentionally not
managed by this repo; the user must accept the GNOME permission dialog on each
new machine/session identity when required.

## Bootstrap assumptions

For a new desktop Linux machine, the intended bootstrap is:

1. Install Homebrew.
2. Install chezmoi.
3. Clone/init this repository as the chezmoi source state.
4. Ensure the Flathub Flatpak remote is enabled (manual one-time step):
   - `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`
   - `flatpak remote-modify --enable flathub` (requires sudo on most hosts)
   - Fedora ships `flathub` as a **disabled** system remote, so it must be
     enabled before `chezmoi apply` can install Flatpak apps like WezTerm.
     The onchange package script will also try to enable it, but the remote
     itself must first exist and be user-enabled.
5. Prepare GPG/YubiKey before first full apply:
   - import the public key from `dot_0x5AB6D0DF0F9A3055.asc`
   - run `gpg --card-status` with the YubiKey inserted so GPG can discover the
     smartcard-backed secret key stubs
6. Run `chezmoi apply`.

The GPG private key is expected to live on a YubiKey, not in this repository and
not as an importable private-key file. On Fedora Silverblue or other atomic
systems, host-level smartcard/pcscd setup may be required before GPG decryption
works.

## Pi agent resource management

Pi global configuration under `~/.pi/agent` is managed selectively:

- `~/.pi/agent/AGENTS.md` should be tracked only as a symlink to
  `../../okf/AGENTS.md` (resolving to `~/okf/AGENTS.md`). The instruction file
  contents live under `~/okf/` and are not tracked by chezmoi.
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

## SRT sandbox configuration

Global SRT sandbox settings are managed by `dot_srt-settings.json.tmpl`, which
renders to `~/.srt-settings.json`. The intended filesystem policy is:

- allow writes to the project current working directory (`.`) only;
- deny writes to `./.git` to protect repository history;
- deny writes to the entire project-local `./.pi` path;
- do not add child allow/deny exceptions under `./.pi`, including
  `./.pi/mcp-results/`.

On Linux, SRT uses bubblewrap (`bwrap`). If `./.pi` is denied while a child such
as `./.pi/mcp-results/` is allowed, and `./.pi` does not already exist as a
directory, bwrap/SRT can materialize or mask `./.pi` as a regular mount-point
file to enforce the rules. That can break even read operations with errors like
`bwrap: Can't mkdir <cwd>/.pi: Not a directory`. macOS sandboxing does not use
these bwrap mount mechanics, so the same nested exception policy may appear to
work there but fail on Linux.

## Portability conventions

- Prefer OS-aware templates over hardcoded host paths.
- Guard optional shell tools with `command -v` or file-existence checks.
- Avoid hardcoded `/Users/dzmitry`, `/home/dzmitry`, `/opt/local`, or similar
  host-specific paths in cross-platform files. If a host-specific path is needed,
  keep it inside an OS-specific template branch.

## Privilege elevation and trusted command paths

For privileged commands in agent sessions, prefer `/usr/bin/pkexec` over
`sudo`. `sudo` prompts in the terminal, which the agent cannot answer and which
is easier to spoof with a user-space executable named `sudo`. `pkexec` delegates
authentication to the desktop polkit agent so the password prompt is surfaced to
the user instead of the requesting process.

Always invoke privilege-elevation tools by absolute path, especially
`/usr/bin/pkexec` and `/usr/bin/sudo`, so user-writable `PATH` entries such as
`~/.local/bin`, Homebrew, npm, cargo, or Pi agent shims cannot shadow the real
system binaries.

Bash startup intentionally normalizes Linux `PATH` so immutable/system command
directories (`/usr/bin`, `/bin`, `/usr/sbin`, `/sbin`) are searched before
user-writable tool directories. Keep this ordering unless there is a documented,
security-reviewed reason to allow a user-space tool to override a system command.

## Session startup

At the start of every new session, identify the current system before doing
anything else, because this repository is applied across multiple machines
(macOS, Fedora Silverblue/atomic, Ubuntu, etc.) with different package
managers, paths, and capabilities:

- Detect the OS and distribution with `uname -s` and, on Linux, check
  `/etc/os-release` (for example, look for `VARIANT_ID=silverblue` or similar
  atomic identifiers).
- Note the hostname with `hostname` so host-specific behavior can be applied.
- Confirm key tool availability relevant to the task (`chezmoi`, `brew`,
  `flatpak`, `uv`, `gpg`, etc.) with `command -v` rather than assuming.

Use the detected environment to pick the correct platform branches in templates
and scripts, and to avoid suggesting commands or paths that do not exist on the
current host.

## Periodic maintenance

Periodically (and at least when major CVEs or breaking changes surface) the
user should be prompted to run a maintenance review of everything this repo
installs. Agents working in this repository should remind the user of the
following two reviews when relevant (for example during a `chezmoi apply`, a
package-list change, or a security audit):

1. **Vulnerability review of all installed packages, including Pi add-on
   dependencies.** Audit every layer this repository manages for known
   vulnerabilities:
   - Homebrew: `brew audit` / `brew outdated` and review the formulae list.
   - Flatpak: `flatpak update` and review installed refs.
   - npm global tools and Pi extension/skill `node_modules` (under
     `~/.pi/agent/{extensions,skills}` and the external contrib repo): run
     `npm audit` in each directory with a `package-lock.json`.
   - `uv tool` installs: `uv tool list` and check each tool's dependencies
     (for example `uv tool run --from <tool> pip-audit`, or reinstall to pull
     patched transitive deps).
   - MacPorts (macOS): `port outdated` and review the macports list.
   Review any CVEs reported and either bump, pin, or remove the affected
   package. Pinned versions in this repo (see "Handling dependencies" in the
   global AGENTS) should be re-justified at this time.

2. **Manager-fit review: brew vs. `uv tool` vs. npm global.** Go through the
   lists in `.chezmoidata/packages.yaml` (`linux.homebrew`, `darwin.homebrew`,
   `darwin.macports`, `npm_global`, `uv_tool`, `termux`) and reconsider, for
   each tool, whether it is managed by the most appropriate manager:
   - Tools available as a Homebrew formula and used as a general CLI should
     generally be a brew formula (so they get `brew audit`/`brew bump` and
     bottle updates) rather than a `cargo install`/`go install`/`uv tool`/
     npm global install.
   - Python-only CLI tools that are not in Homebrew (or where the brew formula
     lags badly) belong in `uv_tool`.
   - JavaScript/Node-only tools belong in `npm_global` only when no brew
     formula exists or the formula is unsuitable.
   - Move tools in the direction that reduces the number of managers and keeps
     update/audit coverage best-in-class. Update `.chezmoidata/packages.yaml`
     and the relevant onchange scripts accordingly.

Keep notes of decisions (and the "why") in CONSTRAINTS.md per the global
AGENTS rules.

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
