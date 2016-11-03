#!/bin/bash
. /root/config.sh

countsource=`ls -1 $DOWNLOAD/*{mkv,mp4,ass} 2>/dev/null | wc -l`
countqueue=`ls -1 $QUEUE/*.{mkv,mp4,ass} 2>/dev/null | wc -l`
countencoded=`ls -1 $ENCODED/*.mp4 2>/dev/null | wc -l`
lastlog=`tail -1 ${INSTALL}/log.txt | head -1`

ERW="execute retieve worker..."
QCF="queue contain files..."
ER="execute rename..."
FR="ffmpeg running..."
EE="execute encode..."
FR="ffmpeg running..."
SY="sabishī yo..."

nohup ${INSTALL}/app/retrieve.sh >> ${INSTALL}/log_retrieve.txt &

if [ $countencoded != 0 ]; then
	nohup ${INSTALL}/app/si.sh upload >> ${INSTALL}/log_upload.txt
fi

if [[ $countsource != 0 ]]; then
	php /root/rename.php downloads >> /root/log.txt; sleep 1
	if [ $countqueue == 0 ]; then
		php ${INSTALL}/rename.php downloads  >> ${INSTALL}/log.txt; sleep 1
		echo "${ER}" >> ${INSTALL}/log.txt; mv ${DOWNLOAD}/*.mkv ${QUEUE}; sleep 1
		if pidof -s ffmpeg > /dev/null; then
			if [[ ! $lastlog == "${FR}" ]]; then
				echo "${FR}" >> ${INSTALL}/log.txt
			fi
		else
			echo "${EE}" >> ${INSTALL}/log.txt; nohup ${INSTALL}/encode.sh >> ${INSTALL}/log.txt &
		fi
	else
		if [[ ! $lastlog == "${QCF}" ]]; then
			echo "${QCF}" >> ${INSTALL}/log.txt
		fi
	fi
elif pidof -s ffmpeg > /dev/null; then
	if [[ ! $lastlog == "${FR}" ]]; then
		echo "${FR}" >> ${INSTALL}/log.txt
	fi
elif [[ $countqueue != 0 ]]; then
	sleep 15
	if pidof -s ffmpeg > /dev/null; then
		echo "${FR}"
	else
		if [[ ! $lastlog == "${QCF}" ]]; then
			echo "${QCF}" >> ${INSTALL}/log.txt
		fi
	fi
else
	if [[ ! $lastlog == "${SY}" ]]; then
		echo "${SY}" >> ${INSTALL}/log.txt
	fi
fi
