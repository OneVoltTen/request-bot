#!/bin/bash
cd /var/www/sort; SORT="/var/www/sort"; DOWNLOAD="/var/www/downloads"; TRASH="/var/www/trash"; LAST=""
#TR_TORRENT_DIR="/var/www/sort"
#TR_TORRENT_NAME="SampleVideo_1280x720_2mb.mp4"
TR_DOWNLOADS="/var/www/sort/$TR_TORRENT_NAME"; echo "TR_DOWNLOADS > $TR_DOWNLOADS" >> $SORT/log.txt
# Function die with message
die() { echo "$@" 1>&2 ; exit 1; }
# Update downloading.txt if any changes
# If downloading.txt being updated
if [ ! -f '/var/www/downloading.txt' ]; then
	sleep 5
fi
#echo 'retrieve...' >> $SORT/log.txt; /root/app/retrieve.sh; sleep 1
# Read each line in downloading.txt
echo 'read downloading.txt' >> $SORT/log.txt
while read line; do
	if [[ ! $LAST == $line ]]; then
		LAST=${line}
		# Get meta between colon
		FILEN=${line%:*:*:*:*:*}; Basename="${FILEN##*/}"; echo $line >> $SORT/log.txt; MALID=${line#*:*:*:*:*:}; VALUES=${line#*:}; TITLE=${VALUES%:*:*:*:*}; FANSUB1=${VALUES%:*:*:*}; FANSUB=${FANSUB1#*:}; NEXT1=${VALUES%:*}; NEXT=${NEXT1#*:*:}; AUDIO=${NEXT%:*}; SUB=${NEXT#*:}
		# File meta title
		FTITLE="$MALID|$TITLE|$FANSUB|$AUDIO|$SUB"; echo Filetitle $FTITLE >> $SORT/log.txt
		# Verify meta colon count
		colon_count=$(grep -o ":" <<< "$line" | wc -l)
		if [[ ! $colon_count == 5 ]]; then
			declare -a arr=($MALID $TITLE $FANSUB $AUDIO $SUB);	echo "> invalid colon count! $colon_count" >> $SORT/log.txt
			for i in "${arr[@]}"; do
				if [[ $i == *":"* ]]; then
					echo "> $i: [$i]" >> $SORT/log.txt
				fi
			done
			die "invalid colon ${line}" >> $SORT/log.txt
		else
			# If file in working directory
			if [[ $TR_TORRENT_NAME == *".mkv" ]] || [[ $TR_TORRENT_NAME == *".mp4" ]] || [[ $TR_TORRENT_NAME == *".avi" ]] || [[ $Basename == *".mkv" ]] || [[ $Basename == *".mp4" ]] || [[ $Basename == *".avi" ]]; then
				echo "file $FILEN" >> $SORT/log.txt
				if [[ -f $FILEN ]]; then
					echo "match!"; echo "match!" >> $SORT/log.txt; echo "$FILEN"; echo "id["$MALID"] title["$TITLE"] fansub["$FANSUB"] file["$FILEN"]" >> $SORT/log.txt
					#mediainfo --fullscan "$FILEN"
					if [[ $TR_TORRENT_NAME == *".mkv" ]] || [[ $TR_TORRENT_NAME == *".mp4" ]]  || [[ $TR_TORRENT_NAME == *".avi" ]] || [[ $Basename == *".mkv" ]] || [[ $Basename == *".mp4" ]] || [[ $Basename == *".avi" ]]; then
						# Remove pipe if exist
						if [[ $file == *"|"* ]]; then
							mv "${FILEN}" "${FILEN/|/}"; file=${file//|/}
						fi
						# Change mp4 container
						if [[ $FILEN == *"mp4" ]]; then
							echo "detect mp4" >> $SORT/log.txt
							ffmpeg -i $FILEN -vcodec copy -acodec copy $FILEN.mkv; sleep 1
							# Move file into trash/ID
							mkdir -p "$TRASH/$MALID"
							mv "$FILEN" "$TRASH/$MALID" >> $SORT/log.txt
							# Update filen to new file
							FILEN="${FILEN}.mkv"
							mv "$FILEN" "${FILEN//.mp4/}" >> $SORT/log.txt
							FILEN=${FILEN//.mp4/}
							echo "MKV " $FILEN >> $SORT/log.txt
						fi
						# Change avi container
						if [[ $FILEN == *"avi" ]]; then
							echo "detect avi" >> $SORT/log.txt
							ffmpeg -i $FILEN -vcodec copy -acodec copy $FILEN.mkv; sleep 1
							# Move file into trash/ID
							mkdir -p "$TRASH/$MALID"
							mv "$FILEN" "$TRASH/$MALID" >> $SORT/log.txt
							# Update filen to new file
							FILEN="${FILEN}.mkv"
							mv "$FILEN" "${FILEN//.avi/}" >> $SORT/log.txt
							FILEN=${FILEN//.avi/}
							echo "MKV " $FILEN >> $SORT/log.txt
						fi
						# Set file title metadata
						mkvpropedit "$FILEN" -e info -s title="$FTITLE" >> $SORT/log.txt
						# Move to downloads folder
						filen=${FILEN//"/var/www/sort/"/}
						echo $filen
						echo $FANSUB
						echo $MALID
						mv "$FILEN" "${DOWNLOAD}/$MALID|$FANSUB|$filen"
						nohup /root/bot.sh sort  >/dev/null 2>&1 &
						die "complete" >> $SORT/log.txt
					fi
				else
					echo 'no match' >> $SORT/log.txt
				fi
			sleep 2
			else
				# If file in subdirectory
				echo "directory" >> $SORT/log.txt
				echo $Basename >> $SORT/log.txt
				# Rename variable to remove illegal characters
				FILEN1=${Basename//[^a-zA-Z_0-9]/_}
				if [ -d "$FILEN" ]; then
					# Rename folder to remove illegal characters
					RENAME=${FILEN1/[^a-zA-Z_0-9]/_}
					mv "$FILEN" "$SORT/$RENAME"
					# Change working directory into folder
					cd "$SORT/$FILEN1"
					# If moved successfully into folder
					if [ ! $(pwd) == $SORT ]; then
						echo "match!"; echo "id["$MALID"] title["$TITLE"] fansub["$FANSUB"] file["$FILEN"]" >> $SORT/log.txt
						echo "Working directory" $(pwd) >> $SORT/log.txt
						# Move files into working directory [Max 1 subfolder]
						mv ***/*.mkv "$SORT/$FILEN1";
						mv ***/*.mp4 "$SORT/$FILEN1";
						mv ***/*.avi "$SORT/$FILEN1";
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
								echo "MKV " $file >> $SORT/log.txt
							fi
						done
						for file in *.avi; do
							# Change avi container
							if [[ $file == *"avi" ]]; then
								echo "detect avi" >> $SORT/log.txt
								ffmpeg -i $file -vcodec copy -acodec copy $file.mkv; sleep 1
								# Move file into trash/ID
								mkdir -p "$TRASH/$MALID"
								mv "$file" "$TRASH/$MALID" >> $SORT/log.txt
								# Update file to new file
								file="${file}.mkv"
								mv "$file" "${file//.avi/}" >> $SORT/log.txt
								file=${file//.avi/}
								echo "MKV " $file >> $SORT/log.txt
							fi
						done
						for file in *.mkv; do
							# Rename file to remove pipe
							if [[ $file == *"|"* ]]; then
								mv "${file}" "${file/|/}"; file=${file//|/};
							fi
							# Move OP/ED files into trash folder
							arr=(	'creditless' 'ending' 'opening' 'ncop' 'nced'
									' op1' ' op 1' ' op01' ' op 01'
									' op2' ' op 2' ' op02' ' op 02'
									' op3' ' op 3' ' op03' ' op 03'
									' op4' ' op 4' ' op04' ' op 04'
									' op5' ' op 5' ' op05' ' op 05'
									' op6' ' op 6' ' op06' ' op 06'
									' op7' ' op 7' ' op07' ' op 07'
									' op8' ' op 8' ' op08' ' op 08'
									' ed1' ' ed 1' ' ed01' ' ed 01'
									' ed2' ' ed 2' ' ed02' ' ed 02'
									' ed3' ' ed 3' ' ed03' ' ed 03'
									' ed4' ' ed 4' ' ed04' ' ed 04'
									' ed5' ' ed 5' ' ed05' ' ed 05'
									' ed6' ' ed 6' ' ed06' ' ed 06'
									' ed7' ' ed 7' ' ed07' ' ed 07'
									' ed8' ' ed 8' ' ed08' ' ed 08'
									' ed9' ' ed 9' ' ed09' ' ed 09'
									'_op1' '_op 1' '_op01' '_op_01'
									'_op2' '_op_2' '_op02' '_op_02'
									'_op3' '_op_3' '_op03' '_op_03'
									'_op4' '_op_4' '_op04' '_op_04'
									'_op5' '_op_5' '_op05' '_op_05'
									'_op6' '_op_6' '_op06' '_op_06'
									'_op7' '_op_7' '_op07' '_op_07'
									'_op8' '_op_8' '_op08' '_op_08'
									'_ed1' '_ed_1' '_ed01' '_ed_01'
									'_ed2' '_ed_2' '_ed02' '_ed_02'
									'_ed3' '_ed_3' '_ed03' '_ed_03'
									'_ed4' '_ed 4' '_ed_4' '_ed_04'
									'_ed5' '_ed_5' '_ed05' '_ed_05'
									'_ed6' '_ed_6' '_ed06' '_ed_06'
									'_ed7' '_ed_7' '_ed07' '_ed_07'
									'_ed8' '_ed_8' '_ed08' '_ed_08' 
									'_ed9' '_ed_9' '_ed09' '_ed_09')
							for ((i = 0; i < ${#arr[@]}; i++)); do
								#echo "${file,,} - ${arr[$i]}"
								if [[ ${file,,} == *${arr[$i]}*  ]]; then
									echo "[${MALID}] ${file,,} => ${arr[$i]}" >> $SORT/log-music.txt
									# Move to trash folder
									mv "${file}" "$TRASH/$MALID" >> $SORT/log-music.txt
								fi
							done
							# Set file title metadata
							mkvpropedit "$file" -e info -s title="$FTITLE" >> $SORT/log.txt
							# Move to downloads folder
							FILE=${file///var/www/sort//}
							mv "${file}" "${DOWNLOAD}/$MALID|$FANSUB|$FILE" >> $SORT/log.txt
						done
					else
						echo "working directory failed change > $SORT/$FILEN1" >> $SORT/log.txt
					fi
					sleep 2
					# Move folder into trash/ID
					mv "$SORT/$FILEN1" "$TRASH/$MALID"
					nohup /root/bot.sh sort >/dev/null 2>&1 &
					die "complete" >> $SORT/log.txt
				else
					echo "file $FILEN" >> $SORT/log.txt
				fi # dir not exist
			fi # files
		fi # :
	else
		echo "dupe line" >> $SORT/log.txt
	fi # LAST
done <../downloading.txt
echo "failed" >> $SORT/log.txt
