<?php
	// Remove extension
	$extension=substr($str,-3,3);
	$str=substr($str,0,-4);

	include "main/baseid.php";

	// Linux filename dupe/copy test remove (tests)
	$str = str_replace(array("(1)","(2)", "(copy)", "x264", "856x480", "|"), "", $str);
	$str = str_replace('é', 'e', $str);
	$str = str_replace('à', 'a', $str);
	$str = str_replace('μ', 'u', $str);

	// remove end CRC32
	if (substr($str,-1,1)=="]" && substr($str,-10,-9)=="["){
		$str=substr($str,0,-10);
	}
	if (substr($str,-1,1)==")" && substr($str,-10,-9)=="("){
		$str=substr($str,0,-10);
	}
	
	// remove text between 'apostrophe'
	$str=preg_replace("/'[\s\S]+?'/", '', $str);
	// strip whitespaces
	$str=ltrim(rtrim($str));
	// Replaces multiple spaces with a space
	$str=preg_replace('/\s+/',' ',$str);
	// Replaces long dash with normal dash
	$str=str_replace('‒','-',$str);
	// Replaces all & with an "and"
	$str=str_replace('&','and',$str);

	$str = str_ireplace(array("~"," ",".","_ep","24fps"), '_', $str);
	
	include "main/fansub.php";
	include "main/resolution.php";

	// remove delimiter
	$dash=substr_count($str,'_-_');
	// Replaces all weird characters with an underscore
	$str=preg_replace('/[^A-Za-z0-9@\_+.,-]/','_',$str);
	$str=str_ireplace(array("final","dual_audio"),$str);

	include "main/bluray.php";

	// Removes year, video depth/codec, audio codec, misc
	$str=str_ireplace(array("2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","8bit","8-bit","10bit","10-bit","Hi10p","Hi10","H10P","Hi444PP","h264","h.264","h_264","x264","x.264","x_264","h265","h.265","h_265","x265","hevc","xvid","aac","flac","ac3","opus","ogg","vorbis","-fansubs","fansubs","fansub","_copy","_remastered","BS11","_Web_"),"",$str);

	// Remove all weird characters
	$fansub=preg_replace('/[^A-Za-z0-9@&\_+.,-]/','',$fansub);
	// Replaces all weird characters with an underscore
	$str=preg_replace('/[^A-Za-z0-9@\_+.,-]/','_',$str);
	// Replaces multiple underscores with an underscore
	$str=preg_replace('/[_]+/','_',$str);
	// Strip underscores
	$str=ltrim(rtrim($str,"_"),"_");
	// Strip dash
	$str=ltrim(rtrim($str,"-"),"-");
	// Replaces multiple
	//$str=preg_replace('/[_-_]+/','_-_',$str);

	include "main/revision.php";
	
	$str = str_replace("_s_", "s_", $str);

	if (isset($disc)){
		$str=$anime."AnimePahe_".$str."_".$disc."_".$resolution."_".$fansub.".".$extension;
	} else {
		$str=$anime."AnimePahe_".$str."_".$resolution."_".$fansub.".".$extension;
	}

	$newName=$str;
	echo $fileName." =>\n".$newName."\n";
	rename($fileName,$newName);
	rename(DOWNLOADS."/".$newName, QUEUE."/".$newName);

	unset($str);unset($disc);unset($resolution);unset($resX);unset($resY);unset($scaledResX);unset($scaledResY);unset($extension);
	sleep(.2);