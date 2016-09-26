#!/bin/bash
cd /root
countsource=`ls -1 ${DOWNLOAD}/*.{mkv,mp4} 2>/dev/null | wc -l`

php rename.php downloads; sleep 1

# Move uploaded files before testing
mv ${UPLOADED}/* ${TRASH}

if [ $countsource != 0 ]; then	
		mv ${KOMARU}/* ${DOWNLOAD} # If error
		echo "moving renamed files to encoded..."
		mv ${DOWNLOAD}/*.mkv ${ENCODED}; sleep 2
		php rename.php 2; sleep 1
		php NodefilesUploader.php test; sleep 2
		echo "moving uploaded files to downloads..."
		php rename.php renametest; sleep 2
		mv ${ENCODED}/* ${DOWNLOAD}
else
	echo "no files in downloads folder..."
fi
