<?php
	$path = "/var/www/encoded/";

	if ($handle = opendir($path)) {
		chdir($path);
		while (false !== ($fileName = readdir($handle))) {
			if ($fileName != "." && $fileName != ".." && strtolower(substr($fileName, strrpos($fileName, '.') + 1)) == 'mp4' || strpos($fileName, '.mkv'))  {
				$str = $fileName;
				$newName = $str;

				$str = str_ireplace("_Cant_", "_Can't_", $str);
				$str = str_ireplace("_I_ll_", "_I'll_", $str);
				$str = str_replace('_I_ve', "_I've", $str);

				$str = str_replace("TV_720p", "720p", $str);
				$str = str_replace("542p", "720p", $str);

				$str = str_replace('.mkv_encoded', '', $str);
				$str = str_replace('.mp4_encoded', '', $str);
				$str = str_replace('.avi_encoded', '', $str);
				$str = str_replace('.mkv', '', $str);

				$str = preg_replace('/\\.[^.\\s]{3,4}$/', '', $str);
				if (strpos($str,'.mkv') !== false) {
					$str = substr($str, 0, strpos($str, ".mkv"));
					$str = $str.".mp4";
				}
				$newName = str_replace(".mkv", ".mp4", $newName);
				$newName = str_replace(".mp4_encoded", "", str_replace(".mkv_encoded", "", str_replace(".avi_encoded", "", $newName)));
				echo $fileName." => ".$newName."\n\n";
				rename($fileName, $newName);

				unset($str);
				unset($fileName);
				unset($newName);
			}
		}
		closedir($handle);
	}


function strposX($haystack,$needle,$number){
	if($number=='1'){
		return strpos($haystack,$needle);
	}elseif($number>'1'){
		return strpos($haystack,$needle,strposX($haystack,$needle,$number-1)+strlen($needle));
	}else{
		return error_log('Error: Value for parameter $number is out of range');
	}
}

?>
