# --- Detecta quando o shell está rodando dentro do Cursor Agent ---
IS_CURSOR_AGENT=0
if [[ -n "$CURSOR_TRACE_ID" || "$TERM_PROGRAM" == "cursor" ]]; then
  IS_CURSOR_AGENT=1
fi

# Caminhos/ENVs que você precisa SEMPRE (fora e dentro do Cursor)
export ZSH="/home/$USER/.oh-my-zsh"

# (se você usa NVM para builds, mantenha; caso pese, a gente pode lazy-load)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Java/Android/ADB/WSL/Outros ENVs
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export ANDROID_HOME=$HOME/.android
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH="$(yarn global bin):$PATH"
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/tools:$ANDROID_HOME/cmdline-tools/tools/bin
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
export PATH=$PATH:/opt/gradle/gradle-7.4.2/bin
export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2)
export ADB_SERVER_SOCKET=tcp:$WSL_HOST:5037
export PATH=$PATH:/home/danielorkae/.pulumi/bin
PATH=~/.console-ninja/.bin:$PATH
export GITHUB_TOKEN="$(gh auth token)"

# --- Comportamento diferente dentro/fora do Cursor ---
if (( IS_CURSOR_AGENT )); then
  # Sessão do Cursor: prompt leve e nada de temas/plugins/OSC iTerm2
  PROMPT='%n@%m:%~$ '
  RPROMPT=''
  PROMPT_EOL_MARK=''
  # Evita qualquer precmd/preexec “fancy”
  unset precmd_functions preexec_functions
else
  # Sessão normal (fora do Cursor): teu setup completo
  ZSH_THEME="spaceship"
  plugins=(git vi-mode)
  source $ZSH/oh-my-zsh.sh

  # Spaceship (somente fora do Cursor)
  SPACESHIP_PROMPT_ORDER=(
    user dir host git node php hg exec_time line_sep jobs exit_code char
  )
  SPACESHIP_USER_SHOW=always
  SPACESHIP_PROMPT_ADD_NEWLINE=false
  SPACESHIP_CHAR_SYMBOL="❯"
  SPACESHIP_CHAR_SUFFIX=" "

  # Zinit (somente fora do Cursor)
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  source "${ZINIT_HOME}/zinit.zsh"
  zinit load zdharma-continuum/history-search-multi-word
  zinit light zsh-users/zsh-syntax-highlighting
  zinit light zdharma-continuum/fast-syntax-highlighting
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-completions
fi

# --- Integração iTerm2: só FORA do Cursor ---
if [[ -z $CURSOR_TRACE_ID ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
  # Se você usa marks do iTerm2, pode manter os hooks aqui
  precmd() { print -Pn "\e]133;D;%?\a" }
  preexec() { print -Pn "\e]133;C;\a" }
fi

# Alias, etc. (valem para ambos)
alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'
