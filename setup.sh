#!/bin/bash
set -eo pipefail

LOG_FILE="install_log.txt"

# Função para verificar se um comando está instalado
is_installed() {
  command -v "$1" &>/dev/null
}

# Função para verificar se um diretório existe
is_directory() {
  [ -d "$1" ]
}

# Função para instalar um pacote
install_package() {
  local package_name=$1
  local check_command=$2
  local install_command=$3

  echo "[$(date '+%H:%M:%S')] Checking $package_name..."
  if eval "$check_command"; then
    echo "$package_name already installed. Skipping."
  else
    echo "Installing $package_name..."
    eval "$install_command" >> "$LOG_FILE" 2>&1
    echo "$package_name installed."
  fi

  echo "$package_name checked" >> "$LOG_FILE"
}

# Cria o arquivo de log
echo "--> Initial Setup [$(date)]" > "$LOG_FILE"

echo "Updating package lists..."
sudo apt-get update >> "$LOG_FILE" 2>&1

echo "Installing initial dependencies..."
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  python3-venv \
  unzip \
  wget >> "$LOG_FILE" 2>&1

echo "--> Installing dev tools"

# Install GCC
install_package "GCC" \
  "is_installed gcc" \
  "sudo apt-get install -y gcc"

# Install NVM (Node Version Manager)
install_package "NVM" \
  "is_directory $HOME/.nvm" \
  "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | bash"

# Load NVM for use in this script session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js LTS via NVM
if ! is_installed node; then
  echo "Installing Node.js LTS via NVM..."
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*'
  echo "Node.js LTS installed."
fi

# Install pnpm via corepack
install_package "pnpm" \
  "is_installed pnpm" \
  "corepack enable pnpm"

# Install PHP
install_package "PHP" \
  "is_installed php" \
  "sudo apt install -y php php-curl php-zip php-intl php-mbstring php-xml php-imagick"

# Install Composer (multi-step, handled inline)
if ! is_installed composer; then
  echo "Installing Composer..."
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  sudo php composer-setup.php --install-dir=/usr/bin --filename=composer
  php -r "unlink('composer-setup.php');"
  echo "Composer installed."
fi

# Install Docker + Compose plugin
install_package "Docker" \
  "is_installed docker" \
  "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
  echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  sudo apt-get update && \
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
  sudo usermod -aG docker \$USER"

# Install AWS CLI v2
install_package "AWS CLI" \
  "is_installed aws" \
  "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o '/tmp/awscliv2.zip' && \
  unzip -o /tmp/awscliv2.zip -d /tmp/awscli && \
  sudo /tmp/awscli/aws/install && \
  rm -rf /tmp/awscliv2.zip /tmp/awscli"

# Install GH CLI
install_package "GitHub CLI" \
  "is_installed gh" \
  "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt-get update \
  && sudo apt-get install -y gh"

# Install Claude Code CLI
install_package "Claude Code" \
  "is_installed claude" \
  "npm install -g @anthropic-ai/claude-code"

# Install uv (Python package/project manager)
install_package "uv" \
  "is_installed uv" \
  "curl -LsSf https://astral.sh/uv/install.sh | sh"

# Install Android SDK
install_package "Android SDK" \
  "is_directory $HOME/.android/cmdline-tools" \
  "mkdir -p \"$HOME/.android/cmdline-tools\" && \
  curl -o /tmp/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
  unzip -o /tmp/cmdline-tools.zip -d \"$HOME/.android/cmdline-tools\" && \
  mv \"$HOME/.android/cmdline-tools/cmdline-tools\" \"$HOME/.android/cmdline-tools/latest\" && \
  rm -f /tmp/cmdline-tools.zip && \
  sudo apt install -y lib32z1 openjdk-21-jdk && \
  export PATH=\$PATH:\"$HOME/.android/cmdline-tools/latest/bin\" && \
  yes | sdkmanager --licenses && \
  sdkmanager --install 'platform-tools' 'platforms;android-35' 'build-tools;35.0.0' 'cmake;3.22.1'"

echo "--> Installing and configuring zsh"

ZSH_CUSTOM="$HOME/.oh-my-zsh"

# Install zsh
install_package "Zsh" \
  "is_installed zsh" \
  "sudo apt install -y zsh"

# Install Oh My Zsh (non-interactive)
install_package "Oh My Zsh" \
  "is_directory $ZSH_CUSTOM" \
  "RUNZSH=no CHSH=no sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""

# Install Spaceship theme
install_package "Spaceship Theme" \
  "is_directory ${ZSH_CUSTOM}/themes/spaceship-prompt" \
  "git clone https://github.com/spaceship-prompt/spaceship-prompt.git \"${ZSH_CUSTOM}/themes/spaceship-prompt\" --depth=1 && \
  ln -sf \"${ZSH_CUSTOM}/themes/spaceship-prompt/spaceship.zsh-theme\" \"${ZSH_CUSTOM}/themes/spaceship.zsh-theme\""

# Install Zinit via git clone (mais confiável que curl | bash)
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
install_package "Zinit" \
  "is_directory $ZINIT_HOME" \
  "mkdir -p \"$(dirname \"$ZINIT_HOME\")\" && git clone https://github.com/zdharma-continuum/zinit.git \"$ZINIT_HOME\""

# Copy .zshrc from GitHub
echo "Copying .zshrc from GitHub..."
curl -fsSL https://raw.githubusercontent.com/danielorkae/setup/main/.zshrc > "$HOME/.zshrc"
echo ".zshrc copied."

# Set zsh as default shell
echo "Configuring zsh as default shell..."
sudo chsh -s "$(which zsh)" "$USER"
echo "zsh configured as default shell."

echo ""
echo "DONE! Restart your terminal or run: exec zsh"
echo "Note: Docker group changes require logout/login to take effect."
