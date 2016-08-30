<?php
require_once('/root/getid3/getid3.php');
$getID3=new getID3;
$FullFileName=realpath('/var/www/html/video.mkv');
$ThisFileInfo=$getID3->analyze($FullFileName);
getid3_lib::CopyTagsToComments($ThisFileInfo);
if(!empty(htmlentities($ThisFileInfo['filenamepath']))){
echo $title=htmlentities(!empty($ThisFileInfo['comments_html']['title'])?implode('<br>',$ThisFileInfo['comments_html']['title']):chr(160));
}else{
die("title metadata not found");
}
?>
