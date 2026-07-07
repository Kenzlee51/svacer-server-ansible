#!/bin/bash

set -e

TARGET_IP=""
VERBOSE_ANSIBLE=""

# Разбираем аргументы
while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--remote)
            TARGET_IP="$2"
            shift 2
            ;;
        -v|-vv|-vvv)
            VERBOSE_ANSIBLE="$1"
            shift
            ;;
        -*|--*|*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done



echo "0/7 Чистим остатки прошлых прогонов"
rm -f /etc/apt/sources.list.d/docker.sources
rm -f /etc/docker/daemon.json
echo "0/7 Успешно очистили систему!"

echo "1/7 Обновляем репы"
apt update
echo "1/7 Репы успешно обнволены"

# Установка требуемых пакетов docker
#echo "2/7 Устанавливаем docker.io docker-compose-plugin"
#apt install -y docker.io docker-compose-plugin
#echo "2/7 Успешно установили docker.io docker-compose-plugin"

# Устанаваливаем или обноваяем python3
echo "3/7 Устанавливаем python3"
apt install -y python3
apt install -y python3-venv
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

# Устанвока коллекции  для ansible
echo "6/7 Устанавливаем коллекции community.docker ansible в окружение venv"
.venv/bin/ansible-galaxy collection install community.docker
.venv/bin/ansible-galaxy collection install community.crypto.openssh_keypair
echo "6/7 Успешно установили коллекции community.docker ansible в окружение venv"

echo "7/7 Запускаем плейбук устанвоки svacer server"
.venv/bin/ansible-playbook -i inventory $VERBOSE_ANSIBLE svacer_install.yml -e target="$TARGET_IP"
