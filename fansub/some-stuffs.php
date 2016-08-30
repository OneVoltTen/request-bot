<?php
if (stripos($fansub,'some-stuffs') !== false) {
	$underscore = substr_count($str, "_");
	$str = substr_replace($str, "_-_", strposX($str, "_", $underscore), 1);
}
?>
