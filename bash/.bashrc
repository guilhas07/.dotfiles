#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"
. "$HOME/.cargo/env"

export PATH="$PATH:~/.local/share/bob/nvim-bin"
export EDITOR="nvim"

alias vim="nvim"
alias lg="lazygit"
