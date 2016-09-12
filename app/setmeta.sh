#!/bin/bash
cd /var/www/trash/1354
for file in *.mkv; do
	if [ -f $file ]; then
		ffmpeg -i "$file" -metadata title="1354|Mobile_Suit_Gundam_00|OZC|1|1" -c copy -map 0 "/var/www/downloads/$file"
	fi
done
