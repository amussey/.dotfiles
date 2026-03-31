# ---- Prompt: [user@host:cwd]{pyenv}{git} $ ----

# Use prompt-style escapes + %F colors (zsh-native)
autoload -Uz colors && colors
setopt PROMPT_SUBST

# --- Python env segment ---
# - venv: $VIRTUAL_ENV
# - conda: $CONDA_DEFAULT_ENV
_py_prompt() {
  local env=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    env="${VIRTUAL_ENV:t}"           # basename
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    env="$CONDA_DEFAULT_ENV"
  fi

  [[ -n "$env" ]] && echo "%F{magenta}(${env})%f"
}

# --- Git segment (branch) ---
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%F{cyan}(%b)%f'          # (branch)
zstyle ':vcs_info:git:*' actionformats '%F{cyan}(%b|%a)%f' # (branch|rebase)

precmd() { vcs_info }  # refresh before each prompt

# --- Colors placement ---
# user: green, host: blue, cwd: red, brackets/labels: yellow
PROMPT='%F{yellow}[%f%F{green}%n%f%F{yellow}@%f%F{blue}%m%f%F{yellow}:%f%F{red}%~%f%F{yellow}]%f$(_py_prompt)${vcs_info_msg_0_} $ '
