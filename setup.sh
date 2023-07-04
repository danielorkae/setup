#!/bin/bash

echo "--> Initial Setup"

USER="danielorkae"

sudo apt-get update

sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  unzip

echo "--> Installing dev tools"

# Install NodeJS LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash

# Install Yarn
sudo npm --global install yarn

# Install PHP
sudo apt install -y php \
php-curl \
php-zip \
php-intl \
php-mbstring \
php-xml \
php-imagick

# Install Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/bin --filename=composer
php -r "unlink('composer-setup.php');"

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

# Install AWS Cli
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip -o awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Install Android SDK
cd
mkdir .android
cd .android
wget https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip
unzip -o commandlinetools-linux-6609375_latest.zip -d cmdline-tools
rm -rf commandlinetools-linux-6609375_latest.zip
sudo apt install -y lib32z1 openjdk-11-jdk
cd && cd .android/cmdline-tools/tools/bin
./sdkmanager --install "platform-tools" "platforms;android-31" "build-tools;34.0.0" "cmake;3.6.4111459"
./sdkmanager --update

echo "--> Installing and configuring zsh"

ZSH_CUSTOM="$HOME/.oh-my-zsh"

# Install zsh
sudo apt install -y zsh

# Install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install spaceship theme
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# Install zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
mkdir -p "$(dirname $ZINIT_HOME)"
git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Copy .zshrc from github
curl https://raw.githubusercontent.com/danielorkae/setup/main/.zshrc > $HOME/.zshrc

# Initialize zsh
sudo chsh -s $(which zsh) $USER
zsh
echo "DONE!!!"
