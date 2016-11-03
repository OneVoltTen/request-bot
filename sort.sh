#!/bin/bash
. /root/config.sh
cd ${SORT}
LAST=""
#TR_TORRENT_DIR="${SORT}"
#TR_TORRENT_NAME="Bleach"
TR_DOWNLOADS="${SORT}/$TR_TORRENT_NAME"; echo "TR_DOWNLOADS > $TR_DOWNLOADS" >> $SORT/log.txt
# Function die with message
die() { echo "$@" 1>&2; exit 1; }
# Update downloading.txt if any changes, if downloading.txt being updated
if pidof -s retrieve.sh >> $SORT/log.txt; then
	sleep 10
fi
echo 'retrieve...' >> $SORT/log.txt; /root/app/retrieve.sh; sleep 1
# Read each line in downloading.txt
echo 'read downloading.txt' >> $SORT/log.txt
while read line; do
	if [[ ! $LAST == $line ]]; then
		LAST=${line}
		# Get meta between colon
		FILEN=${line%:*:*:*:*:*}; Basename="${FILEN##*/}"; echo $line >> $SORT/log.txt; MALID=${line#*:*:*:*:*:}; VALUES=${line#*:}; FANSUB1=${VALUES%:*:*:*}; FANSUB=${FANSUB1#*:}; NEXT1=${VALUES%:*}; NEXT=${NEXT1#*:*:}; AUDIO=${NEXT%:*}; SUB=${NEXT#*:}
		#TITLE=${VALUES%:*:*:*:*}; 
		TITLE="Text"
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
			if [[ $TR_TORRENT_NAME == *".mkv" ]] || [[ $TR_TORRENT_NAME == *".mp4" ]] || [[ $TR_TORRENT_NAME == *".avi" ]] || [[ $Basename == *".mkv" ]] || [[ $Basename == *".mp4" ]] || [[ $Basename == *".avi" ]]; then
				echo "file $FILEN" >> $SORT/log.txt
				if [[ -f $FILEN ]]; then
					CRC=`crc32 "$FILEN"`
					mkdir "$SORT/$CRC"
					mv "$FILEN" "$SORT/$CRC"
					DIR="$SORT/$CRC"
					source $INSTALL/app/sortx.sh >> $SORT/log.txt
				else
					echo 'no match' >> $SORT/log.txt
				fi
			sleep 2
			else
				source $INSTALL/app/sortx.sh >> $SORT/log.txt
			fi # files
		fi # :
	else
		echo "dupe line" >> $SORT/log.txt
	fi # LAST
done <../downloading.txt
echo "end" >> $SORT/log.txt
