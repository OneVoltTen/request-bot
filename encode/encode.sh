. /root/app/config.sh

LOCKFILE=/tmp/lockencode.txt # create lockfile with process id
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "encode.sh already running" >> ${LOG}/main.log
    exit
else
	echo $$ > ${LOCKFILE} # set process id into lockfile
	trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
fi

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
		echo "FFMPEG complete" >> ${LOG}/main.log
		echo "log rename => progress_$(date +%F_%H-%M).txt"
		mv ${LOG}/encode/progress.log ${LOG}/encode/progress_$(date +%F_%H-%M).log
		# Remove temp subtitle file after processing
		rm -rf ${INSTALL}/.fonts/*

		allowarr=('666') # add filename id to move to upload folder
		if [[ "${allowarr[@]}" =~ "$animeid" ]]; then
			echo "move to upload..." >> ${LOG}/main.log &
			mv "${i}_encoded.mp4" "$UPLOAD" -f >> ${LOG}/main.log &
			nohup php ${INSTALL}/rename/rename.php upload >> ${LOG}/main.log &
		else
			echo "move to verify..." >> ${LOG}/main.log &
			mv "${i}_encoded.mp4" $VERIFY -f >> ${LOG}/main.log &
			nohup php ${INSTALL}/rename/rename.php verify >> ${LOG}/main.log &
		fi
		# trash
		if [[ ${FILENAMEX%${GROUP}*} > 0 ]]; then
			echo "move to trash..."; mkdir -p "${TRASH}/${FILENAMEX%${GROUP}*}"; mv $i "${TRASH}/${FILENAMEX%${GROUP}*}" -f
		else
			echo "no id set"; echo "move to trash..."; mv $i ${TRASH} -f
		fi
		nohup php ${INSTALL}/rename/rename.php verify &
		unset i;unset filename;unset animeid;unset metaa;unset meta;unset audio;unset FILENAMEX;unset FILENAMEXX;unset Basename;unset ext;
	fi
done
# Remove temp file
rm -rf $QUEUE/*.{OTF,TTF,TTC,FON,FNT,PFB,DFONT,ASS,SRT,PGS,SUP,SUB,IDX,JPG,PNG,GIF,BMP,Otf,Ttf,Ttc,Fon,Fnt,Pfb,Dfont,Ass,Srt,Pgs,Sup,Sub,Idx,Jpg,Png,Gif,Bmp,otf,ttf,ttc,fon,fnt,pfb,dfont,ass,srt,pgs,sup,sub,idx,jpg,png,gif,bmp} ${INSTALL}/.fonts/*.{OTF,TTF,TTC,FON,FNT,PFB,DFONT,Otf,Ttf,Ttc,Fon,Fnt,Pfb,Dfont,otf,ttf,ttc,fon,fnt,pfb,dfont}

seconds=`date +%S`
if [[ $seconds -gt "52" ]]; then
	echo ">" $seconds "no bot.sh"
else
	echo "execute"
	nohup ${INSTALL}/bot.sh >> ${LOG}/main.log &
fi

rm -f ${LOCKFILE}
