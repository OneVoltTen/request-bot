<?php

$path = "/var/www/uploaded/";
if ($handle = opendir($path)) {
	chdir($path);
	while (false !== ($fileName = readdir($handle))) {
		if (($fileName != "." && $fileName != ".." && (strtolower(substr($fileName, strrpos($fileName, '.') + 1)) == 'mkv' || strtolower(substr($fileName, strrpos($fileName, '.') + 1)) == 'mp4'))) {
			$str = $fileName;

			// Replaces all spaces with an underscore
			$str = str_replace('AnimePahe_', '', $str);
			$str = str_replace('mp4', 'mkv', $str);
			$newName = $str;
			//echo $fileName." => ".$newName."\n\n";
			rename($fileName, $newName);

			unset($str);
		}
	}
}

$path = "/var/www/downloads/";
if ($handle = opendir($path)) {
	chdir($path);
while (false !== ($fileName = readdir($handle))) {
		if (($fileName != "." && $fileName != ".." && (strtolower(substr($fileName, strrpos($fileName, '.') + 1)) == 'mkv' || strtolower(substr($fileName, strrpos($fileName, '.') + 1)) == 'mp4'))) {
			$str = $fileName;

			// Replaces all spaces with an underscore
			$str = str_replace('AnimePahe_', '', $str);
			$str = str_replace('mp4', 'mkv', $str);
			$newName = $str;
			//echo $fileName." => ".$newName."\n\n";
			rename($fileName, $newName);

			unset($str);
		}
	}
}

closedir($handle);
?>
