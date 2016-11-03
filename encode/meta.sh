#!/bin/bash
. /root/config.sh
if [[ -f $1 ]]; then
	ffmpeg -i $1 -f ffmetadata meta.txt >/dev/null 2>&1
	metaline=`sed -n "2{p;q;}" meta.txt`
	if [[ $metaline == *"title="* && $metaline == *"|"* ]]; then
		meta=${metaline//title=/}
		#echo $meta
		rm -f meta.txt
	else
		echo "invalid meta [title] => [${metaline}]"
		FILEN=${1#${DOWNLOAD}/*}
		FILEN=${FILEN#$QUEUE/*}
		mv $1 $KOMARU/$FILEN
		mv ${INSTALL}/meta.txt $KOMARU/${FILEN}_meta.txt
	fi
else
	echo "invalid file ${1}"
fi
#rm -f meta.txt
sleep .5
