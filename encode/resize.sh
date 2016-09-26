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
