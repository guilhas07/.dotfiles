# Use powerline
USE_POWERLINE="true"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

unsetopt nomatch

alias es="cd ~/Documents/ES/es22-32/"


# SD alias
alias sd="cd ~/Documents/SD/A59-Turmas/"
alias nameserver="cd NamingServer; mvn exec:java -Dexec.args=\"localhost 5000 -debug\""
alias turmas1="cd ClassServer; mvn exec:java -Dexec.args=\"localhost 2001 P\"" 
alias turmas2="cd ClassServer; mvn exec:java -Dexec.args=\"localhost 2002 S\"" 
alias turmasfail="cd ClassServer; mvn exec:java -Dexec.args=\"localhost 2003 X\"" 
alias aluno="cd Student; mvn exec:java -Dexec.args=\"aluno0012 Joaquim Freire\""
alias docente="cd Professor; mvn exec:java"
alias admin_turmas="cd Admin; mvn exec:java"


export PATH="$PATH:/opt/idea-IU-213.6777.52/bin"


