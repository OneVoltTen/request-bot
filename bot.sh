#!/bin/bash
. /root/app/config.sh

nohup ${INSTALL}/app/retrieve.sh >> ${LOG}/retrieve.log &
nohup php ${INSTALL}/upload/upload.php >> ${LOG}/upload.log &
nohup php ${INSTALL}/rename/rename.php downloads >> ${LOG}/rename.log &
nohup ${INSTALL}/encode/encode.sh >> ${LOG}/main.log &