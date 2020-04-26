
# 要备份的地址路径
WORK_PATH=/home/backup
#########################
#删除8天之前的文件      #
#########################

TAR_PATH=${WORK_PATH}/tar

find $TAR_PATH -type f  -mtime +8 | xargs rm -rvf


