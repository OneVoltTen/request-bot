#!/bin/bash
cd /var/www/sort
SORT="/var/www/sort"
DOWNLOAD="/var/www/downloads"
TRASH="/var/www/trash"
#TR_TORRENT_DIR="/var/www/sort"
#TR_TORRENT_NAME="Tekkon_Kinkreet_(2006)_[720p,BluRay,x264]_-_THORA.mkv"

TR_DOWNLOADS="/var/www/sort/$TR_TORRENT_NAME"
echo "TR_DOWNLOADS > $TR_DOWNLOADS" >> $SORT/log.txt

if [ ! -f ../downloading.txt ]; then
    echo "downloading.txt file not found!" >> $SORT/log.txt
else
	echo 'retrieving...' >> $SORT/log.txt
	# Update downloading.txt if any changes
	/root/retrieve.sh; sleep 1
	echo 'read downloading.txt' >> $SORT/log.txt
	while read line; do
		FILEN=${line%:*:*:*:*:*}
		echo $line >> $SORT/log.txt
		MALID=${line#*:*:*:*:*:}
		VALUES=${line#*:}
		TITLE=${VALUES%:*:*:*:*}			
		FANSUB1=${VALUES%:*:*:*}
		FANSUB=${FANSUB1#*:}
		NEXT1=${VALUES%:*}
		NEXT=${NEXT1#*:*:}
		AUDIO=${NEXT%:*}
		SUB=${NEXT#*:}
		FTITLE="$MALID|$TITLE|$FANSUB|$AUDIO|$SUB"
		echo Filetitle $FTITLE >> $SORT/log.txt

		colon_count=$(grep -o ":" <<< "$line" | wc -l)
		if [[ ! $colon_count == 5 ]]; then
			declare -a arr=($MALID $TITLE $FANSUB $AUDIO $SUB)
			echo "> invalid colon count! $colon_count" >> $SORT/log.txt
			for i in "${arr[@]}"; do
				if [[ $i == *":"* ]]; then
					echo "> $i: [$i]" >> $SORT/log.txt
				fi
			done
		else
			if [[ $TR_TORRENT_NAME == *".mkv" ]] || [[ $TR_TORRENT_NAME == *".mp4" ]]; then
				echo "file $FILEN" >> $SORT/log.txt
				if [[ -f $FILEN ]]; then
					echo 'match!' >> $SORT/log.txt
					echo "id["$MALID"] title["$TITLE"] fansub["$FANSUB"] file["$FILEN"]" >> $SORT/log.txt
					#mediainfo --fullscan "$FILEN"
					if [[ $TR_TORRENT_NAME == *".mkv" ]]; then
						if [[ $file == *"|"* ]]; then
							mv "${FILEN}" "${FILEN/|/}"; file=${file//|/};
						fi
						mkvpropedit "$FILEN" -e info -s title="$FTITLE" >> $SORT/log.txt
						mv ${SORT}/*.mkv ${DOWNLOAD}
					fi
				else
					echo 'no match' >> $SORT/log.txt
				fi
			sleep 2
			else
				echo "directory" >> $SORT/log.txt
				# Replace illegal folder name
				Basename="${FILEN##*/}"
				echo $Basename >> $SORT/log.txt
				FILEN1=${Basename//[^a-zA-Z_0-9]/_}
				if [ -d "$FILEN" ]; then
					RENAME=${FILEN1/[^a-zA-Z_0-9]/_}
					mv "$FILEN" "$SORT/$RENAME"
					cd "$SORT/$FILEN1"
					if [ ! $(pwd) == $SORT ]; then
						for file in *mkv; do
							echo Current directory $(pwd) >> $SORT/log.txt
							if [[ $file == *".mkv" ]]; then
								if [[ $file == *"|"* ]]; then
									mv "${file}" "${file/|/}"; file=${file//|/};
								fi
								mkvpropedit "$file" -e info -s title="$FTITLE" >> $SORT/log.txt
								mv "${file}" "${DOWNLOAD}" >> $SORT/log.txt
							fi
						done
					else
						echo "working directory failed change > $SORT/$FILEN1" >> $SORT/log.txt
					fi
					sleep 2
					mkdir -p "$TRASH/$MALID"
					mv "$SORT/$FILEN1" "$TRASH/$MALID"
				else
					echo "directory illegal $SORT$FILEN" >> $SORT/log.txt
				fi # dir not exist
			fi #files
		fi #:
	done <../downloading.txt
fi #downloading.txt
echo "end" >> $SORT/log.txt
/root/bot.sh sort
