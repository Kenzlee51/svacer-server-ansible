#!/bin/bash

set -e

apt update

# Установка требуемых пакетов docker
apt install -y docker.io docker-compose-plugin

# Устанаваливаем или обноваяем python3
apt install -y python3

# Созадем и запускаем окружение
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
#source .venv/bin/activate - не запускаем окружение,
# чтобы нчиего не сломать, а работам с ним напрямую через  .venc/bin/

# Устанавливаем ansible
.venv/bin/pip install ansible

# Устанвока коллекции community.docker для ansible
.venv/bin/ansible-galaxy collection install community.docker

.venv/bin/ansible-playbook svacer_install.yml