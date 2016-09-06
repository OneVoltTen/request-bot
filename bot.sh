#!/bin/bash

cd /root
SOURCE="/var/www/downloads"
SECOND="/var/www/downloads/.00"
QUEUE="/var/www/downloads/.queue"
ENCODED="/var/www/encoded"
countqueue=`ls -1 $QUEUE/*.{mkv,mp4,ass} 2>/dev/null | wc -l`
countencoded=`ls -1 $ENCODED/*.mp4 2>/dev/null | wc -l`
countsource=`ls -1 $SOURCE/*{mkv,mp4,ass} 2>/dev/null | wc -l`
countsecond=`ls -1 $SECOND/*.{mkv,mp4,avi} 2>/dev/null | wc -l`

if [[ -z "$1" && "$1"=="sort" ]]; then
	echo "execute retieve worker..."
	nohup /root/retrieve.sh > /dev/null 2>&1 &
fi

if [ $countencoded != 0 ]; then
	echo "execute upload worker..."
	nohup php /root/NodefilesUploader.php > /dev/null 2>&1 &
fi

php /root/renameu.php
php /root/rename.php downloads
#php ~/rename.php 00

if [ $countqueue != 0 ]; then
	echo "queue not empty..."
elif [ $countqueue == 0 ]; then
	if [ $countsource != 0 ]; then
		echo "execute rename..."
		mv ${SOURCE}/*.mkv ${QUEUE}; sleep 2
		echo "execute encode..."
		nohup /root/encode.sh > /dev/null 2>&1 &
	#elif [ $countsecond != 0 ]; then
	#	echo "Adding secondary files to queue..."
	#	mv $(ls -1tr $SECOND/*.{mkv,mp4,avi} | grep -E '^[^d]' | head -1) ${QUEUE}; sleep 2
	#	echo "Process the queue..."
	#	nohup /root/encode.sh > /dev/null 2>&1 &
	else
		echo "oyasumi..."
	fi
else
	echo "isogashii desu..."
fi
