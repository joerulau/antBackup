TODAY=$(date -d "now" +%Y-%m-%d)
# 要备份的地址路径
WORK_PATH=/home/backup

SERVER="minio"
# 桶名
BUCKET="ip172.16.10.230"

TAR_PATH=${WORK_PATH}/tar

# 如果文件夹不存在，创建文件夹
if [ ! -d "$TAR_PATH" ]; then
        mkdir -p $TAR_PATH
fi
# 打压缩包
tar -czPf ${TAR_PATH}/${TODAY}.tar.gz -C ${WORK_PATH}/${TODAY} .

# 上传  --recursive 
mc cp ${TAR_PATH}/${TODAY}.tar.gz ${SERVER}/${BUCKET}

# 上传成功后，将今天的备份源删除
rm -rf ${WORK_PATH}/${TODAY}


