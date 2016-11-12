# run script as superuser
# install transmission-daemon node php mediainfo mkvtoolnix ffmpeg
mkdir /var/www
mkdir /var/www/downloads
mkdir /var/www/incomplete
mkdir /var/www/komaru
mkdir /var/www/queue
mkdir /var/www/sort
mkdir /var/www/trash
mkdir /var/www/upload
mkdir /var/www/uploaded
mkdir /var/www/verify
mkdir /root/log
mkdir /root/log/encode
#chown user:user /var/www/*
# schedule run /root/bot.sh every 5 minutes