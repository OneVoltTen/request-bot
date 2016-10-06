#!/bin/bash
. /root/config.sh
FILENAMEX=""
die() { echo "$@" 1>&2 ; exit 1; }
# Retrieve file
for i in `ls -tr ${DOWNLOAD}/.queue/*.mkv | sort -rh`; do
	FILENAMEX=${i#*${QUEUE}/}
done
# Retrieve file meta
. ${INSTALL}/encode/titlemeta.sh

for i in `ls -tr $QUEUE/*.mkv`;do
	if [ -f $i ]; then
		if [ $i == *"_encoded"* ]; then
			echo "remove encoded file ${i}"
			mv ${i} ${TRASH} -f
		fi
		filename=${i#${QUEUE}/*}
		. ${INSTALL}/encode/resize.sh
		. ${INSTALL}/encode/fonts.sh
		. ${INSTALL}/encode/ffmpeg.sh
		echo "FFMPEG complete" >> ${INSTALL}/log.txt
		echo "log rename => progress_$(date +%F_%H-%M).txt"
		mv ${LOG}/progress.txt ${LOG}/progress_$(date +%F_%H-%M).txt
		# Remove temp subtitle file after processing
		rm -rf ${INSTALL}/.fonts/*
		echo "move to encoded folder..."
		mv ${i}_encoded.mp4 ${ENCODED} -f
		# If file moved to encoded folder
		count=`ls -1 $ENCODED/*_encoded.mp4 2>/dev/null | wc -l`
		# If file not moved to encode folder
		if [[ ${FILENAMEX%${GROUP}*} > 0 ]];then
			echo "move to trash..."; mkdir -p "${TRASH}/${FILENAMEX%${GROUP}*}"; mv $i "${TRASH}/${FILENAMEX%${GROUP}*}" -f
		else
			echo "no id set"; echo "move to trash..."; mv $i ${TRASH} -f
		fi
	fi
done
# Remove temp file
sleep 1; echo "remove temp file..."; rm -rf $QUEUE/*.{OTF,TTF,TTC,FON,FNT,PFB,DFONT,ASS,SRT,PGS,SUP,SUB,IDX,JPG,PNG,GIF,BMP,Otf,Ttf,Ttc,Fon,Fnt,Pfb,Dfont,Ass,Srt,Pgs,Sup,Sub,Idx,Jpg,Png,Gif,Bmp,otf,ttf,ttc,fon,fnt,pfb,dfont,ass,srt,pgs,sup,sub,idx,jpg,png,gif,bmp} ${INSTALL}/.fonts/*.{OTF,TTF,TTC,FON,FNT,PFB,DFONT,Otf,Ttf,Ttc,Fon,Fnt,Pfb,Dfont,otf,ttf,ttc,fon,fnt,pfb,dfont}

seconds=`date +%S`
if [[ $seconds -gt "52" ]]; then
	echo ">" $seconds "no bot.sh"
else
	echo "execute bot.sh"; nohup ${INSTALL}/bot.sh sort >> ${INSTALL}/log.txt &
fi
