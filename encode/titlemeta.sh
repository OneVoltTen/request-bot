rm -f meta.txt
rm -f metadata.txt

metaa=`${INSTALL}/encode/meta.sh $QUEUE/$FILENAMEX`
meta=${metaa#*|*|*|}
subx=${meta#*|}; audio=${meta%|*}
function is_int() { return $(test "$@" -eq "$@" > /dev/null 2>&1); }
if [[ $meta != *"Lavf"* ]]; then
	if [[ ! $subx -eq $subx && ! $audio -eq $audio ]]; then
		die "meta failed - ${meta}" >> ${INSTALL}/log.txt
	else
		if [ -z "$audio" ];	then
			audio_channel=0
		else
			audio_channel=$audio
		fi
		if [ -z "$subx" ]; then
			subtitle=0
		else
			subtitle=$subx
		fi
		echo "${FILENAMEX} => [$meta] => [${audio_channel}] [${subtitle}]"
		echo "${FILENAMEX} => [$meta] => [${audio_channel}] [${subtitle}]" >> ${INSTALL}/log.txt
	fi
else
	echo "CRITICAL > Lavf codec detected; unable to detect title meta [${FILENAMEX}]" >> ${INSTALL}/log.txt
	audio_channel=0
	subtitle=0
fi

FILENAMEXX=${FILENAMEX%${GROUP}*}
rm -f meta.txt
rm -f metadata.txt
