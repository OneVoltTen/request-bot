if [[ ${file,,} == *${1}* ]]; then
	echo "[${MALID}] ${file,,} => ${1}" >> $SORT/log-music.txt
	mv "${file}" "$TRASH/$MALID" >> $SORT/log-music.txt
	music=$((music+1))
fi
