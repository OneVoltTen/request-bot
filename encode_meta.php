<?php
# Returns audio/sub meta to bash script
if(isset($argv[1]) && !empty($argv[1])){
	$fileName=$argv[1];
}else{
	die('undefined file');
}
require_once('/root/getid3/getid3.php');
$getID3=new getID3;

#$fileName="12883AnimePahe_Non_Non_Biyori_-_01_Darude_720p_CBM.mkv";
$path=realpath('/var/www/downloads/.queue/'.$fileName);
# echo $path."\n";
if(!empty(file_get_contents($path))){
	
	# WARNING WARNING WARNING
	# This process will allocate the file into system ram to check the metatags
	# If the filesize is larger than system available ram the process will fail
	
	$ThisFileInfo=$getID3->analyze($path);
	getid3_lib::CopyTagsToComments($ThisFileInfo);
	$metadata=htmlentities(!empty($ThisFileInfo['comments_html']['title'])?implode('<br>',$ThisFileInfo['comments_html']['title']):chr(160));
	$metadata=array_filter(explode('|', $metadata));
	if(empty($metadata[0]) || empty($metadata[1]) || empty($metadata[2])){
		die("> Metadata not set - ".$fileName."\n");
	}else{# Set metadata
		if(empty($metadata[3])){$aud=0;}else{$aud=$metadata[3];}
		if(empty($metadata[4])){$sub=0;}else{$sub=$metadata[4];}
		echo $aud."|".$sub."\n";
		$aud=escapeshellarg($aud);
	}
}else{
	die('could not open input file '.$path."\n");
}
?>
