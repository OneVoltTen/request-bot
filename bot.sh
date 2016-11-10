#!/bin/bash
. /root/app/config.sh

#revise log comments
ERW="execute retieve worker..."
QCF="queue contain files..."
ER="execute rename..."
FR="ffmpeg running..."
PR="php running..."
EE="execute encode..."
FR="ffmpeg running..."
SY="sabishī yo..."

nohup ${INSTALL}/app/retrieve.sh >> ${LOG}/retrieve.log &
php ${INSTALL}/upload/upload.php >> ${LOG}/upload.log &
php ${INSTALL}/rename/rename.php downloads >> ${LOG}/rename.log &
#nohup ${INSTALL}/encode/encode.sh >> ${LOG}/main.log &