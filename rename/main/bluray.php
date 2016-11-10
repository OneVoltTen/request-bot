<?php
	// Check BD/DVD
	if (strpos($str,'_BD')==true || stripos($str,'bluray')==true || stripos($str,'blu-ray')==true || stripos($str,'bdrip')==true || stripos($str,'brip')==true || stripos($str,'brrip')==true || stripos($str,'bray')==true){
	$disc="BD";
	$str=str_ireplace(array("bray","brrip","brip","bdrip","blu-ray","bluray","blu_ray","BD","dvd","dvdrip"),$str);
	}elseif(strpos($str,'DVD')==true){
		$disc="DVD";
	}