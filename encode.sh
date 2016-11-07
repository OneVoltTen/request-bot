. /root/config.sh

for i in `ls -tr $QUEUE/*.mkv`;do
	# Retrieve file
	for i in `ls -tr $QUEUE/*.mkv | sort -rh`; do
		FILENAMEX=${i#*${QUEUE}/}
	done
	if [ -f $i ]; then
		filename=${i#${QUEUE}/*}
		animeid=${filename%AnimePahe*}
		#echo $animeid
		. ${INSTALL}/encode/titlemeta.sh
		. ${INSTALL}/encode/resize.sh
		. ${INSTALL}/encode/fonts.sh
		. ${INSTALL}/encode/ffmpeg.sh
		echo "FFMPEG complete" >> ${INSTALL}/log.txt
		echo "log rename => progress_$(date +%F_%H-%M).txt"
		mv ${LOG}/progress.txt ${LOG}/progress_$(date +%F_%H-%M).txt
		# Remove temp subtitle file after processing
		rm -rf ${INSTALL}/.fonts/*
		echo "move to verify folder..."
		mv ${i}_encoded.mp4 ${VERIFY} -f
		# trash
		if [[ ${FILENAMEX%${GROUP}*} > 0 ]]; then
			echo "move to trash..."; mkdir -p "${TRASH}/${FILENAMEX%${GROUP}*}"; mv $i "${TRASH}/${FILENAMEX%${GROUP}*}" -f
		else
			echo "no id set"; echo "move to trash..."; mv $i ${TRASH} -f
		fi
		unset i;unset filename;unset animeid;unset metaa;unset meta;unset audio;unset FILENAMEX;unset FILENAMEXX;unset Basename;unset ext;unset count
	fi
done
# Remove temp file
rm -rf $QUEUE/*.{OTF,TTF,TTC,FON,FNT,PFB,DFONT,ASS,SRT,PGS,SUP,SUB,IDX,JPG,PNG,GIF,BMP,Otf,Ttf,Ttc,Fon,Fnt,Pfb,Dfont,Ass,Srt,Pgs,Sup,Sub,Idx,Jpg,Png,Gif,Bmp,otf,ttf,ttc,fon,fnt,pfb,dfont,ass,srt,pgs,sup,sub,idx,jpg,png,gif,bmp} ${INSTALL}/.fonts/*.{OTF,TTF,TTC,FON,FNT,PFB,DFONT,Otf,Ttf,Ttc,Fon,Fnt,Pfb,Dfont,otf,ttf,ttc,fon,fnt,pfb,dfont}

seconds=`date +%S`
if [[ $seconds -gt "52" ]]; then
	echo ">" $seconds "no bot.sh"
else
	echo "execute bot.sh"; nohup ${INSTALL}/bot.sh sort >> ${INSTALL}/log.txt &
fi
