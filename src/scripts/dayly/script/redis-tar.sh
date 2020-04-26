#!/bin/sh

TODAY=$(date -d "now" +%Y-%m-%d)

WORK_PATH=/home/backup

TAR_PATH=${WORK_PATH}/${TODAY}/redis

# 如果文件夹不存在，创建文件夹
if [ ! -d "$TAR_PATH" ]; then
        mkdir -p $TAR_PATH
fi

redis-cli SAVE > /dev/null 2>&1
mv /dump.rdb ${TAR_PATH}/dump.rdb
