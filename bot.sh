#!/bin/bash
cd /root
SOURCE="/var/www/downloads"; SECOND="/var/www/downloads/.00"; QUEUE="/var/www/downloads/.queue"; ENCODED="/var/www/encoded"; countqueue=`ls -1 $QUEUE/*.{mkv,mp4,ass} 2>/dev/null | wc -l`
countencoded=`ls -1 $ENCODED/*.mp4 2>/dev/null | wc -l`; countsource=`ls -1 $SOURCE/*{mkv,mp4,ass} 2>/dev/null | wc -l`; countsecond=`ls -1 $SECOND/*.{mkv,mp4,avi} 2>/dev/null | wc -l`; lastlog=`tail -1 /root/log.txt | head -1`;

if [[ -z "$1" && "$1"=="sort" ]]; then
	echo "execute retieve worker..."; nohup /root/app/retrieve.sh keep >/dev/null 2>&1 &
fi
if [ $countencoded != 0 ]; then
	echo "execute upload worker..." >> /root/log.txt >> /root/log.txt;nohup php /root/NodefilesUploader.php >> /root/log.txt &
fi

php /root/rename.php downloads  >> /root/log.txt; sleep 1

if [[ $countsource != 0 ]]; then
	if [ $countqueue == 0 ]; then
		echo "execute rename..." >> /root/log.txt; mv ${SOURCE}/*.mkv ${QUEUE}; sleep 1
		if pidof -s ffmpeg > /dev/null; then
			if [[ ! $lastlog == "ffmpeg running..." ]]; then
				echo "ffmpeg running..." >> /root/log.txt
			fi
		else
			echo "execute encode..." >> /root/log.txt; nohup /root/encode.sh >> /root/log.txt &
		fi
	else
		if [[ ! $lastlog == "queue contain files..." ]]; then
			echo "queue contain files..." >> /root/log.txt
		fi
	fi
elif pidof -s ffmpeg > /dev/null; then
	if [[ ! $lastlog == "ffmpeg running..." ]]; then
		echo "ffmpeg running..." >> /root/log.txt
	fi
elif [[ $countqueue != 0 ]]; then
	sleep 15
	if pidof -s ffmpeg > /dev/null; then
		echo "ffmpeg running..."
	else
		if [[ ! $lastlog == "queue contain files..." ]]; then
			echo "queue contain files..." >> /root/log.txt
		fi
	fi
else
	if [[ ! $lastlog == "sabishī yo..." ]]; then
		echo "sabishī yo..." >> /root/log.txt
	fi
fi
