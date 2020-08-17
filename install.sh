#!/bin/sh
# Author:  qiaor
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#                   AntBakcup for CentOS/RedHat 7+                    #
#######################################################################
"

antbakcup_dir=$(dirname "`readlink -f $0`")
pushd ${antbakcup_dir} > /dev/null

. ./options.conf

minio_install_dir="${antbakcup_dir}/minio"

version() {
  echo "version: 1.0"
  echo "updated date: 2020-04-23"
}

Show_Help() {
  version
  echo "Usage: $0  command ...[parameters]....
  --help, -h                  Show this help message
  --version, -v               Show version info
  --client, -c                Install client backup service
  --server, -s                Install backup server
  --minioClient, -m          Install minio client
  "
}

Install_AntBackupClient() {
    # check mysql backup
    while :; do echo
        read -e -p "Do you want to enable Database backup? [y/n]: " db_flag
        if [[ ! ${db_flag} =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            if [ "${db_flag}" == 'y' ]; then
                while :; do echo
                    echo 'Please select a version of the Database:'
                    echo -e "\t${CMSG} 1${CEND}. Enable MySQL backup"
                    echo -e "\t${CMSG} 2${CEND}. Enable PostgreSQL backup"
                    echo -e "\t${CMSG} 3${CEND}. Do not backup"
                    read -e -p "Please input a number:(Default 3 press Enter) " db_option
                    db_option=${db_option:-3}
                    if [[ ! ${db_option} =~ ^[1-3]$ ]]; then
                        echo "${CWARNING}input error! Please only input number 1~3${CEND}"
                    else
                        while :; do
                            if [[ "${db_option}" == '2' ]]; then
                                read -e -p "Please input the path of PostgreSQL(/data/postgres): " postgres_server_dir
                                if [[ ! -d ${postgres_server_dir} ]]; then
                                    echo "${CWARNING}input error! Please input correct path${CEND}"
                                else
                                    break
                                fi
                            elif [[ "${db_option}" == '1' ]]; then
                                read -e -p "Please input the path of MySQL(/data/mysql): " mysql_server_dir
                                if [[ ! -d ${mysql_server_dir} ]]; then
                                    echo "${CWARNING}input error! Please input correct path${CEND}"
                                else
                                    break
                                fi
                            else
                                break
                            fi
                        done
                        
                        break
                    fi
                done
            fi
            break
        fi
    done

    # check redis backup
    while :; do echo
        read -e -p "Do you want to enable Redis backup? [y/n]: " redis_flag
        if [[ ! ${redis_flag} =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            if [[ "${redis_flag}" == 'y' ]]; then
                while :; do
                    read -e -p "Please input the redis path of Redis(/usr/local/webserver/redis): " redis_server_dir
                    if [[ ! -d ${redis_server_dir} ]]; then
                        echo "${CWARNING}input error! Please input correct redis path${CEND}"
                    else
                        break
                    fi
                done
            fi
            break
        fi
    done

    # check Nginx backup
    while :; do echo
        read -e -p "Do you want to enable Nginx backup? [y/n]: " nginx_flag
        if [[ ! ${nginx_flag} =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            if [[ "${nginx_flag}" == 'y' ]]; then
                while :; do
                    read -e -p "Please input the nginx conf path of Nginx(/usr/local/webserver/nginx/conf): " nginx_conf_dir
                    if [[ ! -d ${nginx_conf_dir} ]]; then
                        echo "${CWARNING}input error! Please input correct nginx conf path${CEND}"
                    else
                        break
                    fi
                done
            fi
            break
        fi
    done

    # check git repo backup
    while :; do echo
        read -e -p "Do you want to enable Git Repo backup? [y/n]: " git_flag
        if [[ ! ${git_flag} =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            if [[ "${git_flag}" == 'y' ]]; then
                while :; do
                    read -e -p "Please input the git repo path of Git(/usr/local/webserver/git/repo): " git_repo_dir
                    if [[ ! -d ${git_repo_dir} ]]; then
                        echo "${CWARNING}input error! Please input correct git repo path${CEND}"
                    else
                        break
                    fi
                done
            fi
            break
        fi
    done

    # check images backup
    while :; do echo
        read -e -p "Do you want to enable Images backup? [y/n]: " images_flag
        if [[ ! ${images_flag} =~ ^[y,n]$ ]]; then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            if [[ "${images_flag}" == 'y' ]]; then
                while :; do
                    read -e -p "Please input the path of Images(/usr/local/webserver/images): " images_file_dir
                    if [[ ! -d ${images_file_dir} ]]; then
                        echo "${CWARNING}input error! Please input correct images path${CEND}"
                    else
                        break
                    fi
                done
            fi
            break
        fi
    done

    if [[ "${db_flag}" == 'n' ]] && [[ "${redis_flag}" == 'n' ]] && [[ "${nginx_flag}" == 'n' ]] && [[ "${git_flag}" == 'n' ]] && [[ "${images_flag}" == 'n' ]]; then
        echo "${CSUCCESS}antBackup installed successfully! ${CEND}"
        exit 0
    fi


    # get the IP information
    IPADDR=$(./include/get_ipaddr.py)
    echo "${IPADDR} ......"

    [ ! -d ${backup_root_dir} ] && mkdir -p ${backup_root_dir}
    [ ! -d ${backup_data_dir} ] && mkdir -p ${backup_data_dir}
    [ ! -d ${backup_script_dir} ] && mkdir -p ${backup_script_dir}
    [ ! -d ${backup_dayly_script_dir} ] && mkdir -p ${backup_dayly_script_dir}
    [ ! -d ${backup_weekly_script_dir} ] && mkdir -p ${backup_weekly_script_dir}
    [ ! -d ${backup_upload_script_dir} ] && mkdir -p ${backup_upload_script_dir}

    [ ! -e "${backup_dayly_script_dir}/dayly-script.sh" ] && cp ${antbakcup_dir}/src/scripts/dayly/dayly-script.sh ${backup_dayly_script_dir}
    [ ! -e "${backup_weekly_script_dir}/weekly-script.sh" ] && cp ${antbakcup_dir}/src/scripts/weekly/weekly-script.sh ${backup_weekly_script_dir}
    [ ! -d ${backup_dayly_script_dir}/script ] && mkdir -p ${backup_dayly_script_dir}/script
    [ ! -d ${backup_weekly_script_dir}/script ] && mkdir -p ${backup_weekly_script_dir}/script



    # Database
    if [ "${db_flag}" == 'y' ] && [ "${db_option}" != '3' ]; then
        if [[ ${db_option} == '2' ]]; then
            while :; do echo
                read -e -p "Please input the pgsql host: " pgsql_host
                if [ -z "${pgsql_host}" ]; then
                    echo "${CWARNING}input error! Please input the pgsql host${CEND}"
                else
                    while :; do echo
                        read -e -p "Please input the pgsql username: " pgsql_user_name
                        if [ -z "${pgsql_user_name}" ]; then
                            echo "${CWARNING}input error! Please input the pgsql username${CEND}"
                        else
                            while :; do echo
                                read -e -p "Please input the pgsql password: " pgsql_password
                                if [ -z "${pgsql_password}" ]; then
                                    echo "${CWARNING}input error! Please input the pgsql password${CEND}"
                                else
                                    break
                                fi
                            done
                            break
                        fi
                    done
                    break
                fi
            done

            cp ${antbakcup_dir}/src/scripts/dayly/script/pgsql-tar.sh ${backup_dayly_script_dir}/script
            sed -i "s@WORK_PATH=\/home\/backup@WORK_PATH=\/home\/backup\/backup-data@" ${backup_dayly_script_dir}/script/pgsql-tar.sh
            sed -i "s@HOST=localhost@HOST=${pgsql_host}@" ${backup_dayly_script_dir}/script/pgsql-tar.sh
            sed -i "s@USER=postgres@USER=${pgsql_password}@" ${backup_dayly_script_dir}/script/pgsql-tar.sh
            sed -i "s@PASSWD=123456@PASSWD=${pgsql_user_name}@" ${backup_dayly_script_dir}/script/pgsql-tar.sh
        else
            cp ${antbakcup_dir}/src/scripts/dayly/script/mysql-tar.sh ${backup_dayly_script_dir}/script
            sed -i "s@WORK_PATH=\/home\/backup@WORK_PATH=\/home\/backup\/backup-data@" ${backup_dayly_script_dir}/script/mysql-tar.sh
            sed -i "s@MYCMD=mysql@MYCMD=${mysql_server_dir}\/bin\/mysql@" ${backup_dayly_script_dir}/script/mysql-tar.sh
            sed -i "s@MYDUMP=mysqldump@MYDUMP=${mysql_server_dir}\/bin\/mysqldump@" ${backup_dayly_script_dir}/script/mysql-tar.sh
        fi
    fi

    # Redis
    if [ "${redis_flag}" == 'y' ]; then
        cp ${antbakcup_dir}/src/scripts/dayly/script/redis-tar.sh ${backup_dayly_script_dir}/script
        sed -i "s@WORK_PATH=\/home\/backup@WORK_PATH=\/home\/backup\/backup-data@" ${backup_dayly_script_dir}/script/redis-tar.sh
    fi

    # Nginx
    if [ "${nginx_flag}" == 'y' ]; then
        cp ${antbakcup_dir}/src/scripts/dayly/script/nginx-tar.sh ${backup_dayly_script_dir}/script
        sed -i "s@WORK_PATH=\/home\/backup@WORK_PATH=\/home\/backup\/backup-data@" ${backup_dayly_script_dir}/script/nginx-tar.sh
        sed -i "s@NGINX_CONF_PATH=\/usr\/local\/nginx\/conf@NGINX_CONF_PATH=${nginx_conf_dir}@" ${backup_dayly_script_dir}/script/nginx-tar.sh
    fi

    # Git
    if [ "${git_flag}" == 'y' ]; then
        cp ${antbakcup_dir}/src/scripts/weekly/script/git-tar.sh ${backup_weekly_script_dir}/script
        sed -i "s@WORK_PATH=\/home\/backup@WORK_PATH=\/home\/backup\/backup-data@" ${backup_weekly_script_dir}/script/git-tar.sh
        sed -i "s@GIT_REPO_DIR=\/urs\/local\/gogs\/repo@GIT_REPO_DIR=${git_repo_dir}@" ${backup_weekly_script_dir}/script/git-tar.sh
    fi

    # Images
    if [ "${images_flag}" == 'y' ]; then
        cp ${antbakcup_dir}/src/scripts/weekly/script/images-tar.sh ${backup_weekly_script_dir}/script
        sed -i "s@WORK_PATH=\/home\/backup@WORK_PATH=\/home\/backup\/backup-data@" ${backup_weekly_script_dir}/script/images-tar.sh
        sed -i "s@IMAGES_FILE_DIR=\/data\/osimg@IMAGES_FILE_DIR=${images_file_dir}@" ${backup_weekly_script_dir}/script/images-tar.sh

    fi

    # Install_MinioClient
    Install_MinioClient

    # upload
    Install_UploadService
}

Install_MinioClient() {
    if [ -e "${minio_install_dir}/client/mc" ]; then
        echo "${CSUCCESS}mc installed successfully! ${CEND}"
    else
        [ ! -d "${minio_install_dir}/client" ] && mkdir -p ${minio_install_dir}/client

        pushd ${antbakcup_dir}/src > /dev/null
        cp minioClient/mc ${minio_install_dir}/client
        chmod +x ${minio_install_dir}/client/mc
        [ ! -e /usr/local/bin/mc ] && ln -s ${minio_install_dir}/client/mc /usr/local/bin/mc

        mc config host add minio ${backup_server} ${backup_server_user} ${backup_server_pwd}

        if [ -e "${minio_install_dir}/client/mc" ]; then
            echo "${CSUCCESS}mc installed successfully! ${CEND}"
        else
            rm -rf ${minio_install_dir}/client
            echo "${CFAILURE}mc install failed, Please Contact the author! ${CEND}"
        fi

        popd > /dev/null
    fi
}

Install_UploadService() {
    echo "cp ${antbakcup_dir}/src/scripts/upload/*.sh ${backup_upload_script_dir}"
    cp -f ${antbakcup_dir}/src/scripts/upload/*.sh ${backup_upload_script_dir}
    sed -i "s@WORK_PATH=\/home\/backup@WORK_PATH=\/home\/backup\/backup-data@" ${backup_upload_script_dir}/upload-tar.sh
    sed -i "s@WORK_PATH=\/home\/backup@WORK_PATH=\/home\/backup\/backup-data@" ${backup_upload_script_dir}/rms-tar.sh

    sed -i "s@BUCKET=\"ip172.16.10.230\"@BUCKET=ip${IPADDR}@" ${backup_upload_script_dir}/rms-tar.sh

    # 加入定时任务
    crontab -l > crontab.conf && cat >> crontab.conf <<EOF
# 每天的0点1分，备份日备份文件，实际上是前一天的数据
1 0 * * * /bin/sh ${backup_dayly_script_dir}/dayly-script.sh >/dev/null 2>&1
# 每周日0点1分，备份周备份文件
1 0 * * 7 /bin/sh ${backup_weekly_script_dir}/weekly-script.sh >/dev/null 2>&1
# 每天的1点，服务器开始上传远程服务器（这里会删除7天前的数据）
0 1 * * * /bin/sh ${backup_upload_script_dir}/upload-script.sh >/dev/null 2>&1
EOF
    crontab crontab.conf

    

    echo "${CSUCCESS}crontab added successfully! ${CEND}"

}

Install_MinioServer() {
    [ ! -e "${minio_install_dir}/server" ] && mkdir -p ${minio_install_dir}/server
    pushd ${antbakcup_dir}/src > /dev/null
    cp minioClient/docker-compose.yml ${minio_install_dir}/server/docker-compose.yml
    popd > /dev/null
    pushd ${minio_install_dir}/server > /dev/null
    docker-compose up -d
    popd > /dev/null

    echo "${CSUCCESS}MinioServer installed successfully! ${CEND}"
}


ARG_NUM=$#
TEMP=`getopt -o hvVcsm --long help,version,client,server,minioClient -- "$@" 2>/dev/null`
[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
eval set -- "${TEMP}"
while :; do
    [ -z "$1" ] && break;
    case "$1" in
        -h|--help)
          Show_Help; exit 0
          ;;
        -v|-V|--version)
          version; exit 0
          ;;
        -c|--client)
          Install_AntBackupClient; exit 0
          ;;
        -s|--server)
          Install_MinioServer; exit 0
          ;;
        -m|--minioClient)
          Install_MinioClient; exit 0
          ;;
        --)
          shift
          ;;
        *)
          echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
          ;;
    esac
done

Show_Help