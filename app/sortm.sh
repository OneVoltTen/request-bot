# Replace space with underscore
if [[ $file == *" "* ]]; then
	mv "${file}" "${file// /_}"; file=${file// /_}
fi
# Remove pipe
if [[ $file == *"|"* ]]; then
	mv "${file}" "${file/|/}"; file=${file//|/}
fi
if [[ -f $file ]]; then
	if [[ "${file}" == *".mp4" || "${file}" == *".avi" ]]; then
		if [[ "${file}" == *".avi"* ]]; then
			ffmpeg -fflags +genpts -i "$file" -vcodec copy -acodec copy $file.mp4; sleep .5
			mkdir -p "$TRASH/$MALID"
			rm "$file" >> $SORT/log.txt
			mv "${file}.mp4" "${file//.avi/.mp4}"; file=${file//.avi/.mp4}
		fi
		if [[ "${file}" == *".mp4" ]]; then
			ffmpeg -i $file -vcodec copy -acodec copy $file.mkv; sleep .5
			rm "$file" >> $SORT/log.txt
			if [[ "${file}" == *".avi"* ]]; then
				mv "${file}.mp4" "${file//.mp4/.mkv}"; file=${file//.avi/.mp4}
			fi
		fi
		# Update file to new file
		file="${file}.mkv"
		if [[ "${file}" == *".mp4"* ]]; then
			mv "$file" "${file//.mp4/}" >> $SORT/log.txt
			file=${file//.mp4/}
		elif [[ "${file}" == *".avi"* ]]; then
			mv "$file" "${file//.avi/}" >> $SORT/log.txt
			file=${file//.avi/}
		fi
		echo "MKV " $file >> $SORT/log.txt
	fi
fi
