TODAY=$(date -d "now" +%Y-%m-%d)
NGINX_CONF_PATH=/usr/local/nginx/conf
# 要备份的地址路径
WORK_PATH=/home/backup

TAR_PATH=${WORK_PATH}/${TODAY}/nginx
# 如果文件夹不存在，创建文件夹
if [ ! -d "$TAR_PATH" ]; then
        mkdir -p $TAR_PATH
fi
# 打压缩包
tar -czvf ${TAR_PATH}/nginx_conf.tar.gz -C ${NGINX_CONF_PATH} .



