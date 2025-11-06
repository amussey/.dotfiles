

# Default ZSH setup stuff.
unset SSH_AUTH_SOCK
# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi


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
function _completemarks {
  reply=($(ls $MARKPATH))
}
compctl -K _completemarks jump
compctl -K _completemarks unmark


# Onport command
# This command will tell you the applications running on a specific port.
function onport() {
    sudo lsof -i :$1
}


# Set the title on the current window.
function title {
    echo -ne "\e]1;$1\a"
}

alias vs=vs3

# Shorthand for creating and activating a Python 2 virtualenv.
function vs2 {
    if [ ! -f "$1/bin/activate" ]; then
        virtualenv -p "/usr/local/bin/python2" $1
    fi
    source $1/bin/activate
}

# Shorthand for creating and activating a Python 3 virtualenv.
function vs3 {
    if [ ! -f "$1/bin/activate" ]; then
        virtualenv -p "/usr/local/bin/python3" $1
    fi
    source $1/bin/activate
}


# Initiate a new Python project in the current folder.
function pystart {
    vs env
    pip install ipdb ipython
    deactivate
    vs env
    echo "env/\n.env\n*.pyc" > .gitignore
    git init
    echo "# ${PWD##*/}" > README.md
    echo "[flake8]\nignore = E501\n\n[pep8]\nignore = E501" > setup.cfg
    alias ipython=ipython2
    cp ~/.zshrc-files/pystart/Makefile Makefile
}


# htop on OSX requires root privileges to run.
alias htop="sudo htop"


# Commands for starting and stopping PostgreSql manually.
function postgres-start {
    command -v pg_ctl >/dev/null 2>&1 || { echo >&2 "This command requires Postgres to be installed.  Please use \`brew install postgres\`."; exit 1; }
    pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
}

function postgres-stop {
    command -v pg_ctl >/dev/null 2>&1 || { echo >&2 "This command requires Postgres to be installed.  Please use \`brew install postgres\`."; exit 1; }
    pg_ctl -D /usr/local/var/postgres stop -s -m fast
}

# Convert a movie file to a GIF with FFMPEG.
# Parameters:
#     movie-to-gif [movie file] [movie start time] [gif duration]
function movie-to-gif {
    filename=$(basename "$1")
    start_time="$2"
    duration="$3"
    pallet="${filename%.*}.png"
    output_gif="${filename%.*}.gif"
    ffmpeg -y -ss "$start_time" -t "$duration" -i "$1" -vf fps=15,scale=480:-1:flags=lanczos,palettegen "$pallet"
    ffmpeg -ss "$start_time" -t "$duration" -i "$1" -i "$pallet" -filter_complex "fps=15,scale=480:-1:flags=lanczos[x];[x][1:v]paletteuse" "$output_gif"
}


export PATH="/usr/local/opt/tcl-tk/bin:$PATH"

stty sane


if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
    # echo "Windows 10 Bash"
    alias subl="/mnt/c/Program\ Files/Sublime\ Text\ 3/subl.exe"
    alias pbcopy="clip.exe"
    export PATH=$HOME/bin:$PATH
fi


# Pyenv init and shortcut functions.
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"

function vls {
    VENV_VERS=3.12.11
    VENV_NAME=$(basename $(pwd))
    pyenv virtualenv ${1:-${VENV_VERS}} ${VENV_NAME}
    pyenv local ${VENV_NAME}
}
