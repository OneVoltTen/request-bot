#!/bin/bash
cd /var/www/goldenboy
for file in *.mkv; do
	if [ -f $file ]; then
		ffmpeg -i "$file" -metadata title="1371|title|Corp|0|0" -c copy -map 0 "/var/www/downloads/$file"
	fi
done
