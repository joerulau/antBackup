#!/bin/sh
TODAY=$(date -d "now" +%Y-%m-%d)
echo ${TODAY} "oming"
# 要备份的地址路径
WORK_PATH=/home/backup
IMAGES_FILE_DIR=/data/osimg

TAR_PATH=${WORK_PATH}/${TODAY}/images
# 如果文件夹不存在，创建文件夹
if [ ! -d "$TAR_PATH" ]; then
        mkdir -p $TAR_PATH
fi
tar -czf ${TAR_PATH}/images.tar.gz -C ${IMAGES_FILE_DIR} .