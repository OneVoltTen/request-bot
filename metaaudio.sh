#!/bin/bash
cd /root
KOMARU="/var/www/komaru";
#echo $1;
if [[ -f $1 ]]; then
	exiftool $1 > metadata.txt
	while read line; do
		if [[ $line == *"Track Number"* ]]; then
			meta=${line#*:}
			echo $meta
		fi
	done < metadata.txt
else
	echo "invalid file ${1}"
fi
