#!/bin/bash

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

  echo "Checking if $package_name is already installed..."
  if eval "$check_command"; then
    echo "$package_name is already installed."
  else
    echo "Installing $package_name..."
    eval "$install_command" >> $LOG_FILE
    echo "$package_name installed."
  fi

  echo "$1 installed" >> $LOG_FILE
}

# Cria o arquivo de log
echo "--> Initial Setup" > $LOG_FILE

echo "Updating package lists..."
sudo apt-get update >> $LOG_FILE

echo "Installing initial dependencies..."
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  python3.10-venv \
  unzip >> $LOG_FILE

echo "--> Installing dev tools"

# Install G++
install_package "Gcc" \
  "is_installed gcc" \
  "sudo apt-get install -y gcc"

# Install Node.js LTS
install_package "Node.js" \
  "is_installed node" \
  "curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs"

# Install NVM
install_package "NVM" \
  "is_directory $HOME/.nvm" \
  "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash"

# Install Yarn
install_package "Yarn" \
  "is_installed yarn" \
  "sudo npm --global install yarn"

# Install PHP
install_package "PHP" \
  "is_installed php" \
  "sudo apt install -y php php-curl php-zip php-intl php-mbstring php-xml php-imagick"

# Install Composer
install_package "Composer" \
  "is_installed composer" \
  "php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\"" \
  "sudo php composer-setup.php --install-dir=/usr/bin --filename=composer && php -r \"unlink('composer-setup.php');\""

# Install Docker
install_package "Docker" \
  "is_installed docker" \
  "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  sudo apt update && \
  sudo apt-get -y install docker-ce docker-ce-cli containerd.io"

# Install AWS CLI
install_package "AWS CLI" \
  "is_installed aws" \
  "curl 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip' -o 'awscli-bundle.zip' && \
  unzip -o awscli-bundle.zip && \
  sudo python3 ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws"

# Install GH CLI
install_package "GitHub CLI" \
  "is_installed gh" \
  "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y"

# Install Android SDK
install_package "Android SDK" \
  "is_directory $HOME/.android" \
  "mkdir -p $HOME/.android && \
  cd $HOME/.android && \
  wget https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip && \
  unzip -o commandlinetools-linux-6609375_latest.zip -d cmdline-tools && \
  rm -rf commandlinetools-linux-6609375_latest.zip && \
  sudo apt install -y lib32z1 openjdk-11-jdk && \
  cd $HOME && cd $HOME/.android/cmdline-tools/tools/bin && \
  yes | ./sdkmanager --licenses && \
  ./sdkmanager --install 'platform-tools' 'platforms;android-31' 'build-tools;34.0.0' 'cmake;3.6.4111459' && \
  ./sdkmanager --update"

echo "--> Installing and configuring zsh"

ZSH_CUSTOM="$HOME/.oh-my-zsh"

# Install zsh
install_package "Zsh" \
  "is_installed zsh" \
  "sudo apt install -y zsh"

# Install oh my zsh
install_package "Oh My Zsh" \
  "is_directory $ZSH_CUSTOM" \
  "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)\""

# Install spaceship theme
install_package "Spaceship Theme" \
  "is_directory $ZSH_CUSTOM/themes/spaceship-prompt" \
  "git clone https://github.com/denysdovhan/spaceship-prompt.git \"$ZSH_CUSTOM/themes/spaceship-prompt\" && \
  ln -s \"$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme\" \"$ZSH_CUSTOM/themes/spaceship.zsh-theme\""

# Install Dracula theme
install_package "Dracula Theme" \
  "is_directory $ZSH_CUSTOM/themes/dracula" \
  "git clone https://github.com/dracula/zsh.git \"$ZSH_CUSTOM/themes/dracula\" && \
  ln -s \"$ZSH_CUSTOM/themes/dracula/dracula.zsh-theme\" \"$ZSH_CUSTOM/themes/dracula.zsh-theme\""

# Install zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
NO_INPUT=y
install_package "Zinit" \
  "is_directory $ZINIT_HOME" \
  "bash -c $(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh) -y"

# Copy .zshrc from GitHub
echo "Copying .zshrc from GitHub..."
curl https://raw.githubusercontent.com/danielorkae/setup/main/.zshrc > $HOME/.zshrc
echo ".zshrc copied."

# Initialize zsh
echo "Configuring zsh as default shell..."
sudo chsh -s "$(which zsh)" $USER
echo "zsh configured as default shell."

echo "DONE!!!"
