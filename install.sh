#!/bin/bash -i

os_version=$(hostnamectl | sed -n 's/Operating System: \(.*$\)/\1/p') # -n in conjuction with p flag, only prints matched line
package_manager=""
programs="stow kitty starship lazygit npm unzip p7zip git-delta noto-fonts-emoji tmux"

case $os_version in
	"Arch Linux")
		echo "Your operating system: $os_version"
		package_manager="pacman";;
	*)
		echo "Operating System: $os_version not supported."
		exit 1;;
esac

echo 

echo "Installing all required programs"

# install yay if it doesn't exist
if ! command -v yay &> /dev/null;then
    git clone "https://aur.archlinux.org/yay.git"
    cd yay
    makepkg -si
    cd -
    rm -rf yay
fi

sudo $package_manager -Syu $programs --needed

# clear bash default settings to prevent stow conflict
read -p "Do you which to remove your local bash scripts? [y/n] " code
if [[ "$code" == "y" ]];then
    rm ~/.bash*
fi

# restore config directories
dirs=$(find . -maxdepth 1 -type d ! -path ".git" ! -path "." | tr -d "./")
for dir in $dirs; do
	[[ "$dir" == "private" ]] && continue
	echo "Stowing $dir"
	stow $dir
done

if [[ -d private ]]; then
	for dir in private/*/; do
		dir=$(basename "$dir")
		echo "Stowing private/$dir"
		stow -d private -t ~ "$dir"
	done
fi

# update fonts
fc-cache -fv ~/.local/share/fonts/

# source new .bashrc
source ~/.bashrc
