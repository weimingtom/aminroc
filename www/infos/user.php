<?php
	header("Content-Type:text/html;charset=utf-8");
	header("Expires:Mon, 26 Jul 1997 05:00:00 GMT");
	header("Pragma:no-cache");
	header("Cache-Control:no-cache");
	
	session_start();
	define('MAX_USER_NAME_LEN',10);
	

	if($_GET['get']){
		if(isset($_SESSION['nickname'])){
			echo("{nickname:'" . $_SESSION['nickname'] . "'}");
		}
		else{
			echo('');
		}
	}
	else{
		$nickname = js_unescape($_COOKIE['nickname']);
		if($nickname){
			$_SESSION['nickname'] = substr($nickname,0,MAX_USER_NAME_LEN);
		}
		else{
			$_SESSION['nickname'] = $_SERVER['REMOTE_ADDR'];
		}
		header('Location:../play.html');
	}
	
	function js_unescape($str)
	{
		$ret = '';
		$len = strlen($str);
		
		for ($i = 0; $i < $len; $i++){
			if ($str[$i] == '%' && $str[$i+1] == 'u'){
				$val = hexdec(substr($str, $i+2, 4));
				if ($val < 0x7f) $ret .= chr($val);
				else if($val < 0x800) $ret .= chr(0xc0|($val>>6)).chr(0x80|($val&0x3f));
				else $ret .= chr(0xe0|($val>>12)).chr(0x80|(($val>>6)&0x3f)).chr(0x80|($val&0x3f));
				$i += 5;
			}
			else if ($str[$i] == '%'){
				$ret .= urldecode(substr($str, $i, 3));
				$i += 2;
			}
			else{
				$ret .= $str[$i];
			}
		}
		return $ret;
	}
?>