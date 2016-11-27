#!/bin/bash
. /root/app/config.sh

LOCKFILE=/tmp/lock.txt # create lockfile
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "bot.sh already running" >> ${LOG}/main.log
    exit
else
	echo $$ > ${LOCKFILE} # set process id into lockfile
	trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
fi

nohup ${INSTALL}/sort/sort.sh >> ${LOG}/sort.log  &
nohup ${INSTALL}/app/retrieve.sh >> ${LOG}/retrieve.log &
nohup php /root/rename/rename.php downloads >> ${LOG}/rename.log &
nohup ${INSTALL}/encode/encode.sh >> ${LOG}/main.log &

echo ps -ef | grep "upload.php" | grep -v grep
if [[ $? -eq 0 ]]; then
    echo "upload"
    nohup php ${INSTALL}/upload/upload.php >> ${LOG}/upload.log &
fi

sleep 30

rm -f ${LOCKFILE}
