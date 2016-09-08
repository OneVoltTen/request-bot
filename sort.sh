#!/bin/bash
cd /var/www/sort; SORT="/var/www/sort"; DOWNLOAD="/var/www/downloads"; TRASH="/var/www/trash"; LAST=""
#TR_TORRENT_DIR="/var/www/sort"
#TR_TORRENT_NAME="SampleVideo_1280x720_2mb.mp4"
TR_DOWNLOADS="/var/www/sort/$TR_TORRENT_NAME"; echo "TR_DOWNLOADS > $TR_DOWNLOADS" >> $SORT/log.txt
# Function die with message
die() { echo "$@" 1>&2 ; exit 1; }
# Update downloading.txt if any changes
echo 'retrieve...' >> $SORT/log.txt; /root/retrieve.sh; sleep 1
# Foreach line in downloading.txt
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
						mv ${SORT}/*.mkv ${DOWNLOAD}
						nohup /root/bot.sh sort > /dev/null 2>&1 &
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
						# Move files into working directory [Max 1 subfolder]
						mv ***/*.mkv "$SORT/$FILEN1"; sleep 1
						mv ***/*.mp4 "$SORT/$FILEN1"; sleep 1
						mv ***/*.avi "$SORT/$FILEN1"; sleep 1
						echo "Working directory" $(pwd) >> $SORT/log.txt
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
							sleep 1
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
							sleep 1
						done
						for file in *.mkv; do
							# Rename file to remove pipe
							if [[ $file == *"|"* ]]; then
								mv "${file}" "${file/|/}"; file=${file//|/};
							fi
							# Set file title metadata
							mkvpropedit "$file" -e info -s title="$FTITLE" >> $SORT/log.txt
							# Move to downloads folder
							mv "${file}" "${DOWNLOAD}" >> $SORT/log.txt
						done
					else
						echo "working directory failed change > $SORT/$FILEN1" >> $SORT/log.txt
					fi
					sleep 2
					# Move folder into trash/ID
					mkdir -p "$TRASH/$MALID"
					mv "$SORT/$FILEN1" "$TRASH/$MALID"
					nohup /root/bot.sh sort > /dev/null 2>&1 &
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
