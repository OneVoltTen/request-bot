#!/bin/bash
. /root/app/config.sh

nohup ${INSTALL}/app/retrieve.sh >> ${LOG}/retrieve.log &

echo ps -ef | grep "upload.php" | grep -v grep
if [[ $? -eq 0 ]]; then
    echo "upload"
    nohup php ${INSTALL}/upload/upload.php >> ${LOG}/upload.log &
fi

nohup php ${INSTALL}/rename/rename.php downloads >> ${LOG}/rename.log &
nohup ${INSTALL}/encode/encode.sh >> ${LOG}/main.log &