init:
	chezmoi init https://github.com/dimitry12/configs.git

fix_origin:
	git remote set-url origin git@github.com:dimitry12/configs.git

after_config_change:
	chezmoi init

check_data:
	chezmoi data

check_template:
	chezmoi execute-template path_or_string
