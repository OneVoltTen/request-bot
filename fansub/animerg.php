<?php // This fansubs naming sucks
$fansub="AnimeRG";
$str=str_ireplace('Eng_Sub_','',$str);
$str=str_ireplace('Multi_Subbed_','',$str);
$str=str_ireplace('Multi-Sub','',$str);
$str=preg_replace("/\(([^()]*+|(?R))*\)/","", $str);

//Remove the last [] because it usually contains fansub name
$data = explode("[" , rtrim($fileName, "]"));
$data = array_pop($data);
$data = array_shift(explode(']', $data));
print($data)."\n";
$str=str_ireplace($data,'',$str);

?>
