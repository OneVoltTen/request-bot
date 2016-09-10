#!/bin/bash
cd /root
KOMARU="/var/www/komaru";
#echo $1;
rm -f meta.txt
if [[ -f $1 ]]; then
	ffmpeg -i $1 -f ffmetadata meta.txt >/dev/null 2>&1
	metaline=`sed -n "2{p;q;}" meta.txt`
	if [[ $metaline == *"title="* && $metaline == *"|"* ]]; then
		meta=${metaline//title=/}
		echo $meta
		rm -f meta.txt
	else
		echo "invalid meta [title] => [${metaline}]"
		FILEN=${1#/var/www/downloads/*}
		FILEN=${FILEN#.queue/*}
		mv $1 $KOMARU/$FILEN
		mv /root/meta.txt $KOMARU/${FILEN}_meta.txt
	fi
else
	echo "invalid file ${1}"
fi
