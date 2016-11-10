<?php
	$baseid = basename($str);
	$fn=explode('|', $baseid);
	if(!empty($fn[0]) && !empty($fn[1])){
		$anime=$fn[0];
		$fansub=$fn[1];
	}
	$str=strstr($str, '|');$str=strstr($str, '|');