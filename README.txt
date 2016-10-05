AnimePahe request bot; download torrent, encode video, upload & post to database.

Supports:
Retrieve torrent page download url [nyaa.se, bakabt.me]
Video formats [avi, mp4, mkv]
Multiple tracks [subtitle, audio]
Multiple RSS/Request instances

Basic Process:
User adds request via web interface [https://beta.animepahe.com/request], moderator accepts request
Retrieve.sh retrieves requests [https://beta.animepahe.com/devrequest/0], saves details, downloads torrent url
On download complete sort.sh processes downloaded files, move video files to downloads folder, leftover files to trash folder
Downloads folder renames video files, moved to queue folder, else invalid filename move to komaru folder
Queue folder encodes files with FFMPEG, processed file moved to encoded folder
Encoded folder upload video file to filehost, retrieve upload url, post to database, move uploaded file to uploaded folder
