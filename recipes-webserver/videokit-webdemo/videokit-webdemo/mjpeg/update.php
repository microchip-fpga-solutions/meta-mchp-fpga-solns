<html>
<head>
	<title>Microchip MJPEG GUI Demo</title>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="pfsoc.css">
</style>
</head>
<body>		
<!--    <img src="microchip_logo.png" alt="Microchip" width="150" height="100"></br> -->
        <img src="mchp_logo2.png" alt="Microchip" width="187" height="100"></br>
	<h1 align=center style="background-color:powderblue;color:blue">MJPEG GUI</h1>

<?php
$brightness = $_REQUEST['brightness'];
$contrast = $_REQUEST['contrast'];
$qf = $_REQUEST['qf'];
$cbred = $_REQUEST['cbred'];
$cbgreen = $_REQUEST['cbgreen'];
$cbblue = $_REQUEST['cbblue'];
?>
<table align=center>
<tr></tr>
<tr align=center> <td>
<h2> Please wait while camera configurations are being updated... </h2>
</td></tr>
<tr> 
	<td> <b>Brightness : <?php echo $brightness ?> </td>
	<td> <b>Color Red  : <?php echo $cbred ?> </td>
</tr>
<tr> 
	<td> <b>Contrast   : <?php echo $contrast ?> </td>
	<td> <b>Color Green: <?php echo $cbgreen ?> </td>
</tr>
<tr> 
	<td> <b>Quality Factor: <?php echo $qf ?> </td>
	<td> <b>Color Blue: <?php echo $cbblue ?> </td>
</tr>
</table>
<?php
//echo "<h3>Current Values: </h3>";
//echo "<b>&emsp; Brightness: ".$brightness."</>";
//echo "<b>&emsp;&emsp;&emsp;   Color Balance Red: ".$cbred."<br />";
//echo "<b>&emsp; Contrast: ".$contrast."</>";
//echo "<b>&emsp;&emsp;&emsp;&ensp;&nbsp; Color Balance Green: ".$cbgreen."<br />";
//echo "<b>&emsp; Quality Factor: ".$qf."</>";
//echo "<b>&emsp;&nbsp; Color Balance Blue: ".$cbblue."<br />";
$myfile = fopen("update.sh", "w") or die("Unable to open file!");
$txt = "Brightness=".$brightness."\n";
fwrite($myfile, $txt);
$txt = "Contrast=".$contrast."\n";
fwrite($myfile, $txt);
$txt = "Quality=".$qf."\n";
fwrite($myfile, $txt);
$txt = "Color_Balance_Red=".$cbred."\n";
fwrite($myfile, $txt);
$txt = "Color_Balance_Green=".$cbgreen."\n";
fwrite($myfile, $txt);
$txt = "Color_Balance_Blue=".$cbblue."\n";
fwrite($myfile, $txt);
$txt = "/usr/bin/v4l2-ctl -d /dev/video0 --set-ctrl=quality_factor=".$qf." --set-ctrl=brightness=".$brightness." --set-ctrl=contrast=".$contrast." --set-ctrl=gain_red=".$cbred." --set-ctrl=gain_green=".$cbgreen." --set-ctrl=gain_blue=".$cbblue."\n";
//$txt = "/opt/microchip/multimedia/pic_ctrls/pic_ctrl -bt ".$brightness." -ct ".$contrast." -qt ".$qf." -rg ".$cbred." -gg ".$cbgreen." -bg ".$cbblue."\n";
//$txt = "/opt/microchip/mjpeg_gui_controls/mjpeg -b ".$brightness." -c ".$contrast." -q ".$qf." -cbr ".$cbred." -cbg ".$cbgreen." -cbb ".$cbblue."\n";
//$txt = "./mjpeg ".$brightness." ".$contrast." ".$qf." ".$cbred." ".$cbgreen." ".$cbblue."\n";
// /opt/microchip/pic_ctrls/pic_ctrl -rg 122 -gg 102 -bg 138 -bt 137 -ct 154 -qt 50
fwrite($myfile, $txt);
fclose($myfile);
?>

<?php
    	if(isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on')   
		$url = "https://";   
    	else  
		$url = "http://";   
    	$url.= $_SERVER['HTTP_HOST'];   
	$url.= $_SERVER['REQUEST_URI'];    
	$ip_server = $_SERVER['SERVER_ADDR'];
	echo shell_exec("sudo /srv/www/mjpeg/update.sh >/srv/www/mjpeg/messages 2>/srv/www/mjpeg/error_log &");

header('Refresh: 3; URL=http://'.$ip_server.'/mjpeg/index.htm?v_bright='.$brightness.'&v_contrast='.$contrast.'&v_qf='.$qf.'&v_red='.$cbred.'&v_green='.$cbgreen.'&v_blue='.$cbblue.'&stream=started');
exit();
?>

</body>
</html>
