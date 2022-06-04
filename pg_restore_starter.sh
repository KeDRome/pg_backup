#!/bin/bash
echo "##########################################"
echo "#      PostgreSQL DB Restore Tool        #"
echo "##########################################"
echo  ""

PG_VERSION=$(ls /var/lib/postgresql/)
echo "[-1.0] Удаляем базу данных.. "
apt remove --purge postgresql-$PG_VERSION
if [ $? -eq 0 ]; then 
    echo "[-1.+] БД успешно удалена!"
else
    echo "[-1.-] Во время удаления возникли проблемы.. Вы root? БД PostgreSQL установлена?"
    exit
fi
CWDir=$( pwd )
CWUser=$( whoami )
WDate=$2
echo "[-1.1] Устанавливаем БД PostgreSQL"
apt install postgresql -y  
if [ $? -eq 0 ]; then
    echo "[-1.1.+] Установка успешно завершена!"
else
    echo "[-1.1.-] Во время установки возникли ошибки! Вы root?"
    exit
fi
PG_VERSION=$(ls /var/lib/postgresql/)

BACKUP_STORAGE=$1
BACKUP_STORAGE_bydefault='/backup'

check_storage(){
    echo "[0.2] Проверка существования.."
    cd $BACKUP_STORAGE && cd $CWDir
    if [ $? -eq 0 ]; then
        echo "[0.2.+] Каталог существует!" 
    else
        echo "[0.2.-] Каталог не существует! Вы правильно указали путь? Проверьте права доступа к каталогу!"
        exit
    fi 
};

echo "[0.0] Хранилище"
if [[ $BACKUP_STORAGE == "d" ]]; then
    BACKUP_STORAGE=$BACKUP_STORAGE_bydefault/$WDate
    echo "[0.1] Выбрано хранилище по умолчанию.. $BACKUP_STORAGE"
    check_storage
else
    echo "[0.1] Выбрано хранилище $BACKUP_STORAGE"
    BACKUP_STORAGE=$BACKUP_STORAGE/$WDate
    check_storage
fi    
echo "[1.0] Подготовка PostgreSQL"
systemctl stop postgresql 
if [ $? -eq 0 ]; then
    echo "[1.+] БД остановлена успешно!"
    echo "[1.1] Очищаем каталог /var/lib/postgresql/$PG_VERSION/main"
    rm -rf /var/lib/postgresql/$PG_VERSION/main/*
    if [ $? -eq 0 ]; then
        echo "[1.1.+] Каталог успешно очищен!"
    else
        echo "[1.1.-] Очистить каталог не вышло.. Вы root?"
        exit
    fi
else
    echo "[1.-] Во время остановки БД возникли проблемы.. Вы root?"
    exit
fi

echo "[2.0] Восстановление.."
tar -xf $BACKUP_STORAGE/base.tar.gz -C /var/lib/postgresql/$PG_VERSION/main/
chown postgres.postgres -R /var/lib/postgresql/ 
if [ $? -eq 0 ]; then
    echo "[2.1.+] Восстановление успешно выполнено!";
else
    echo "[2.1.-] Во время восстановления возникли ошибки!"
    exit
fi
echo "[3.0] Запускаем PostgreSQL"
systemctl start postgresql && \
    echo "[3.+] База запущена!" || \
    echo "[3.-] Запуск базы не удался! Попробуйте вручную!"