#!/bin/bash
cd /root
countsource=`ls -1 /var/www/downloads/*.{mkv,mp4} 2>/dev/null | wc -l`

php renameu.php
php rename.php downloads; sleep 1

# Move uploaded files before testing
mv /var/www/uploaded/* /var/www/trash

if [ $countsource != 0 ]; then	
		mv /var/www/komaru/* /var/www/downloads # If error
		echo "moving renamed files to encoded..."
		mv /var/www/downloads/*.mkv /var/www/encoded; sleep 2
		php rename.2.php; sleep 1
		php NodefilesUploader.php test; sleep 2
		echo "moving uploaded files to downloads..."
		php renametest.php; sleep 2
		mv /var/www/encoded/* /var/www/downloads
else
	echo "no files in downloads folder..."
fi
