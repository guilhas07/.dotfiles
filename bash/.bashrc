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

alias vim="nvim"
alias lg="lazygit"
alias dot="cd ~/.dotfiles/"
