<?php
if (stripos($str,'doremi') !== false) {
	$str = str_replace('.', '_', $str);
	$str = str_replace('Episode', '-', $str);
}

