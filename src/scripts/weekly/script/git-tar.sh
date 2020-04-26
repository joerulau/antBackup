#!/bin/sh
TODAY=$(date -d "now" +%Y-%m-%d)
echo ${TODAY} "gogs-repo"
# 要备份的地址路径
WORK_PATH=/home/backup

TAR_PATH=${WORK_PATH}/${TODAY}/git-repo
GIT_REPO_DIR=/urs/local/gogs/repo
# 如果文件夹不存在，创建文件夹
if [ ! -d "$TAR_PATH" ]; then
        mkdir -p $TAR_PATH
fi
tar -czf ${TAR_PATH}/gogs-repositories.tar.gz -C ${GIT_REPO_DIR} .

