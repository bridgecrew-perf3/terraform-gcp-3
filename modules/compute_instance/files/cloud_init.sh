#!/usr/bin/env bash

set -ex

function install_os_dependencies() {
  sudo apt-get update
  sudo apt-get install -y \
    make \
    htop \
    ffmpeg
}

function set_ssh_files() {
  # This ssh files are meant to be use for deploy keys and other services
  ssh-keyscan -t rsa -H github.com > /home/ubuntu/.ssh/known_hosts
  ssh-keygen -q -t rsa -b 4096 -N '' -f /home/ubuntu/.ssh/id_rsa <<<y >/dev/null 2>&1
  chown -R ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa /home/ubuntu/.ssh/id_rsa.pub /home/ubuntu/.ssh/known_hosts
}

function install_npm() {
  sudo -u ubuntu curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  mv /.nvm /home/ubuntu/.nvm

  export NVM_DIR="/home/ubuntu/.nvm"
  cat <<EOF >> /home/ubuntu/.bashrc

export NVM_DIR="$NVM_DIR"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF

  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install 14
  npm install -g yarn nodemon pm2
  chown -R ubuntu:ubuntu /home/ubuntu/.nvm
}

START_TIME=$(date +%s)

install_os_dependencies
set_ssh_files
install_npm

END_TIME=$(date +%s)
ELAPSED=$(($END_TIME - $START_TIME))

echo "Deployment complete. Time elapsed: [$ELAPSED] seconds"
