#!/bin/bash
. /root/app/config.sh

if [ ! -z ${CRC+x} ]; then echo "CRC set '$CRC'" >> ${LOG}/sort.log; FILEN="$SORT/$CRC"; Basename="${FILEN##*/}"; fi
# Change working directory into folder
cd "$FILEN"
# If moved successfully into folder
if [[ $(pwd) != $SORT ]]; then
	echo "match!"; echo "id["$MALID"] title["$TITLE"] fansub["$FANSUB"] filedir["$FILEN"]" >> ${LOG}/sort.log
	echo "directory $FILEN" >> ${LOG}/sort.log
	echo "metatitle $FTITLE" >> ${LOG}/sort.log
	FOLDER=${Basename//[^a-zA-Z_0-9]/_}
	RENAME=${FOLDER/[^a-zA-Z_0-9]/_}
	mv "$FILEN" "$SORT/$RENAME" >> ${LOG}/sort.log
	echo "Working directory" $(pwd) >> ${LOG}/sort.log
	mkdir -p "$TRASH/$MALID"
	# Move files into working directoryc
	mv **/*.mkv "$SORT/$FOLDER" 2>/dev/null >> ${LOG}/sort.log
	mv **/*.mp4 "$SORT/$FOLDER" 2>/dev/null >> ${LOG}/sort.log
	mv **/*.avi "$SORT/$FOLDER" 2>/dev/null >> ${LOG}/sort.log

	sleep 5 # wait for file move complete

	for file in *.{"avi","mp4","mkv"}; do
		if [[ ! -f $file ]]; then
			continue
		fi
		music=0
		# Move files with filter word to trash
		file_lower=${file,,}
		echo "${file_lower}" >> ${LOG}/sort.log
		arr=('creditless' 'ending' 'opening' 'ncop' 'nced' 'op1' 'op 1' 'op01' 'op 01' 'op2' 'op 2' 'op02' 'op 02' 'op3' 'op 3' 'op03' 'op 03' 'op4' 'op 4' 'op04' 'op 04' ' op5' 'op 5' 'op05' 'op 05' 'op6' 'op 6' 'op06' 'op 06' 'op7' 'op 7' 'op07' 'op 07' 'op8' 'op 8' 'op08' 'op 08' 'op9' 'op 9' 'op09' 'op 09' 'op10' 'op 10' 'op10' 'op 10' 'op11' 'op 11' 'op11' 'op 11' 'ed1' 'ed 1' 'ed01' 'ed 01' 'ed2' 'ed 2' 'ed02' 'ed 02' 'ed3' 'ed 3' 'ed03' 'ed 03' 'ed4' 'ed 4' 'ed04' 'ed 04' 'ed5' 'ed 5' 'ed05' 'ed 05' 'ed6' 'ed 6' 'ed06' 'ed 06' 'ed7' 'ed 7' 'ed07' 'ed 07' 'ed8' 'ed 8' 'ed08' 'ed 08' 'ed9' 'ed 9' 'ed09' 'ed 09' 'ed10' 'ed 10' 'ed 10' 'ed11' 'ed 11' 'ed 11')
		for ((i = 0; i < ${#arr[@]}; i++)); do
			if [[ "${file_lower// /_}" == *"_${arr[$i]// /_}"* ]]; then
				echo "[${MALID}] ${file_lower,,} - ${arr[$i]}" >> ${LOG}/sort_filter.log
				mv "${file}" "$TRASH/$MALID" >> ${LOG}/sort_filter.log
				music=1
				echo "music match" >> ${LOG}/sort_filter.log
			else
				echo "no match "${file// /_}" == *_"${arr[$i]// /_}"*" >> ${LOG}/sort_filter.log
			fi
		done
		
		if [[ $music == 0 ]]; then
			if [[ "$file" == *"mp4" ||  "$file" == *"avi" ]]; then
				echo "filename $file" >> ${LOG}/sort.log
				if [[ "$file" == *"mp4" ]]; then
					ffmpeg -i "$file" -vcodec copy -acodec copy "$file.mkv" >> ${LOG}/sort.log
				elif [[ "$file" == *"avi" ]]; then
					ffmpeg -fflags +genpts -i "$file" -vcodec copy -acodec copy "$file.mkv" >> ${LOG}/sort.log
				fi
				mkdir -p "$TRASH/$MALID"
				mv "$file" "$TRASH/$MALID" >> ${LOG}/sort.log
				file="$file.mkv" >> ${LOG}/sort.log
				mv "${file}" "${file//.mp4/}" >> ${LOG}/sort.log
				mv "${file}" "${file//.avi/}" >> ${LOG}/sort.log
				file="${file//.mp4/}"
				file="${file//.avi/}"
				echo "converted ${file}" >> ${LOG}/sort.log
			fi
			
			# Set file title metadata
			mkvpropedit "${file}" -e info -s title="${FTITLE}" >> ${LOG}/sort.log
			# Move to downloads folder
			FILE="${file//${SORT}//}"
			mv "${file}" "${DOWNLOAD}/$MALID|${FANSUB}|${FILE}" >> ${LOG}/sort.log
		fi
		
	done
	# Move folder into trash/ID
	mv "$SORT/$FOLDER" "$TRASH/$MALID"
else
	echo "working directory failed change > $SORT/$FOLDER" >> ${LOG}/sort.log
fi

unset FILE;unset file;unset music;unset CRC;unset FILEN;unset Basename;unset SORT;unset MALID;unset TITLE;unset FANSUB;unset FILEN;unset FOLDER;

nohup php /root/sort/sorted.php "$MALID" >> ${LOG}/sorted.log &
#die "complete" >> ${LOG}/sort.log
