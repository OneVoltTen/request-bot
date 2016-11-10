#!/bin/bash
. /root/app/config.sh

# directory of mkv files to set metadata
cd "/media/yubikiri/bot/sort/this"
meta="405|title|fansub|0|0"
# destination to copy files to
dest="/media/yubikiri/bot/queue/$file"
for file in *.mkv; do
	if [[ -f $file ]]; then
		ffmpeg -i "$file" -metadata title="$meta" -c copy -map 0 "$dest"
	fi
done

#${INSTALL}/bot.sh
