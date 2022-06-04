# PostgreSQL_Restore
Этот скрипт позволяет выполнять **репликацию серверов БД PostgreSQL** из резервных копий
>sh ./pg_restore_starter.sh [/path/to/backup-storage/|d] [mm.dd.yyyy]

**Пример: ./pg_restore_starter.sh /myfolder/backup 12.22.2009** \
Это приведет к тому, что скрипт восстановит данные из резервной копии, которая находится в каталоге /myfolder/12.22.2009 .
# Зависимости
## Хранилище
### **[/path/to/backup-storage|d]**
По умолчанию, **хранилищем** является каталогом '/backups', если вы хотите указать другой каталог, который хранит бэкап, то вместо **[/path/to/backup-storage]** укажите свой путь. 
Если вам подходит место по умолчанию, введите **'d'**;

## Дата
### **[mm.dd.yyyy]**
Обратите внимание, что у этого параметра отсутсвует **значение по умолчанию**!
Вы обязательно должны указать имя каталога, содержащий в себе бэкап, и который находится в **хранилище**. 

## База данных
**У вас должна быть установлена БД Postgresql!** \
Настройка не требуется!

# Принцип работы
**Запуск только от 'root' !**
## [-1.*] Предподготовка PostgreSQL
**Если PostgreSQL будет отсутствовать скрипт прервется!**\
Для корректной работы вам понадобится БД PostgreSQL, с пустым **main** каталогом, отсутствующим кластером серверов! \
Чтобы точно удостоверится, что они отсутсвуют, **в начале скрипта будет выполнено удаление, со сбросом кластера**, и установка БД. \
Во время удаления (**[-1.0]**) вам нужно будет ввести сначала **'y'**, а затем, когда появится вопрос о судьбе кластеров, нажать клавишу **'Enter'**. \

После этого будет выполнена установка PostgreSQL.
## [0.*] Проверка Хранилища
Здесь выполняется проверка корректности, введенного вами пути к каталогу, содержащему бэкап. \
**Если каталог будет осутствовать или иметь недостаточные права на чтение, то скрипт прервется!**
## [1.*] Постподготовка PostgreSQL
На этом этапе БД останавливается, а затем вычищается каталог /var/lib/postgresql/{version}/main .
## [2.*] Восстановление данных
Здесь архив распаковывается и доставляется в каталог /var/lib/postgresql/{version}/main , после на весь каталог /var/lib/postgres , рекурсивно применяется смена владельца на пользователя **postgres**.
## [3.*] Перезагрузка PostgreSQL
Тут скрипт включает PostgreSQL \
**Подождите некоторое время! В зависимости от размеров импортируемых данных время может отличаться.**