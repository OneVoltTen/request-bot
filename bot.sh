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

if [[ $countsource != 0 ]]; then
	if [ $countqueue == 0 ]; then
		echo "execute rename..."; mv ${SOURCE}/*.mkv ${QUEUE}; sleep 1
		if pidof -s ffmpeg > /dev/null; then
			echo 'ffmpeg running...'
		else
			echo "execute encode..."; nohup /root/encode.sh > /dev/null 2>&1 &
		fi
	else
		echo "queue contain files..."
	fi
elif pidof -s ffmpeg > /dev/null; then
	echo 'ffmpeg running...'
else
	echo "sabishī yo..."
fi
