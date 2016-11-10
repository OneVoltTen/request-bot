<?php
	// check resolution
	if (strpos($str,'720p')==true || strpos($str,'x720')==true){
		$resolution="720p";
	} else if (strpos($str,'540p')==true || strpos($str,'x540')==true){
		$resolution="540p";
	} else if (strpos($str,'576p')==true || strpos($str,'x576')==true){
		$resolution="576p";
	} else if (strpos($str,'480p')==true || strpos($str,'x480')==true || strpos($str,'DVD')==true){
		$resolution="480p";
	} else if (strpos($str,'360p')==true || strpos($str,'x360')==true){
		$resolution="360p";
	} else if (strpos($str,'420p')==true || strpos($str,'x420')==true){
		$resolution="420p";
	} else {
		$resolution="720p";
	}

	// removes resolutions
	$str=str_ireplace(array("360p","396p","480p","640x480","704x480","720x480","848x480","864x480","540p","576p","768x576","1024x576","720p","960x720","1280x720","1600x900","1440x1080","1920x1080","1080p"),"",$str);