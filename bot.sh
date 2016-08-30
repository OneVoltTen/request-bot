#!/bin/bash

cd /root
SOURCE="/var/www/downloads"
QUEUE="/var/www/downloads/.queue"
SECOND="/var/www/downloads/.00"
countqueue=`ls -1 $QUEUE/*.{mkv,mp4,ass} 2>/dev/null | wc -l`
countsource=`ls -1 $SOURCE/*.mkv 2>/dev/null | wc -l`
countsecond=`ls -1 $SECOND/*.{mkv,mp4,avi} 2>/dev/null | wc -l`
Noret=""

noret(){
	echo "$1";
	return $1;
	}
if [[ -z "$1" && "$1"=="sort" ]];then
	Noret="1"
fi

php /root/renameu.php
php /root/rename.php downloads
#php ~/rename.php 00

if [ $countqueue != 0 ]; then
	echo "encode not empty..."
	if [ -z "$1" ];then
		/root/retrieve.sh
	fi
elif [ $countqueue == 0 ]; then
	echo "encode empty..."
	if [ -z "$1" ];then
		/root/retrieve.sh
	fi
fi
if [ $countqueue == 0 ]; then
	if [ $countsource != 0 ]; then
		echo "renaming files..."
		mv ${SOURCE}/*.mkv ${QUEUE}; sleep 2
		echo "process queue..."
		nohup /root/encode.sh &
	#elif [ $countsecond != 0 ]; then
	#	echo "Adding secondary files to queue..."
	#	mv $(ls -1tr $SECOND/*.{mkv,mp4,avi} | grep -E '^[^d]' | head -1) ${QUEUE}; sleep 2
	#	echo "Process the queue..."
	#	nohup /root/encode.sh &
	fi
else
echo "isogashii desu...";
fi
