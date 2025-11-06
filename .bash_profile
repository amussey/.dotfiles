
# Allows for marking and jumping to directories deep in the filesystem.
# Taken from Jeroen Janssens's article "Quickly navigate your filesystem from the command-line"
# URL:        http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
# Discussion: https://news.ycombinator.com/item?id=6229001
export MARKPATH=$HOME/.marks
function jump {
    cd -P $MARKPATH/$1 2> /dev/null || echo "No such mark: $1"
}
function mark {
    mkdir -p $MARKPATH; ln -s $(pwd) $MARKPATH/$1
}
function unmark {
    rm -i $MARKPATH/$1
}
function marks {
    \ls -l $MARKPATH | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}
function _jump {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local marks=$(find $MARKPATH -type l | awk -F '/' '{print $NF}')
    COMPREPLY=($(compgen -W '${marks[@]}' -- "$cur"))
    return 0
}
complete -o default -o nospace -F _jump jump


# Colored Command Shell
#
# This is a great lightweight alternative to the full Powerline Shell.
# This displays in the form:
#     [user@system-name:~]#
export PS1='\[\e[1;33m\][\[\e[0m\]\[\e[1;32m\]\u\[\e[0m\]\[\e[1;33m\]@\[\e[0m\]\[\e[1;34m\]$HOSTNAME\[\e[0m\]\[\e[1;33m\]:\[\e[0m\]\[\e[1;31m\]\w\[\e[0m\]\[\e[1;33m\]]\$\[\e[0m\] '


# Powerline Shell
# https://github.com/milkbikis/powerline-shell
#
# This will also require updating your shell with a patched font:
# https://github.com/Lokaltog/powerline-fonts
#
# To install Powerline Shell, run the command:
#     git clone https://github.com/milkbikis/powerline-shell.git .powerline-shell ; cd .powerline-shell ; python install.py
function _update_ps1() {
    export PS1="$(~/.powerline-shell/powerline-shell.py $?)"
}
export PROMPT_COMMAND="_update_ps1"


# git Autocomplete
# Originally created by Shawn O. Pearce <spearce@spearce.org>
# Allows for tab autocompletion of branch names while using git.
source bash/git-completion.bash


# Onport command
# This command will tell you the applications running on a specific port.
function onport() {
    sudo lsof -i :$1
}

# Pyenv init and shortcut functions.
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init -)"

function vls {
    VENV_VERS=3.12.11
    VENV_NAME=$(basename $(pwd))
    pyenv virtualenv ${1:-${VENV_VERS}} ${VENV_NAME}
    pyenv local ${VENV_NAME}
}
