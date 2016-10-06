#!/bin/bash
. /root/config.sh

cd /var/www/komaru/golden
meta="1371|title|SSP_Corp|1|1"

for file in *.mkv; do
	if [ -f $file ]; then
		ffmpeg -i "$file" -metadata title="$meta" -c copy -map 0 "/var/www/downloads/$file"
	fi
done

${INSTALL}/bot.sh
