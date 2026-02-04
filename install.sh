#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

# Create Chezmoi configuration file with variables for .gitconfig template
chezmoi_config_dir="${HOME}/.config/chezmoi"
chezmoi_config_file="${chezmoi_config_dir}/chezmoi.toml"
if [ ! -f "${chezmoi_config_file}" ]; then
	mkdir -p "${chezmoi_config_dir}"
	cat <<- EOF > "${chezmoi_config_file}"
		[data]
		git_name = "Dylan Sprague"
		git_email = "dylan.richard.sprague@gmail.com"
		git_helper = "/.codespaces/bin/gitcredential_github.sh"
	EOF
fi

if ! chezmoi="$(command -v chezmoi)"; then
	bin_dir="${HOME}/.local/bin"
	chezmoi="${bin_dir}/chezmoi"
	echo "Installing chezmoi to '${chezmoi}'" >&2
	if command -v curl >/dev/null; then
		chezmoi_install_script="$(curl -fsSL get.chezmoi.io)"
	elif command -v wget >/dev/null; then
		chezmoi_install_script="$(wget -qO- get.chezmoi.io)"
	else
		echo "To install chezmoi, you must have curl or wget installed." >&2
		exit 1
	fi
	sh -c "${chezmoi_install_script}" -- -b "${bin_dir}"
	unset chezmoi_install_script bin_dir
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

set -- init --apply --source="${script_dir}"

echo "Running 'chezmoi $*'" >&2
# exec: replace current process with chezmoi
exec "$chezmoi" "$@"
