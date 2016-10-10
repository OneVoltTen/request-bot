#!/bin/bash
. /root/config.sh
lastlog=`tail -1 ${INSTALL}/log_upload.txt | head -1`

php ${INSTALL}/rename.php 2

PIDS=`ps aux | grep ${1}.php | grep -v grep`
if [ -z "$PIDS" ]; then
	if [ "${1}" == "upload" ]; then
		echo "initiate ${1}"
		php ${INSTALL}/${1}.php >> ${INSTALL}/log_upload.txt &
	else
		echo "unknown ${1}"
	fi
else
	if [ "${1}" == "upload" ]; then
		if [[ ! $lastlog == *"locked"* ]]; then
			echo "locked ${1}.php"
		fi
	else
		echo "unknown ${1}"
	fi
fi
