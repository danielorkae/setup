# ==============================================================================
# OH MY ZSH CONFIGURATION
# ==============================================================================

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# ==============================================================================
# CURSOR/VS CODE SHELL INTEGRATION
# ==============================================================================

if [[ -n "${VSCODE_INJECTION}" ]] || [[ $TERM_PROGRAM == "vscode" ]]; then
  __vsc_precmd() {
    local __vsc_status=$?
    local prompt_start=$'%{\e]133;A\a%}'
    local prompt_end=$'%{\e]133;B\a%}'
    printf "\033]133;D;%s\007" "$__vsc_status"
    PS1="${prompt_start}${PS1}${prompt_end}"
  }

  __vsc_preexec() {
    printf "\033]133;C\007"
  }

  precmd_functions+=(__vsc_precmd)
  preexec_functions=(__vsc_preexec $preexec_functions)
fi

# ==============================================================================
# SPACESHIP THEME CONFIGURATION
# ==============================================================================

SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  exec_time     # Execution time
  line_sep      # Line break
  vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_USER_SHOW=always
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=" "

# ==============================================================================
# ZINIT PLUGIN MANAGER
# ==============================================================================

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# fast-syntax-highlighting deve ser carregado POR ÚTIMO: ele envolve widgets
# do ZLE e sobrescreve os de outros plugins se carregado antes deles.
zinit load zdharma-continuum/history-search-multi-word
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting

# ==============================================================================
# NVM - LAZY LOADING (evita ~300ms de overhead no startup)
# ==============================================================================

export NVM_DIR="$HOME/.nvm"

# Carrega NVM apenas quando node/npm/nvm/pnpm são chamados pela primeira vez
_load_nvm() {
  unset -f nvm node npm npx pnpm yarn
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm()  { _load_nvm; nvm  "$@"; }
node() { _load_nvm; node "$@"; }
npm()  { _load_nvm; npm  "$@"; }
npx()  { _load_nvm; npx  "$@"; }
pnpm() { _load_nvm; pnpm "$@"; }

# ==============================================================================
# DEVELOPMENT ENVIRONMENT LOADERS
# ==============================================================================

# uv (Python package manager)
export PATH="$HOME/.local/bin:$PATH"
[ -s "$HOME/.local/bin/uv" ] && eval "$(uv generate-shell-completion zsh)"

# ==============================================================================
# LANGUAGE-SPECIFIC CONFIGURATION
# ==============================================================================

# Java: usa o default do sistema em vez de versão hard-coded
if [ -d /usr/lib/jvm/default-java ]; then
  export JAVA_HOME=/usr/lib/jvm/default-java
elif [ -d /usr/lib/jvm/java-21-openjdk-amd64 ]; then
  export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
fi

export ANDROID_HOME=$HOME/.android
export ANDROID_SDK_ROOT=$ANDROID_HOME

# ==============================================================================
# PATH CONFIGURATION
# ==============================================================================

export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# ==============================================================================
# WSL CONFIGURATION
# ==============================================================================

if grep -qi microsoft /proc/version 2>/dev/null; then
  export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2)
  export ADB_SERVER_SOCKET=tcp:$WSL_HOST:5037
fi

# ==============================================================================
# ENVIRONMENT VARIABLES
# ==============================================================================

export PAGER=cat

# ==============================================================================
# ALIASES
# ==============================================================================

alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'
