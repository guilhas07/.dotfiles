#!/bin/bash -i

generate_github_ssh(){
	echo "Generating ssh key"
	read -p "Do you which to proceed? [y/n] " code
    # mkdir ~/.ssh
	if [[ "$code" != "y" ]];then
		echo "Aborting"
		exit 0
	fi
    ssh-keygen -t ed25519 -C "guilhermesoares1970@gmail.com"
    eval "$(ssh-agent -s)"
    read -p "Key to add to the ssh agent (Use full path e.g., /home/user/.ssh/key ): " key
    ssh-add $key
    cat "$key.pub"
}

install_neovim(){
	echo "Neovim installation steps:"
	echo "  1: Install rust"
	echo "  2: Install bob neovim version manager"
	echo "  3: Install neovim nightly and stable"
	read -p "Do you which to proceed? [y/n] " code

	if [[ "$code" != "y" ]];then
		echo "Aborting installation"
		return
	fi

	echo "Installing rust"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y

	echo "Installing bob neovim version manager"
	cargo install bob-nvim
	echo "Installing neovim nightly and stable"
	bob install nightly
	bob install stable
	echo "Using neovim nightly"
    bob use nightly
    sudo ln -s ~/.local/share/bob/nvim-bin/nvim /usr/bin/nvim
}

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
	echo "Stowing $dir"
	stow $dir
done

# update fonts
fc-cache -fv ~/.local/share/fonts/

# source new .bashrc
source ~/.bashrc

install_neovim
generate_github_ssh
