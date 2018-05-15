# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/ikuchan/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/iku/.sdkman"
[[ -s "/home/iku/.sdkman/bin/sdkman-init.sh" ]] && source "/home/iku/.sdkman/bin/sdkman-init.sh"
