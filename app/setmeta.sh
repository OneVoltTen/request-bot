#!/bin/bash
. /root/config.sh

cd /var/www/sort/
meta="666|title|Fansub|1|1"

for file in *.mkv; do
	if [[ -f $file ]]; then
		ffmpeg -i "$file" -metadata title="$meta" -c copy -map 0 "/var/www/queue/$file"
	fi
done

#${INSTALL}/bot.sh
