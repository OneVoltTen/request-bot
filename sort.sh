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
				FOLDER=${Basename//[^a-zA-Z_0-9]/_}
				if [ -d "$FILEN" ]; then
					# Rename folder to remove illegal characters
					RENAME=${FOLDER/[^a-zA-Z_0-9]/_}
					mv "$FILEN" "$SORT/$RENAME"
					# Change working directory into folder
					cd "$SORT/$FOLDER"
					# If moved successfully into folder
					if [ ! $(pwd) == $SORT ]; then
						echo "match!"; echo "id["$MALID"] title["$TITLE"] fansub["$FANSUB"] file["$FILEN"]" >> $SORT/log.txt
						echo "Working directory" $(pwd) >> $SORT/log.txt
						# Move files into working directoryc
						mv **/*.mkv "$SORT/$FOLDER";mv **/*.mp4 "$SORT/$FOLDER";mv **/*.avi "$SORT/$FOLDER"
						mkdir -p "$TRASH/$MALID"
						echo $(pwd)		
						for file in *.{mp4,avi,mkv}; do
							. ${INSTALL}/app/sortm.sh
						done
						for file in *.mkv; do
							music=0
							# Move OP/ED files into trash folder
							filen=$(sed 's/[^0-9A-Za-z_.]/ /g' <<< "$filen")
							arr=('creditless' 'ending' 'opening' 'ncop' 'nced' '1' '2' '3' '4'	'5' '6' '7' '8'	'9' '10')
							for ((i = 0; i < ${#arr[@]}; i++)); do
								#echo "${file,,} - ${arr[$i]}"
								number='^[0-9]+$'
								if [[ ${arr[$i]} =~ $number ]]; then
									oped=('_op' '_op0' '_op_' '_op_0' '_ed' '_ed0' '_ed_' '_ed_0')
									for ((ii = 0; ii < ${#oped[@]}; ii++)); do
									   . ${INSTALL}/app/music.sh "${oped[$ii]}${arr[$i]}"
									done
								else
									. ${INSTALL}/app/music.sh ${arr[$i]}
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
					rm -rf "$TRASH/$MALID/$FOLDER"
					mv "$SORT/$FOLDER" "$TRASH/$MALID"
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
