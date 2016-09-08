#!/bin/bash
cd /root
SOURCE="/var/www/downloads"; SECOND="/var/www/downloads/.00"; QUEUE="/var/www/downloads/.queue"; ENCODED="/var/www/encoded"; countqueue=`ls -1 $QUEUE/*.{mkv,mp4,ass} 2>/dev/null | wc -l`
countencoded=`ls -1 $ENCODED/*.mp4 2>/dev/null | wc -l`; countsource=`ls -1 $SOURCE/*{mkv,mp4,ass} 2>/dev/null | wc -l`; countsecond=`ls -1 $SECOND/*.{mkv,mp4,avi} 2>/dev/null | wc -l`

if [[ -z "$1" && "$1"=="sort" ]]; then
	echo "execute retieve worker..."; nohup /root/retrieve.sh keep > /dev/null 2>&1 &
fi
if [ $countencoded != 0 ]; then
	echo "execute upload worker..."; nohup php /root/NodefilesUploader.php > /dev/null 2>&1 &
fi

php /root/rename.php
php /root/rename.php downloads
sleep 1

PROCESS_DT=$(ps -C ffmpeg -o ruser=)
if [[ $countsource != 0 && ! $PROCESS_DT == "ffmpeg" ]]; then
	if [ $countqueue == 0 ]; then
		echo "execute rename..."; mv ${SOURCE}/*.mkv ${QUEUE}; sleep 1
		if [[ ! $PROCESS_DT == "ffmpeg" ]]; then
			echo "execute encode..."; nohup /root/encode.sh > /dev/null 2>&1 &
			#sleep 10; If count ffmpeg > 1 kill
		else
			echo "nope."
		fi
	else
		echo "nope..."
	fi
else
	echo "isogashii desu..."
fi
