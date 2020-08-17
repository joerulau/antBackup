#!/bin/sh
# pasql-tar.sh

USER=postgres
HOST=localhost
PROT=3433
PASSWD=123456

TODAY=$(date -d "now" +%Y-%m-%d)
WORK_PATH=/home/backup

TAR_PATH=${WORK_PATH}/${TODAY}/pgsql

# 如果文件夹不存在，创建文件夹
if [ ! -d "$TAR_PATH" ]; then
        mkdir -p $TAR_PATH
fi

pg_dumpall -h ${HOST} -p ${PROT} -U ${USER} -W ${PASSWD} -c -f ${TAR_PATH}/pgsql.bak

echo ${TAR_PATH}

