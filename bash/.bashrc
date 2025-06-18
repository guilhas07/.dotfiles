#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

. "$HOME/.cargo/env"

eval "$(starship init bash)"

export EDITOR="nvim"
export PATH="$PATH:/usr/local/go/bin:~/go/bin/:~/.local/share/nvim/mason/bin/"

update-go () {
    if ! command -v gup 2>&1 >/dev/null
    then
        echo "gup tool could not be found"
	echo "install gup with: go install github.com/nao1215/gup@latest"
        return 1
    fi
    echo "Updating go installed packages using gup tool"
    gup update
}

update-cargo () {
    if ! command -v cargo-install-update 2>&1 >/dev/null
    then
        echo "cargo-update crate could not be found"
        echo "install cargo-update with: cargo install cargo-update"
        return 1
    fi

    echo "Updating cargo installed packages using cargo-update crate"
    cargo install-update -a
}

alias vim="nvim"
alias dot="cd ~/.dotfiles/"
alias mkdir="mkdir -p"
lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
HISTTIMEFORMAT="%d/%m/%y %T "
