#!/bin/bash

set -e

echo "1/7 Обновляем репы"
apt update
echo "1/7 Репы успешно обнволены"

# Установка требуемых пакетов docker
echo "2/7 Устанавливаем docker.io docker-compose-plugin"
apt install -y docker.io docker-compose-plugin
echo "2/7 Успешно установили docker.io docker-compose-plugin"

# Устанаваливаем или обноваяем python3
echo "3/7 Устанавливаем python3"
apt install -y python3
echo "3/7 Успешно установили python3"

# Созадем и запускаем окружение
echo "4/7 Создаем окружение venv"
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
#source .venv/bin/activate - не запускаем окружение,
# чтобы нчиего не сломать, а работам с ним напрямую через  .venc/bin/
echo "4/7 Успешно создали окружение venv"

# Устанавливаем ansible
echo "5/7 Устанавливаем ansible в окружение venv"
.venv/bin/pip install ansible
echo "5/7 Успешно утсановили ansible в окружение venv"

# Устанвока коллекции community.docker для ansible
echo "6/7 Устанавливаем коллекции community.docker ansible в окружение venv"
.venv/bin/ansible-galaxy collection install community.docker
echo "6/7 Успешно установили коллекции community.docker ansible в окружение venv"

echo "7/7 Запускаем плейбук устанвоки svacer server"
.venv/bin/ansible-playbook svacer_install.yml
