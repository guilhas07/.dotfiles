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

update-go () {
    echo "Updating go installed packages using gup tool"
    if ! command -v gup 2>&1 >/dev/null
    then
        echo "gup tool could not be found"
        return 1
    fi

    gup update
}

update-cargo () {
    echo "Updating cargo installed packages using cargo-update crate"
    if ! command -v cargo-install-update 2>&1 >/dev/null
    then
        echo "cargo-update crate could not be found"
        return 1
    fi

    cargo install-update -a
}

alias vim="nvim"
lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}
alias dot="cd ~/.dotfiles/"
