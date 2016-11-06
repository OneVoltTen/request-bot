#!/bin/bash
. /root/config.sh

cd "/media/yubikiri/bot/sort/this"
meta="405|title|fansub|0|0"

for file in *.mkv; do
	if [[ -f $file ]]; then
		ffmpeg -i "$file" -metadata title="$meta" -c copy -map 0 "/media/yubikiri/bot/queue/$file"
	fi
done

#${INSTALL}/bot.sh
