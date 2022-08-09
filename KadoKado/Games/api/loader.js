double = false;
if( file == null ) file = 'game.swf';

function toggleDouble() {
	double = !double;
	var fl = window.document["loader"];
	var x = double ? 2 : 1;
	fl.width = 300 * x;
	fl.height = 320 * x;
	fl.setDouble(double);
}

var str = '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" width="300" height="320" align="middle" id="loader">';
str += '<param name="allowScriptAccess" value="always"/>';
str += '<param name="quality" value="high"/>';
str += '<param name="scale" value="noscale"/>';
str += '<param name="wmode" value="opaque"/>';
str += '<param name="bgcolor" value="#ffffff"/>';
str += '<param name="FlashVars" value="swf=swf/'+file+'"/>';
str += '<param name="movie"	value="../api/loader.swf"/>';
str += '<embed src="../api/loader.swf" name="loader" quality="high" wmode="opaque" scale="noscale" bgcolor="#ffffff" width="300" height="320" align="middle" allowScriptAccess="always" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"';
str += ' FlashVars="swf=swf/'+file+'"/>';
str += '</object>';
document.write(str);
document.write('<p><a href="#" onclick="toggleDouble(); return false;">Double</a></p>');

