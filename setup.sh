#/bin/bash

set -e -u -o pipefail

cwd="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
dotfiles_dir="${cwd}/src"
dotfiles_old_dir="${cwd}/src.bak"

__backup() {
	local target_dir="$1"

	cd ${dotfiles_dir}

	# For each dotfile in our folder, retrieve the currently running version from the system instead.
	for dotfile in $(find . -type f); do
		if [ -f ${HOME}/${dotfile} ]; then
			mkdir -p $(dirname "${target_dir}/$dotfile")
			cp -v "${HOME}/${dotfile}" "${target_dir}/${dotfile}"
		fi
	done
}

backup() {
	echo "====== Backing up any existing dotfiles."
	__backup "${dotfiles_old_dir}"
}

import() {
	echo "====== Importing any existing dotfiles into the git tree."
	__backup "${dotfiles_dir}"
}

install() {
	echo "====== Checking for junk left by previous runs of this tool."
	if [[ -d ${dotfiles_old_dir} ]]; then
		prompt=$(cat <<-EOF
		Folder ${dotfiles_old_dir} exists. Your current dotfiles cannot be backed up without overwriting it.
		By typing yes, you will delete the backup directory. By typing no, you will merge the backup directory with your current dotfiles.
		Which one do you choose? [Y/n] 
		EOF
		)
		read -p "${prompt}" response
		[[ -z "${response:+x}" ]] && response='Y'

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
	for dotfile in $(find . -type f); do
		ln -sf "$(realpath ${dotfile})" "${HOME}/${dotfile}"
	done

	# Display warning
	read -p "======  Your old dotfiles are located inside ${dotfiles_old_dir}. Would you like to keep them? [y/N] " response
	[[ -z "${response:+x}" ]] && response='N'

	case $response in
	[nN][oO]|[nN])
		echo "====== Deleting backup..."
		rm -r ${dotfiles_old_dir}
		;;
	esac

	if ! grep "bashrc.after" "${HOME}/.bashrc" >/dev/null; then
		echo "appending .bashrc.after to .bashrc"
		cat >> "${HOME}/.bashrc" <<-"EOF"
			if [ -f ~/.bashrc.after ]; then
				. ~/.bashrc.after
			fi
		EOF
	fi

	echo "====== Setup done."
}

usage() {
	echo "Usage:"
	echo "./setup.sh install"
	echo "./setup.sh backup"
	echo "./setup.sh import"
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
import)
	import
	;;
*)
	usage
	;;
esac
