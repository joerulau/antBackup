#!/bin/sh

MYUSER=root
PASS=123456

TODAY=$(date -d "now" +%Y-%m-%d)

WORK_PATH=/home/backup

TAR_PATH=${WORK_PATH}/${TODAY}/mysql

# 如果文件夹不存在，创建文件夹
if [ ! -d "$TAR_PATH" ]; then
        mkdir -p $TAR_PATH
fi


MYCMD="mysql -u$MYUSER -p$PASS"
MYDUMP="mysqldump -u$MYUSER -p$PASS"
for database in `$MYCMD -e "show databases;"|sed '1,3d'|grep -v "performance_schema"`
do
  $MYDUMP -B -F --events $database|gzip >${TAR_PATH}/${database}.sql.gz
done

