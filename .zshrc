# ==============================================================================
# OH MY ZSH CONFIGURATION
# ==============================================================================

export ZSH="/home/$USER/.oh-my-zsh"

ZSH_THEME="spaceship"

# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# DISABLE_AUTO_UPDATE="true"
# DISABLE_UPDATE_PROMPT="true"
# export UPDATE_ZSH_DAYS=13
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# HIST_STAMPS="mm/dd/yyyy"
# ZSH_CUSTOM=/path/to/new-custom-folder

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

zinit load zdharma-continuum/history-search-multi-word
zinit light zsh-users/zsh-syntax-highlighting
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# ==============================================================================
# DEVELOPMENT ENVIRONMENT LOADERS
# ==============================================================================

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ==============================================================================
# LANGUAGE-SPECIFIC CONFIGURATION
# ==============================================================================

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

export ANDROID_HOME=$HOME/.android
export ANDROID_SDK_ROOT=$ANDROID_HOME

# ==============================================================================
# PATH CONFIGURATION
# ==============================================================================

export PATH="$(yarn global bin):$PATH"
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/tools/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:/opt/gradle/gradle-7.4.2/bin

# ==============================================================================
# WSL CONFIGURATION
# ==============================================================================

export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2)
export ADB_SERVER_SOCKET=tcp:$WSL_HOST:5037

# ==============================================================================
# ENVIRONMENT VARIABLES
# ==============================================================================

export PAGER=cat

# ==============================================================================
# TOKENS & CREDENTIALS
# ==============================================================================

export GITHUB_TOKEN="$(gh auth token)"
export AUTH_TOKEN=$(gh auth token)

# ==============================================================================
# ALIASES
# ==============================================================================

alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'

# ==============================================================================
# USER CONFIGURATION (OPTIONAL)
# ==============================================================================

# export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"
# export LANG=en_US.UTF-8
# export ARCHFLAGS="-arch x86_64"

# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
