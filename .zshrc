# ----------------------------------------------------------------------
# Detect when the shell is running inside Cursor Agent
# ----------------------------------------------------------------------
IS_CURSOR_AGENT=0
if [[ -n "$CURSOR_TRACE_ID" || "$TERM_PROGRAM" == "cursor" ]]; then
  IS_CURSOR_AGENT=1
fi


# ----------------------------------------------------------------------
# ENVs used both inside and outside Cursor
# ----------------------------------------------------------------------
export ZSH="/home/$USER/.oh-my-zsh"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Java / Android / ADB / Other ENVs
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export ANDROID_HOME=$HOME/.android
export ANDROID_SDK_ROOT=$ANDROID_HOME
export LD_LIBRARY_PATH=/opt/openssl/lib

# Extra PATHs
export PATH="$(yarn global bin):$PATH"
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/tools:$ANDROID_HOME/cmdline-tools/tools/bin
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
export PATH=$PATH:/opt/gradle/gradle-7.4.2/bin
export PATH=$PATH:/home/danielorkae/.pulumi/bin
export PATH=$PATH:$HOME/.local/bin
export PATH="~/.console-ninja/.bin:$PATH"

# GitHub tokens
export GITHUB_TOKEN="$(gh auth token)"
export AUTH_TOKEN=$(gh auth token)

# WSL / ADB
export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2)
export ADB_SERVER_SOCKET=tcp:$WSL_HOST:5037

# Libclang
export LIBCLANG_PATH=/usr/lib/llvm-14/lib/

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ASDF
. /home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh
fpath+=("/home/linuxbrew/.linuxbrew/opt/asdf/share/zsh/site-functions")


# ----------------------------------------------------------------------
# Configuration for Cursor / non-Cursor sessions
# ----------------------------------------------------------------------
if (( IS_CURSOR_AGENT )); then
  # Cursor session (light prompt, no plugins/themes)
  PROMPT='%n@%m:%~$ '
  RPROMPT=''
  PROMPT_EOL_MARK=''
  unset precmd_functions preexec_functions
else
  # Normal session (full setup)
  ZSH_THEME="spaceship"
  plugins=(git vi-mode)

  source $ZSH/oh-my-zsh.sh

  # Spaceship config
  SPACESHIP_PROMPT_ORDER=(user dir host git node php hg exec_time line_sep jobs exit_code char)
  SPACESHIP_USER_SHOW=always
  SPACESHIP_PROMPT_ADD_NEWLINE=false
  SPACESHIP_CHAR_SYMBOL="❯"
  SPACESHIP_CHAR_SUFFIX=" "

  # Zinit + plugins
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  source "${ZINIT_HOME}/zinit.zsh"
  zinit load zdharma-continuum/history-search-multi-word
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light zdharma-continuum/fast-syntax-highlighting
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-completions
fi


# ----------------------------------------------------------------------
# iTerm2 integration (only outside Cursor)
# ----------------------------------------------------------------------
if [[ -z $CURSOR_TRACE_ID ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
  precmd()  { print -Pn "\e]133;D;%?\a" }
  preexec() { print -Pn "\e]133;C;\a"  }
fi


# ----------------------------------------------------------------------
# Global aliases
# ----------------------------------------------------------------------
alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'

# Initialize ZSH completion
autoload -Uz compinit
compinit
