cMax = 5;
pMax = 11;

function log(text) {
	flash.external.ExternalInterface.call("alert",text);
}

function decode62(n) {
	// 0-9
	if( n >= 48 && n <= 58 )
		return n - 48;
	// A-Z
	if( n >= 65 && n <= 90 )
		return n - 65 + 10;
	// a-z
	if( n >= 97 && n <= 122 )
		return n - 97 + 36;
	return 63;
}


// data is either "p0;p1;p2;..." or encoded "p0p1p3..." + damages (p2)

function _init(data,ch) {
	cl = data.split(";");
	var t = 1;
	for(var i=0;i<cl.length;i++) {
		var x = int(cl[i]);
		t = ((t * 11) ^ x) % 0x1FFFFF;
		cl[i] = x;
	}
	if( ch != null && ""+t != ch )
		return;
	if( palette == null || paletteIndex != cl[0] ) initPalette();
	applyRec(this);
}

function initPalette() {
	var pmc = this.attachMovie("palette","palinst",0);
	if( pmc == null )
		return;
	paletteIndex = cl[0];
	pmc.gotoAndStop(cl[0]%pmc._totalframes+1);
	var bounds = pmc.getBounds(pmc);
	var bmp = new flash.display.BitmapData(bounds.xMax,bounds.yMax);
	bmp.draw(pmc);
	pmc.removeMovieClip();
	palette = new Array();
	for( var i = 0; i < cMax; i++) {
		var pi = new Array();
		var py = i * 15 + 7;
		while( true ) {
			var c = bmp.getPixel32(pi.length * 15 + 7,py);
			if( c == 0 || c == -1 )
				break;
			pi.push(c & 0xFFFFFF);
		}
		palette.push(pi);
	}
	bmp.dispose();
}

function applyRec(mc) {
	for( var elem in mc ) {
		var e = mc[elem];
		if( typeof e == "movieclip" ) {
			if( e._name.substr(0,2) == "_p" ) {
				var pid = parseInt(e._name.substr(2));
				var frame = cl[pid]%e._totalframes;
				e.gotoAndStop( frame+1 );
			} else if( e._name.substr(0,4) == "_col" ) {
				var cid = parseInt(e._name.substr(4));
				var pal = palette[cid];
				setColor(e, pal[cl[pMax+cid]%pal.length]);
			}
			applyRec(e,pid);
		}
	}
}

function setColor(mc,col) {
	var c = {
		r:col>>16,
		g:(col>>8)&0xFF,
		b:col&0xFF
	}
	var co = new Color(mc)
	var ct = {
		ra:100,
		ga:100,
		ba:100,
		aa:100,
		rb:c.r-255,
		gb:c.g-255,
		bb:c.b-255,
		ab:0
	}
	co.setTransform(ct);
}

function sec(u) {
	while( true ) {
		var c = u.charCodeAt(0);
		if( c == 13 || c == 10 || c == 32 || c == 9 )
			u = u.substr(1);
		else
			break;
	}
	if( u.toLowerCase().substr(0,11) == "javascript:" )
		return null;
	return u;
}

if( _root.data != null && _root.chk != null ) {
	Stage.align = "TL";
	_init(_root.data,_root.chk);
	if( _root.flip == "1" ) {
		_p0b._xscale *= -1;
		_p0b._x = 95;
	}
	if( _root.stop == "1" )
		_p0b.sub.stop();
	if( _root.clic != null )
		_p0b.onPress = function() { getURL(sec(_root.clic),"_self"); };
	if( _root.head != null ) {
		_p0b._xscale *= 0.5;
		_p0b._yscale *= 0.5;
		_p0b._x -= 50;
		_p0b._y -= 8;
	}
}
