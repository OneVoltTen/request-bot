cd ${INSTALL}
SEP="FFMPEG start!"
echo Track [A:$audio_channel] [S:$subtitle] [Scale:$scale]

if [[ $sub =~ "SubStationAlpha" ]] || [[ $sub =~ "S_TEXT/ASS" ]]; then
	echo "ASS subtitle ~ ${SEP}"
	ffmpeg -i ${i} -map 0:v:0 -c:v libx264 \
	-map 0:a:$audio_channel \
	-c:a libfdk_aac -profile:a aac_he_v2 -ac 2 -b:a 48k -af "volume=2" -vbr 3 -profile:v high -x264-params crf=27.0:ref=8:bframes=3:psy-rd=0.00,0.00:rc-lookahead=60:deblock=1,1:merange=8:partitions=all:me=umh:subme=7:trellis=0:8x8dct=1:cqm=flat:deadzone-inter=21:deadzone-intra=11:chroma-qp-offset=0:threads=8:lookahead-threads=2:b-pyramid=normal:b-adapt=2:b-bias=0:direct=spatial:weightp=2:keyint=240:min-keyint=24:scenecut=40:qcomp=0.60:qpmin=0:qpmax=69:qpstep=4:ipratio=1.40:aq-mode=1:aq-strength=1.00:level=3.1 -map_metadata -1 -movflags +faststart \
	-vf "movie=/root/app/watermark.mov [watermark]; [in] [watermark] overlay=10:10,subtitles=${INSTALL}/.fonts/${filename}.${ext}$scale,format=yuv420p [out]" \
	${i}_encoded.mp4 2> ${LOG}/progress.txt	
elif [[ $sub =~ "S_TEXT/UTF8" ]] || [[ $sub =~ "SubRip/SRT" ]]; then
	echo "SRT subtitle ~ ${SEP}"
	ffmpeg -i $i -map 0:v:0 -c:v libx264 \
	-map 0:a:$audio_channel \
	-c:a libfdk_aac -profile:a aac_he_v2 -ac 2 -b:a 48k -af "volume=2" -vbr 3 -profile:v high -x264-params crf=27.0:ref=8:bframes=3:psy-rd=0.00,0.00:rc-lookahead=60:deblock=1,1:merange=8:partitions=all:me=umh:subme=7:trellis=0:8x8dct=1:cqm=flat:deadzone-inter=21:deadzone-intra=11:chroma-qp-offset=0:threads=8:lookahead-threads=2:b-pyramid=normal:b-adapt=2:b-bias=0:direct=spatial:weightp=2:keyint=240:min-keyint=24:scenecut=40:qcomp=0.60:qpmin=0:qpmax=69:qpstep=4:ipratio=1.40:aq-mode=1:aq-strength=1.00:level=3.1 -map_metadata -1 -movflags +faststart \
	-vf "movie=/root/app/watermark.mov [watermark]; [in] [watermark] overlay=10:10,subtitles=${INSTALL}/.fonts/${filename}.${ext}$scale,format=yuv420p [out]" \
	${i}_encoded.mp4 2> ${LOG}/progress.txt
elif [[ $sub =~ "PGS" ]] || [[ $sub =~ "S_HDMV/PGS" ]] || [[ $sub =~ "VobSub" ]] || [[ $sub =~ "S_VOBSUB" ]]; then
	echo "PGS subtitle ~ ${SEP}"
	ffmpeg -y -i $i -i "${INSTALL}/app/watermark.mov" -c:v libx264 \
	-map 0:a:$audio_channel \
	-c:a libfdk_aac -profile:a aac_he_v2 -ac 2 -b:a 48k -af "volume=2" -vbr 3 -profile:v high -x264-params crf=27.0:ref=8:bframes=3:psy-rd=0.00,0.00:rc-lookahead=60:deblock=1,1:merange=8:partitions=all:me=umh:subme=7:trellis=0:8x8dct=1:cqm=flat:deadzone-inter=21:deadzone-intra=11:chroma-qp-offset=0:threads=8:lookahead-threads=2:b-pyramid=normal:b-adapt=2:b-bias=0:direct=spatial:weightp=2:keyint=240:min-keyint=24:scenecut=40:qcomp=0.60:qpmin=0:qpmax=69:qpstep=4:ipratio=1.40:aq-mode=1:aq-strength=1.00:level=3.1 -map_metadata -1 -movflags +faststart \
	-filter_complex "[0:v][0:s:$subtitle]overlay=(W-w)/2:(H-h)/2$scale[hardsubbed];[hardsubbed][1:v]overlay=10:10[out]" -map "[out]" \
	${i}_encoded.mp4 2> ${LOG}/progress.txt
else
	echo "no subtitle ~ ${SEP}"
	ffmpeg -i $i -map 0:v:0 -c:v libx264 \
	-map 0:a:$audio_channel \
	-c:a libfdk_aac -profile:a aac_he_v2 -ac 2 -b:a 48k -af "volume=2" -vbr 3 -profile:v high -x264-params crf=27.0:ref=8:bframes=3:psy-rd=0.00,0.00:rc-lookahead=60:deblock=1,1:merange=8:partitions=all:me=umh:subme=7:trellis=0:8x8dct=1:cqm=flat:deadzone-inter=21:deadzone-intra=11:chroma-qp-offset=0:threads=8:lookahead-threads=2:b-pyramid=normal:b-adapt=2:b-bias=0:direct=spatial:weightp=2:keyint=240:min-keyint=24:scenecut=40:qcomp=0.60:qpmin=0:qpmax=69:qpstep=4:ipratio=1.40:aq-mode=1:aq-strength=1.00:level=3.1 -map_metadata -1 -movflags +faststart \
	-vf "movie=${INSTALL}/app/watermark.mov [watermark]; [in] [watermark] overlay=10:10$scale,format=yuv420p [out]" \
	${i}_encoded.mp4 2> ${LOG}/progress.txt	
fi
