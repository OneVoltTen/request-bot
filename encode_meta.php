<?php
# Returns audio/sub meta to bash script
if(isset($argv[1]) && !empty($argv[1])){
	$fileName=$argv[1];
}else{
	die('undefined file');
}
require_once('/root/app/getid3/getid3.php');
$getID3=new getID3;

#$fileName="12883AnimePahe_Non_Non_Biyori_-_01_Darude_720p_CBM.mkv";
$path=realpath('/var/www/downloads/.queue/'.$fileName);
# echo $path."\n";
if(!empty(file_get_contents($path))){	
	$ThisFileInfo=$getID3->analyze($path);
	getid3_lib::CopyTagsToComments($ThisFileInfo);
	$metadata=htmlentities(!empty($ThisFileInfo['comments_html']['title'])?implode('<br>',$ThisFileInfo['comments_html']['title']):chr(160));
	$metadata=array_filter(explode('|', $metadata));
	if(empty($metadata[0]) || empty($metadata[1]) || empty($metadata[2])){
		echo var_dump($metadata);
		die();
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
