#!/bin/bash
. /root/app/config.sh
rm -f meta.txt
ffmpeg_cmd=`ffmpeg -i "$1" -f ffmetadata meta.txt`; $ffmpeg_cmd
metaline=`sed -n "2{p;q;}" meta.txt`
sleep .2
if [[ $metaline == *"title="* && $metaline == *"|"* ]]; then
	meta=${metaline//title=/}
	echo $meta
else
	echo "invalid meta [title] => [${metaline}]"
	FILEN=${1#${DOWNLOAD}/*}
	FILEN=${FILEN#$QUEUE/*}
	mv $1 $KOMARU/$FILEN
	mv ${INSTALL}/meta.txt $KOMARU/${FILEN}_meta.txt
	ps -ef | grep rename.php | grep -v grep | awk '{print $2}' | xargs kill
fi
rm -f meta.txt
