#!/bin/bash
. /root/config.sh
cd ${SORT}
LAST=""
#TR_TORRENT_DIR="${SORT}"
#TR_TORRENT_NAME="Bleach"
TR_DOWNLOADS="${SORT}/$TR_TORRENT_NAME"; echo "TR_DOWNLOADS > $TR_DOWNLOADS" >> $SORT/log.txt
# Function die with message
die() { echo "$@" 1>&2 ; exit 1; }
# Update downloading.txt if any changes
# If downloading.txt being updated
if [ ! -f '${WWW}/downloading.txt' ]; then
	sleep 5
fi
echo 'retrieve...' >> $SORT/log.txt; /root/app/retrieve.sh; sleep 1
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
						file=${Basename}
						. ${INSTALL}/app/sortm.sh
						# Set file title metadata
						mkvpropedit "$file" -e info -s title="$FTITLE" >> $SORT/log.txt
						# Move to downloads folder
						filen=${file//"${SORT}"/}
						echo $file $FANSUB $MALID
						sleep 1
						mv "${SORT}/${filen}" "${DOWNLOAD}/$MALID|$FANSUB|$filen"
						nohup ${INSTALL}/bot.sh sort  > /dev/null 2>&1 &
						php ${INSTALL}/app/sorted.php $MALID >> ${INSTALL}/log.txt
						nohup ${INSTALL}/sort.sh >> $SORT/log.txt &
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
						# Move files into working directoryc
						mv **/*.mkv "$SORT/$FILEN1";mv **/*.mp4 "$SORT/$FILEN1";mv **/*.avi "$SORT/$FILEN1"
						mkdir -p "$TRASH/$MALID"
						echo $(pwd)		
						for file in *.{mp4,avi,mkv}; do
							. ${INSTALL}/app/sortm.sh
						done
						for file in *.mkv; do
							# Move OP/ED files into trash folder
							filen=$(sed 's/[^0-9A-Za-z_.]/ /g' <<< "$filen")
							arr=('creditless' 'ending' 'opening' 'ncop' 'nced'
								'_op1' '_op_1' '_op01' '_op_01'
								'_op2' '_op_2' '_op02' '_op_02'
								'_op3' '_op_3' '_op03' '_op_03'
								'_op4' '_op_4' '_op04' '_op_04'
								'_op5' '_op_5' '_op05' '_op_05'
								'_op6' '_op_6' '_op06' '_op_06'
								'_op7' '_op_7' '_op07' '_op_07'
								'_op8' '_op_8' '_op08' '_op_08'
								'_op9' '_op_9' '_op09' '_op_09'
								'_ed1' '_ed_1' '_ed01' '_ed_01'
								'_ed2' '_ed_2' '_ed02' '_ed_02'
								'_ed3' '_ed_3' '_ed03' '_ed_03'
								'_ed4' '_ed_4' '_ed04' '_ed_04'
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
							mkvpropedit "${file}" -e info -s title="${FTITLE}" >> $SORT/log.txt
							# Move to downloads folder
							FILE=${file//${SORT}//}
							mv "${file}" "${DOWNLOAD}/$MALID|$FANSUB|$FILE" >> $SORT/log.txt
						done
					else
						echo "working directory failed change > $SORT/$FILEN1" >> $SORT/log.txt
					fi
					sleep 2
					# Move folder into trash/ID
					mv "$SORT/$FILEN1" "$TRASH/$MALID"
					nohup ${INSTALL}/bot.sh sort >/dev/null 2>&1 &
					php ${INSTALL}/app/sorted.php $MALID >> ${INSTALL}/log.txt
					die "complete" >> $SORT/log.txt
				else
					echo "file $FILEN" >> $SORT/log.txt
				fi # dir not exist
			fi # files
		fi # :
	else
		echo "dupe line" >> $SORT/log.txt
	fi # LAST
done < ${WWW}/downloading.txt
echo "failed" >> $SORT/log.txt
