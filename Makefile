# Initialize this chezmoi source state from GitHub on a new machine.
init:
	chezmoi init https://github.com/dimitry12/configs.git

# Switch the remote to SSH after bootstrap credentials are available.
fix_origin:
	git remote set-url origin git@github.com:dimitry12/configs.git

# Refresh chezmoi after source-state configuration changes.
after_config_change:
	chezmoi init

# Render chezmoi data and catch YAML/template data errors.
check_data:
	chezmoi data

# Validate a specific chezmoi template string/path, e.g.:
# make check_template TEMPLATE=run_onchange_packages.sh.tmpl
check_template:
	chezmoi execute-template $${TEMPLATE:-path_or_string}

# Validate the niri config when niri is installed on the current host.
check_niri:
	@if command -v niri >/dev/null 2>&1; then \
		niri validate -c dot_config/niri/config.kdl; \
	else \
		echo "niri not installed; skipping niri config validation"; \
	fi
