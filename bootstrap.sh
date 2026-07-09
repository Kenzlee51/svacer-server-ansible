#!/bin/bash
# ./bootstrap.sh -r ip_address -u username -p user_password -s sudo_password
# ../bootstrap.sh -r ip_address -a - запускаем в авторежиме без првоерки данных на удаленной машине

set -e

TARGET_IP="" # -r
MAIN_USER="" # -u
MAIN_USER_PASSWORD="" # -p
MAIN_USER_SUDO_PASSWORD="" # -s
VERBOSE_ANSIBLE=""
ARGS_FOR_ANSIBLE=""
SKIP_TAGS_ARG=""
TAGS_TO_SKIP=""
AUTO_TEG=""
AUTO="false" #Флаг для плейбука. Ручная или автоматическая сборка



# Разбираем аргументы
while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--remote)
            TARGET_IP="-e target=$2"
            shift 2
            ;;
        -u|--user-target)
            MAIN_USER="-e main_user=$2"
            shift 2
            ;;
        -p|--password-target)
            MAIN_USER_PASSWORD="-e main_user_password=$2"
            shift
            ;;
        -s|--sudo-password)
            MAIN_USER_SUDO_PASSWORD="-e main_user_sudo_password=$2"
            shift
            ;;
        -v|-vv|-vvv)
            VERBOSE_ANSIBLE="$1"
            shift
            ;;
        -a|-auto)
            AUTO="true"
            shift
            ;;
        -*|--*|*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

if [[ -z "$TARGET_IP" ]]; then
    TAGS_TO_SKIP="prod"
fi

if [[ "$AUTO" != "false" ]]; then
    if [[ -n "$TAGS_TO_SKIP" ]]; then
        TAGS_TO_SKIP="$TAGS_TO_SKIP,verification"
    else
        TAGS_TO_SKIP="verification"
    fi
fi

if [[ -n "$TAGS_TO_SKIP" ]]; then
    SKIP_TAGS_ARG="--skip-tags $TAGS_TO_SKIP"
fi

ARGS_FOR_ANSIBLE="$TARGET_IP $MAIN_USER $MAIN_USER_PASSWORD $MAIN_USER_SUDO_PASSWORD"


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
.venv/bin/ansible-galaxy collection install community.crypto
.venv/bin/ansible-galaxy collection install ansible.posix
echo "6/7 Успешно установили коллекции community.docker ansible в окружение venv"

echo "7/7 Запускаем плейбук устанвоки svacer server"
.venv/bin/ansible-playbook -i inventory $VERBOSE_ANSIBLE svacer_install.yml $SKIP_TAGS_ARG $ARGS_FOR_ANSIBLE
