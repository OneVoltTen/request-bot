#!/bin/bash
. /root/config.sh

if [ ! -z ${CRC+x} ]; then echo "CRC set '$CRC'" >> $SORT/log.txt; FILEN="$SORT/$CRC"; Basename="${FILEN##*/}"; fi

# If file in subdirectory
echo "directory $FILEN" >> $SORT/log.txt
# Rename variable to remove illegal characters
FOLDER=${Basename//[^a-zA-Z_0-9]/_}
if [ -d "$FILEN" ]; then
	# Rename folder to remove illegal characters
	RENAME=${FOLDER/[^a-zA-Z_0-9]/_}
	mv "$FILEN" "$SORT/$RENAME"
	# Change working directory into folder
	cd "$SORT/$FOLDER"
	# If moved successfully into folder
	if [ ! $(pwd) == $SORT ]; then
		echo "match!"; echo "id["$MALID"] title["$TITLE"] fansub["$FANSUB"] filedir["$FILEN"]" >> $SORT/log.txt
		echo "Working directory" $(pwd) >> $SORT/log.txt
		# Move files into working directoryc
		mv **/*.mkv "$SORT/$FOLDER >> $SORT/log.txt";mv **/*.mp4 "$SORT/$FOLDER" >> $SORT/log.txt;mv **/*.avi "$SORT/$FOLDER" >> $SORT/log.txt
		mkdir -p "$TRASH/$MALID"
		for file in *.mp4; do
			# Change mp4 container
			if [[ $file == *"mp4" ]]; then
				echo "detect mp4" >> $SORT/log.txt
				ffmpeg -i $file -vcodec copy -acodec copy $file.mkv; sleep 1
				# Move file into trash/ID
				mkdir -p "$TRASH/$MALID"
				mv "$file" "$TRASH/$MALID" >> $SORT/log.txt
				# Update file to new file
				file="${file}.mkv"
				mv "$file" "${file//.mp4/}" >> $SORT/log.txt
				file=${file//.mp4/}
				echo "MKV ${file}" >> $SORT/log.txt
			fi
		done
		for file in *.mkv; do
			music=0
			# Move OP/ED files into trash folder
			# filen=$(sed 's/[^0-9A-Za-z_.]/ /g' <<< "$file")
			# mv "${file}" "$SORT/$FILEN1/${filen}"
			echo "${file,,}"
			arr=('creditless' 'ending' 'opening' ' ncop' ' nced' ' op1' ' op 1' ' op01' ' op 01' ' op2' ' op 2' ' op02' ' op 02' ' op3' ' op 3' ' op03' ' op 03' ' op4' ' op 4' ' op04' ' op 04' ' =op5' ' op 5' ' op05' ' op 05' ' op6' ' op 6' ' op06' ' op 06' ' op7' ' op 7' ' op07' ' op 07' ' op8' ' op 8' ' op08' ' op 08' ' op9' ' op 9' ' op09' ' op 09' ' op10' ' op 10' ' op10' ' op 10' ' op11' ' op 11' ' op11' ' op 11' ' ed1' ' ed 1' ' ed01' ' ed 01' ' ed2' ' ed 2' ' ed02' ' ed 02' ' ed3' ' ed 3' ' ed03' ' ed 03' ' ed4' ' ed 4' ' ed04' ' ed 04' ' ed5' ' ed 5' ' ed05' ' ed 05' ' ed6' ' ed 6' ' ed06' ' ed 06' ' ed7' ' ed 7' ' ed07' ' ed 07' ' ed8' ' ed 8' ' ed08' ' ed 08' ' ed9' ' ed 9' ' ed09' ' ed 09' ' ed10' ' ed 10' ' ed 10' ' ed11' ' ed 11' ' ed 11')
			for ((i = 0; i < ${#arr[@]}; i++)); do
				if [[ ${file,,} == *${arr[$i]}*  ]]; then
					echo "${file,,} - ${arr[$i]}"
					echo "[${MALID}] ${file,,} => ${arr[$i]}" >> $SORT/log-music.txt
					mv "$SORT/$FILEN1/${file}" "$TRASH/$MALID" >> $SORT/log-music.txt
				fi
			done
			if [[ $music == 0 ]]; then
				# Set file title metadata
				mkvpropedit "${file}" -e info -s title="${FTITLE}" >> $SORT/log.txt
				# Move to downloads folder
				FILE=${file//${SORT}//}
				mv "${file}" "${DOWNLOAD}/$MALID|$FANSUB|$FILE" >> $SORT/log.txt
			fi
		done
	else
		echo "working directory failed change > $SORT/$FOLDER" >> $SORT/log.txt
	fi
	sleep 1
	# Move folder into trash/ID
	mv $(pwd) "$TRASH/$MALID"
	nohup php /root/app/sorted.php $MALID >> $SORT/log-sorted.txt &
	nohup /root/bot.sh sort >/dev/null 2>&1 &
	#die "complete" >> $SORT/log.txt
else
	echo "file $FILEN" >> $SORT/log.txt
fi # dir not exist
