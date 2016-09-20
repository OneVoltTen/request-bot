AnimePahe request bot
Semi-automated processing of anime files
Supports video formats avi, mp4, mkv

General process:
User adds anime request https://beta.animepahe.com/request
Moderator accepts request
Set config retrieve url /app/app.js "var url = 'https://beta.animepahe.com/request/0'"
Retrieve.sh retrieves json anime details and downloads torrent
Sort.sh is executed after download complete, convert video format and move to downloads folder
Video files are renamed and moved to queue folder to be processed
After queue file is processed moved to encoded folder
Encoded folder automatically upload video file to filehost, retrieve upload url and post to database, move uploaded file to uploaded folder
