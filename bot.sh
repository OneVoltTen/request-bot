#!/bin/bash
. /root/app/config.sh

nohup ${INSTALL}/app/retrieve.sh >> ${LOG}/retrieve.log & # retrieve torrent list and initiate torrents
nohup php /root/rename/rename.php downloads >> ${LOG}/rename.log & # rename sorted files into queue folder
nohup ${INSTALL}/encode/encode.sh >> ${LOG}/main.log & # encode files in queue folder to upload folder

echo ps -ef | grep "upload.php" | grep -v grep # execute upload.php if not running
if [[ $? -eq 0 ]]; then
    echo "upload"
    nohup php ${INSTALL}/upload/upload.php >> ${LOG}/upload.log &
fi
