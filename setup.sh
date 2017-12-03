#/bin/bash

set -e -u -o pipefail

cwd="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
dotfiles_dir="${cwd}/src"
dotfiles_old_dir="${cwd}/src.old"

backup() {
	echo "====== Backing up any existing dotfiles."
	cd ${dotfiles_dir}

	# For each dotfile in our folder, retrieve the currently running version from the system instead.
	for dotfile in $(find . -type f); do
		if [ -e ${HOME}/${dotfile} ]; then
			mkdir -p $(dirname ${dotfiles_old_dir}/$dotfile)
			cp -v "${HOME}/${dotfile}" "${dotfiles_dir}/${dotfile}"
		fi
	done
	rsync -avr "${HOME}/bin/" "${dotfiles_dir}/bin"
}

install() {
	echo "====== Checking for junk left by previous runs of this tool."
	if [[ -d ${dotfiles_old_dir} ]]; then
		read -p \
		"Folder ${dotfiles_old_dir} exists. Your current dotfiles cannot be backed up without overwriting it. " \
		"By typing yes, you will delete the backup directory. By typing no, you will merge the backup directory with your current dotfiles." \
		"Which one do you choose? [Y/n] " response
		if [[ -z "${response+x}" ]]; then
			response='Y'
		fi
		case $response in
		[yY][eE][sS]|[yY])
			echo "deleting"
			rm -r ${dotfiles_old_dir}
			;;
		esac
	fi
	mkdir -p ${dotfiles_old_dir}

	backup

	echo "====== The way is cleared, copy all new files"
	rsync -avr "${dotfiles_dir}/" "${HOME}"

	# Display warning
	read -p "======  Your old dotfiles are located inside ${dotfiles_old_dir}. Would you like to keep them? [y/N] " response
	if [[ -z "${response+x}" ]]; then
		response='N'
	fi
	case $response in
	[nN][oO]|[nN])
		echo "deleting"
		rm -r ${dotfiles_old_dir}
		;;
	esac

	if ! grep "bashrc.after" "${HOME}/.bashrc"; then
		cat >> "${HOME}/.bashrc" <<-EOF
			if [ -f ~/.bashrc.after ]; then
				. ~/.bashrc.after
			fi
		EOF
	fi
}

usage() {
	echo "Usage:"
	echo "./setup.sh install"
	echo "./setup.sh backup"
	echo "./setup.sh help"
	exit 1
}

[[ $# -eq 1 ]] || usage
case $1 in
install)
	install
	;;
backup)
	backup
	;;
*)
	usage
	;;
esac
