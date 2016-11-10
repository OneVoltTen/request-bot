<?php
	if (isset($disc) || (isset($argv[2]) && $argv[2]=="noV")){
		if (substr($str,-2,2)=="v2" || substr($str,-2,2)=="v3" || substr($str,-2,2)=="v4"){
			$str=str_ireplace('v2','',str_ireplace('v3','',str_ireplace('v4','',$str)));
		}
	}
	
	$str=str_replace('_v0','v0',$str);
	$str=str_replace('_v1','v1',$str);
	$str=str_replace('_v2','v2',$str);
	$str=str_replace('_v3','v3',$str);
	$str=str_replace('_v4','v4',$str);
	$str=str_replace('_v5','v5',$str);
	$str=str_replace('_v6','v6',$str);
	$str=str_replace('_v7','v7',$str);
	$str=str_replace('_v8','v8',$str);