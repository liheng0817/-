#!/bin/bash
#describe:恢复云数据库MySQL的备份文件到自建数据库
#相关链接:https://help.aliyun.com/knowledge_detail/41817.html?spm=a2c4g.11186623.4.2.TZZCRH
#

sql_datadir=/home/mysql/data
sql_sourcedir=/opt
date_time=`date +%Y%m%d`


sys_init() {
if [ ! -d ${sql_datadir} ];then
	mkdir ${sql_datadir}
fi
}

clear_environmental() {
netstat -anple | grep 3306  
if [ $? -eq 0 ];then
killall mysqld  &&  rm -fr ${sql_datadir}/*
else
rm -fr ${sql_datadir}/*
fi
} 

#download_sqlfile(){
#}

recover_sql() {
cd ${sql_sourcedir}
/bin/bash rds_backup_extract.sh -f  hins4953173_data_20180704113854.tar.gz -C ${sql_datadir}  > 1.log   2>&1
/usr/bin/innobackupex --defaults-file=${sql_datadir}/backup-my.cnf --apply-log  ${sql_datadir}   >>  1.log 2>&1
grep "completed OK!"  1.log 
if [ $? -eq 0 ];then
echo "[mysqld]
innodb_checksum_algorithm=innodb
innodb_data_file_path=ibdata1:200M:autoextend
innodb_log_files_in_group=2
innodb_log_file_size=1048576000
innodb_undo_directory=.
innodb_undo_tablespaces=0" > ${sql_datadir}/backup-my.cnf
fi
chown -R mysql:mysql ${sql_datadir}
/usr/bin/mysqld_safe --defaults-file=${sql_datadir}/backup-my.cnf --user=mysql --datadir=${sql_datadir} &
netstat -anple | grep 3306
if [ $? -eq 0 ];then
echo "MYSQL recover sucess!" >> 1.log 2>&1
fi
}

main() {
sys_init
clear_environmental
recover_sql
}

main
