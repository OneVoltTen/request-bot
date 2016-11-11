#!/bin/bash
. /root/app/config.sh
cd ${SORT}
LAST=""
# depreciated
	#TR_TORRENT_DIR="${SORT}"
	#TR_TORRENT_NAME="Bleach"
TR_DOWNLOADS="${SORT}/$TR_TORRENT_NAME"; echo "TR_DOWNLOADS > $TR_DOWNLOADS" >> ${LOG}/sort.log
# wait if torrent.log being retrieved
if pidof -s retrieve.sh >> ${LOG}/sort.log; then
	sleep 5
else
	echo 'retrieve...' >> ${LOG}/sort.log; /root/app/retrieve.sh
fi
# Read each line in torrent.log
echo 'read torrent.log' >> ${LOG}/sort.log
while read line; do
	if [[ ! $LAST == $line ]]; then
		LAST=${line}
		# read and format meta
		FILEN=${line%:*:*:*:*:*}; Basename="${FILEN##*/}"; FILEN="${SORT}/${Basename}"; MALID=${line#*:*:*:*:*:}; VALUES=${line#*:}; FANSUB1=${VALUES%:*:*:*}; FANSUB=${FANSUB1#*:}; NEXT1=${VALUES%:*}; NEXT=${NEXT1#*:*:}; AUDIO=${NEXT%:*}; SUB=${NEXT#*:}
		#TITLE=${VALUES%:*:*:*:*}; 
		TITLE="Text" # temp removed
		FTITLE="$MALID|$TITLE|$FANSUB|$AUDIO|$SUB"
		# Verify meta colon count
		colon_count=$(grep -o ":" <<< "$line" | wc -l)
		if [[ ! $colon_count == 5 ]]; then
			declare -a arr=($MALID $TITLE $FANSUB $AUDIO $SUB);	echo "> invalid colon count! $colon_count" >> ${LOG}/sort.log
			for i in "${arr[@]}"; do
				if [[ $i == *":"* ]]; then
					echo "> $i: [$i]" >> ${LOG}/sort.log
				fi
			done
			die "invalid colon ${line}" >> ${LOG}/sort.log
		else
			if [[ $TR_TORRENT_NAME == *".mkv" ]] || [[ $TR_TORRENT_NAME == *".mp4" ]] || [[ $TR_TORRENT_NAME == *".avi" ]] || [[ $Basename == *".mkv" ]] || [[ $Basename == *".mp4" ]] || [[ $Basename == *".avi" ]]; then
				echo "file $FILEN" >> ${LOG}/sort.log
				if [[ -f "$FILEN" ]]; then
					CRC=`crc32 "$FILEN"`
					mkdir "$SORT/$CRC"
					mv "$FILEN" "$SORT/$CRC"
					DIR="$SORT/$CRC"
					source $INSTALL/sort/sortx.sh >> ${LOG}/sort.log
				else
					echo "no match [file] $FILEN" >> ${LOG}/sort.log
				fi
				sleep 1
			else
				if [[ -d "$FILEN" ]]; then
					source $INSTALL/sort/sortx.sh >> ${LOG}/sort.log
				else
					echo "no match [directory] $FILEN" >> ${LOG}/sort.log
				fi
			fi
		fi
	else
		echo "dupe line" >> ${LOG}/sort.log
	fi
done < "$INSTALL/log/torrent.log"
echo "end" >> ${LOG}/sort.log
