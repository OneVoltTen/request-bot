#!/bin/bash
. /root/config.sh

countsource=`ls -1 $DOWNLOAD/*{mkv,mp4,ass} 2>/dev/null | wc -l`
countqueue=`ls -1 $QUEUE/*.{mkv,mp4,ass} 2>/dev/null | wc -l`
countencoded=`ls -1 $ENCODED/*.mp4 2>/dev/null | wc -l`
lastlog=`tail -1 ${INSTALL}/log.txt | head -1`

ERW="execute retieve worker..."
EUW="execute upload worker..."
QCF="queue contain files..."
ER="execute rename..."
FR="ffmpeg running..."
EE="execute encode..."
FR="ffmpeg running..."
SY="sabishī yo..."

if [[ -z "$1" && "$1"=="sort" ]]; then
	echo "${ERW}"; nohup ${INSTALL}/app/retrieve.sh keep >/dev/null 2>&1 &
fi
if [ $countencoded != 0 ]; then
	echo "${EUW}" >> ${INSTALL}/log.txt >> ${INSTALL}/log.txt;nohup php ${INSTALL}/NodefilesUploader.php >> ${INSTALL}/log.txt &
fi

if [[ $countsource != 0 ]]; then
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
