#!/bin/bash
echo "##########################################"
echo "#       PostgreSQL DB Backup Tool        #"
echo "##########################################"
echo  "" 
CWDir=$( pwd )
CWUser=$( whoami )
BACKUP_STORAGE=$1
BACKUP_STORAGE_bydefault='/backup'

BACKUP_USER=$2
BACKUP_USER_bydefault='postgres'

USER_PASSWORD=$3
USER_PASSWORD_bydefault='xxXX1234'

check_storage () {
    echo "[0.2] Проверка существования.."
    cd $BACKUP_STORAGE && cd $CWDir
    if [ $? -eq 0 ]; then
        echo "[0.2.+] Каталог существует!" 
    else
        echo "[0.2.-] Каталог не существует! Попытка создать каталог..."
        mkdir -p $BACKUP_STORAGE
        if [ $? -eq 0 ]; then
            echo "[0.2.+] Каталог создан!"
        else
            echo "[0.2.-] Создать каталог не удалось! Вы root?"
            echo "[ERROR] Проверка хранилища прервана!"
            exit 
    fi
    echo "[0.3] Проверка прав доступа..."
    touch $BACKUP_STORAGE/check && rm -f $BACKUP_STORAGE/check && \
        if [ $? -eq 0 ]; then
            echo "[0.3.+] Прав доступа достаточно!"
            echo "[OK] Проверка хранилища успешно закончена!"
        else
            echo "[0.3.-] Прав доступа недостаточно! Попытка сменить владельца и права доступа..."
            chown $CWUser.$CWUser $BACKUP_STORAGE && chmod 765 $BACKUP_STORAGE
            if [ $? -eq 0 ]; then
                echo "[0.3.+] Прав доступа достаточно!"
                echo "[OK] Проверка хранилища успешно закончена!"
            else
                echo "[0.3.-] Сменить владельца или права доступа не удалось! Вы root?"
                echo "[ERROR] Проверка хранилища прервана!"
                exit
            fi
        fi
} 

echo "[0.0] Хранилище"
if (($BACKUP_STORAGE == 'd' )); then
    $BACKUP_STORAGE = $BACKUP_STORAGE_bydefault
    echo "[0.1] Выбрано хранилище по умолчанию.. $BACKUP_STORAGE"
    check_storage()
else
    echo "[0.1] Выбрано хранилище $BACKUP_STORAGE"
    check_storage()
fi    

echo "[1.0] Пользователь"
if (($BACKUP_USER == 'd' | $BACKUP_USER == 'postgres' )); then
    $BACKUP_USER = $BACKUP_STORAGE_bydefault
    echo "[1.1] Выбран пользователь по умолчанию.. $BACKUP_USER "
    if (($USER_PASSWORD == 'd' )); then
        $USER_PASSWORD = $USER_PASSWORD_bydefault
        echo "[1.2] С паролем по умолчанию.. $USER_PASSWORD"
    else
        echo "[1.2] С собственным паролем.. $USER_PASSWORD" 
else
    echo "[1.1] Выбран пользователь $BACKUP_USER"
    if (($USER_PASSWORD == 'd' )); then
        $USER_PASSWORD = $USER_PASSWORD_bydefault
        echo "[1.2] С паролем по умолчанию.. $USER_PASSWORD"
    else
        echo "[1.2] С собственным паролем.. $USER_PASSWORD" 
fi

echo "[2.0] Резервная копия PostgreSQL."
$BACKUP_STORAGE = $BACKUP_STORAGE/$(date +%m.%d.%Y)
echo "[2.1] Создаем каталог для бэкапа.. $BACKUP_STORAGE"
mkdir $BACKUP_STORAGE
if [ $? -eq 0 ]; then
    echo "[2.1.+] Каталог успешно создан!"
else 
    echo "[2.1.-] Каталог не был создан.."
    exit
echo "[2.2] Создаем бэкап"
pg_basebackup -v -h localhost -U $BACKUP_USER -W $USER_PASSWORD -D $BACKUP_STORAGE
if [ $? -eq 0 ]; then
    echo "[2.2.+] Резервная копия успешно создана!"
else
    echo "[2.2.-] Во время создания резервной копии возникли ошибки!"
    exit
fi