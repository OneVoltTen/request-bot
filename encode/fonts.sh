cd ${INSTALL}/.fonts
echo "extract attachment..."; ffmpeg -dump_attachment:t "" -i $i -y  >> ${INSTALL}/log.txt; sleep 1
echo "install font..."
fc-cache -f -v ${INSTALL}/.fonts >> ${INSTALL}/log.txt
echo "extract subtitle..."
sub=$(mkvmerge -i "$i" | awk '$4=="subtitles"{print;exit}')
if [[ $sub ]]; then
	# Detect subtitle type
	#echo $sub
	ada_subtitle=true
	if [[ $sub =~ "SubStationAlpha" ]] || [[ $sub =~ "S_TEXT/ASS" ]]; then
		ext=ass
	elif [[ $sub =~ "S_TEXT/UTF8" ]] || [[ $sub =~ "SubRip/SRT" ]]; then
		ext=srt
	elif [[ $sub =~ "PGS" ]] || [[ $sub =~ "S_HDMV/PGS" ]]; then
		ext=pgs
	fi
	track=$(awk -F '[ :]' '{print $3}' <<< "$sub")
	if (( $subtitle > 0 )); then
		track=$((track+$subtitle))
		echo $track;
	fi
	#echo $ext
	#echo $track
	mkvextract tracks "$i" "$track:${i}.${ext}" >> ${INSTALL}/log.txt
	#@mv -f $i.{ass,srt,sub,idx} ${INSTALL}/.fonts  >> ${INSTALL}/log.txt
fi
sleep 1
