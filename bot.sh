#!/bin/bash
cd /root
SOURCE="/var/www/downloads"; SECOND="/var/www/downloads/.00"; QUEUE="/var/www/downloads/.queue"; ENCODED="/var/www/encoded"; countqueue=`ls -1 $QUEUE/*.{mkv,mp4,ass} 2>/dev/null | wc -l`
countencoded=`ls -1 $ENCODED/*.mp4 2>/dev/null | wc -l`; countsource=`ls -1 $SOURCE/*{mkv,mp4,ass} 2>/dev/null | wc -l`; countsecond=`ls -1 $SECOND/*.{mkv,mp4,avi} 2>/dev/null | wc -l`

if [[ -z "$1" && "$1"=="sort" ]]; then
	echo "execute retieve worker..."
	nohup /root/retrieve.sh keep > /dev/null 2>&1 &
fi

if [ $countencoded != 0 ]; then
	echo "execute upload worker..."
	nohup php /root/NodefilesUploader.php > /dev/null 2>&1 &
fi

php /root/renameu.php
php /root/rename.php downloads
sleep 1

if [ $countsource != 0 ]; then
	echo "execute rename..."
	mv ${SOURCE}/*.mkv ${QUEUE}; sleep 2
	PROCESS_DT=$(ps -C ffmpeg -o ruser=)
	if [[ $PROCESS_DT == "ffmpeg" ]]; then
		sleep 15
		if [[ $PROCESS_DT == "ffmpeg" ]]; then
			echo "execute encode..."
			nohup /root/encode.sh > /dev/null 2>&1 &
		fi
	else
		echo "isogashii desu..."
	fi
#elif [ $countsecond != 0 ]; then
	#php ~/rename.php 00
	#	echo "Adding secondary files to queue..."
	#	mv $(ls -1tr $SECOND/*.{mkv,mp4,avi} | grep -E '^[^d]' | head -1) ${QUEUE}; sleep 2
	#	echo "Process the queue..."
	#	nohup /root/encode.sh > /dev/null 2>&1 &
else
	echo "oyasumi..."
fi
