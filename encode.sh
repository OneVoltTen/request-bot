#!/bin/bash
. /root/config.sh
FILENAMEX=""
die() { echo "$@" 1>&2 ; exit 1; }
# Retrieve file
for i in `ls -tr ${DOWNLOAD}/.queue/*.mkv | sort -rh`; do
	FILENAMEX=${i#*${QUEUE}/}
done
# Retrieve file meta
rm -f meta.txt
rm -f metadata.txt

metaa=`${INSTALL}/meta.sh $QUEUE/$FILENAMEX`
meta=${metaa#*|*|*|}
subx=${meta#*|}; audio=${meta%|*}

function is_int() { return $(test "$@" -eq "$@" > /dev/null 2>&1); }
if [ ! $subx -eq $subx 2> /dev/null ] && [ ! $audio -eq $audio 2> /dev/null ]; then
	die "meta failed - ${meta}" >> ${INSTALL}/log.txt
fi

# Empty variable to 0
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
echo "${FILENAMEX} => [${audio_channel}] [${subtitle}]"
echo "${FILENAMEX} => [${audio_channel}] [${subtitle}]" >> ${INSTALL}/log.txt

# End retrieve meta
# Multiple audio track
FILENAMEXX=${FILENAMEX%${GROUP}*}
# End multiple audio track
rm -f meta.txt
rm -f metadata.txt

php ${INSTALL}/rename.php
for i in `ls -tr $QUEUE/*.mkv`;do
	if [ -f $i ]; then
		filename=${i#${QUEUE}/*}
		# Resolution
		resX=`mediainfo $i | grep Width | sed 's/.*: //g' | tr -d '[[:space:]]'`
		resY=`mediainfo $i | grep Height | sed 's/.*: //g' | tr -d '[[:space:]]'`
		resX=${resX%"pixels"}; resY=${resY%"pixels"}
		resTargetX=1280; resTargetY=720
		# Resize if greater than 1280x720
		if [[ $resY -gt $resTargetY ]]; then
			# If height > 720
			ratioY=`awk "BEGIN {print $resY/$resTargetY}"`
			scaledResX=`awk "BEGIN {print $resX/$ratioY}"`
			scaledResX=`echo $scaledResX | awk '{print int($1+0.5)}'`
		else
			scaledResX=$resX
		fi
		if [[ $resX -gt $resTargetX ]]; then
			# If width > 1280
			ratioX=`awk "BEGIN {print $resX/$resTargetX}"`
			scaledResY=`awk "BEGIN {print $resY/$ratioX}"`
			scaledResY=`echo $scaledResY | awk '{print int($1+0.5)}'`
		else
			scaledResY=$resY
		fi
		# Resize calculations
		if [[ ! $resX -gt $resTargetX ]] || [[ ! $resY -gt $resTargetY ]]; then
			scale=""
		elif [[ $resX -eq "1920" ]] || [[ $resY -eq "1080" ]]; then
			scale=",scale=-2:$resTargetY"
		elif [[ $resX -eq $resTargetX ]] || [[ $resY -eq $resTargetY ]]; then
			scale=",scale=-1:$resTargetY"
		elif [[ $scaledResX -gt $resTargetX ]] || [[ $scaledResY -eq $resTargetY ]]; then
			scale=",scale=$resTargetX:-2"
		elif [[ ! $scaledResX -gt $resTargetX ]] || [[ $scaledResY -gt $resTargetY ]]; then
			scale=",scale=-1:$resTargetY"
		elif [[ $scaledResX -gt $resTargetX ]] || [[ $scaledResY -lt $resTargetY ]]; then
			scale=",scale=$resTargetX:-2"
		fi
		# End resolution
		# Subtitle
		cd ${INSTALL}/.fonts
		echo "extract attachment..."; ffmpeg -dump_attachment:t "" -i $i -y > /dev/null 2>&1; sleep 1
		echo "install font..."
		fc-cache -f -v ${INSTALL}/.fonts > /dev/null 2>&1
		echo "extract subtitle..."; sub=$(mkvmerge -i "$i" | awk '$4=="subtitles"{print;exit}')
		if [[ $sub ]]; then
			# Detect subtitle type
			echo $sub; ada_subtitle=true;
			if [[ $sub =~ "SubStationAlpha" ]] || [[ $sub =~ "S_TEXT/ASS" ]]; then
				ext=ass;
			elif [[ $sub =~ "S_TEXT/UTF8" ]] || [[ $sub =~ "SubRip/SRT" ]]; then
				ext=srt;
			elif [[ $sub =~ "PGS" ]] || [[ $sub =~ "S_HDMV/PGS" ]]; then
				ext=pgs;
			fi
			track=$(awk -F '[ :]' '{print $3}' <<< "$sub")
			if (( $subtitle > 0 )); then
				track=$((track+$subtitle))
			fi
			#echo $track
			mkvextract tracks "$i" "$track:${i}.$ext"
		fi
		mv $i.{ass,srt} ${INSTALL}/.fonts/ -f >/dev/null 2>&1;sleep .5
		cd ${INSTALL}
		SEP="FFMPEG start!"
		# End subtitle
		# Process file
		if [[ $sub =~ "SubStationAlpha" ]] || [[ $sub =~ "S_TEXT/ASS" ]]; then
			echo "ASS subtitle ~ ${SEP}" >> ${INSTALL}/log.txt;
			ffmpeg -i $i -map 0:v:0 -c:v libx264 \
			-map 0:a:$audio_channel \
			-c:a libfdk_aac -profile:a aac_he_v2 -ac 2 -b:a 48k -af "volume=2" -vbr 3 -profile:v high -x264-params crf=27.0:ref=8:bframes=3:psy-rd=0.00,0.00:rc-lookahead=60:deblock=1,1:merange=8:partitions=all:me=umh:subme=7:trellis=0:8x8dct=1:cqm=flat:deadzone-inter=21:deadzone-intra=11:chroma-qp-offset=0:threads=8:lookahead-threads=2:b-pyramid=normal:b-adapt=2:b-bias=0:direct=spatial:weightp=2:keyint=240:min-keyint=24:scenecut=40:qcomp=0.60:qpmin=0:qpmax=69:qpstep=4:ipratio=1.40:aq-mode=1:aq-strength=1.00:level=3.1 -map_metadata -1 -movflags +faststart \
			-vf "movie=/root/app/watermark.mov [watermark]; [in] [watermark] overlay=10:10,ass=${INSTALL}/.fonts/${filename}.ass$scale,format=yuv420p [out]" \
			${i}_encoded.mp4 2> ${LOG}/progress.txt
		elif [[ $sub =~ "S_TEXT/UTF8" ]] || [[ $sub =~ "SubRip/SRT" ]]; then
			echo "SRT subtitle ~ ${SEP}" >> ${INSTALL}/log.txt;
			ffmpeg -i $i -map 0:v:0 -c:v libx264 \
			-map 0:a:$audio_channel \
			-c:a libfdk_aac -profile:a aac_he_v2 -ac 2 -b:a 48k -af "volume=2" -vbr 3 -profile:v high -x264-params crf=27.0:ref=8:bframes=3:psy-rd=0.00,0.00:rc-lookahead=60:deblock=1,1:merange=8:partitions=all:me=umh:subme=7:trellis=0:8x8dct=1:cqm=flat:deadzone-inter=21:deadzone-intra=11:chroma-qp-offset=0:threads=8:lookahead-threads=2:b-pyramid=normal:b-adapt=2:b-bias=0:direct=spatial:weightp=2:keyint=240:min-keyint=24:scenecut=40:qcomp=0.60:qpmin=0:qpmax=69:qpstep=4:ipratio=1.40:aq-mode=1:aq-strength=1.00:level=3.1 -map_metadata -1 -movflags +faststart \
			-vf "movie=/root/app/watermark.mov [watermark]; [in] [watermark] overlay=10:10,subtitles=${INSTALL}/.fonts/${filename}.srt$scale,format=yuv420p [out]" \
			${i}_encoded.mp4 2> ${LOG}/progress.txt
		elif [[ $sub =~ "PGS" ]] || [[ $sub =~ "S_HDMV/PGS" ]] || [[ $sub =~ "VobSub" ]] || [[ $sub =~ "S_VOBSUB" ]]; then
			echo "PGS subtitle ~ ${SEP}" >> ${INSTALL}/log.txt;
			ffmpeg -y -i $i -i "${INSTALL}/app/watermark.mov" -c:v libx264 \
			-map 0:a:$audio_channel \
			-c:a libfdk_aac -profile:a aac_he_v2 -ac 2 -b:a 48k -af "volume=2" -vbr 3 -profile:v high -x264-params crf=27.0:ref=8:bframes=3:psy-rd=0.00,0.00:rc-lookahead=60:deblock=1,1:merange=8:partitions=all:me=umh:subme=7:trellis=0:8x8dct=1:cqm=flat:deadzone-inter=21:deadzone-intra=11:chroma-qp-offset=0:threads=8:lookahead-threads=2:b-pyramid=normal:b-adapt=2:b-bias=0:direct=spatial:weightp=2:keyint=240:min-keyint=24:scenecut=40:qcomp=0.60:qpmin=0:qpmax=69:qpstep=4:ipratio=1.40:aq-mode=1:aq-strength=1.00:level=3.1 -map_metadata -1 -movflags +faststart \
			-filter_complex "[0:v][0:s:$subtitle]overlay=(W-w)/2:(H-h)/2$scale[hardsubbed];[hardsubbed][1:v]overlay=10:10[out]" -map "[out]" \
			${i}_encoded.mp4 2> ${LOG}/progress.txt
		else
			echo "no subtitle ~ ${SEP}" >> ${INSTALL}/log.txt;
			ffmpeg -i $i -map 0:v:0 -c:v libx264 \
			-map 0:a:$audio_channel \
			-c:a libfdk_aac -profile:a aac_he_v2 -ac 2 -b:a 48k -af "volume=2" -vbr 3 -profile:v high -x264-params crf=27.0:ref=8:bframes=3:psy-rd=0.00,0.00:rc-lookahead=60:deblock=1,1:merange=8:partitions=all:me=umh:subme=7:trellis=0:8x8dct=1:cqm=flat:deadzone-inter=21:deadzone-intra=11:chroma-qp-offset=0:threads=8:lookahead-threads=2:b-pyramid=normal:b-adapt=2:b-bias=0:direct=spatial:weightp=2:keyint=240:min-keyint=24:scenecut=40:qcomp=0.60:qpmin=0:qpmax=69:qpstep=4:ipratio=1.40:aq-mode=1:aq-strength=1.00:level=3.1 -map_metadata -1 -movflags +faststart \
			-vf "movie=${INSTALL}/app/watermark.mov [watermark]; [in] [watermark] overlay=10:10$scale,format=yuv420p [out]" \
			${i}_encoded.mp4 2> ${LOG}/progress.txt
		fi
		# Rename log file
		echo "FFMPEG complete" >> ${INSTALL}/log.txt
		echo "log rename => progress_$(date +%F_%H-%M).txt"
		mv ${LOG}/progress.txt ${LOG}/progress_$(date +%F_%H-%M).txt
		# Remove temp subtitle file after processing
		rm -rf ${INSTALL}/.fonts/*
		# Move file to encoded folder
		echo "move to encoded folder..."
		mv ${i}_encoded.mp4 ${ENCODED} -f
		# If file moved to encoded folder
		count=`ls -1 $ENCODED/*_encoded.mp4 2>/dev/null | wc -l`
		if [ $count != 0 ]; then
			echo "execute upload worker..." >> ${INSTALL}/log.txt; php ${INSTALL}/rename.php 2; nohup php ${INSTALL}/NodefilesUploader.php >> ${INSTALL}/log.txt &
		else
			echo "no upload..."
		fi
		# If file not moved to encode folder
		if [[ ${FILENAMEX%${GROUP}*} > 0 ]];then
			echo "move to trash..."; mkdir -p "${TRASH}/${FILENAMEX%${GROUP}*}"; mv $i "${TRASH}/${FILENAMEX%${GROUP}*}" -f
		else
			echo "no id set"; echo "move to trash..."; mv $i ${TRASH} -f
		fi
	fi
done
# Remove remaining temp file
sleep 2; echo "remove temp file..."; rm -rf $QUEUE/*.{OTF,TTF,TTC,FON,FNT,PFB,DFONT,ASS,SRT,PGS,SUP,SUB,IDX,JPG,PNG,GIF,BMP,Otf,Ttf,Ttc,Fon,Fnt,Pfb,Dfont,Ass,Srt,Pgs,Sup,Sub,Idx,Jpg,Png,Gif,Bmp,otf,ttf,ttc,fon,fnt,pfb,dfont,ass,srt,pgs,sup,sub,idx,jpg,png,gif,bmp} ${INSTALL}/.fonts/*.{OTF,TTF,TTC,FON,FNT,PFB,DFONT,Otf,Ttf,Ttc,Fon,Fnt,Pfb,Dfont,otf,ttf,ttc,fon,fnt,pfb,dfont}

seconds=`date +%S`
if [[ $seconds -gt "52" ]]; then
	echo ">" $seconds "no bot.sh"
else
	echo "execute bot.sh"; nohup ${INSTALL}/bot.sh sort >> ${INSTALL}/log.txt &
fi
