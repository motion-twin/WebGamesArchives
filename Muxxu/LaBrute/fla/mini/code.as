pMax = 11;

var defpal = [
	0xFFF2DF,
	0xFFCC79,
	0xFFAA1E,
	0xECFFD9,
	0xCBFF97,
	0xD5EAFF,
	0x97CBFF,
	0x8BA3D7,
	0xDF7E37,
	0xB85F1D,
	0xD31818,
	0xFFF9AE,
	0xF0DC99
];

palette = [defpal,defpal,defpal,defpal,defpal];


// data is either "p0;p1;p2;..." or encoded "p0p1p3..." + damages (p2)

function _init(data,tch) {
	cl = data.split(";");
	var tt = 0;
	for(var i=0;i<cl.length;i++) {
		var x = int(cl[i]);
		tt = ((tt * 11) ^ x) & 0x1FFFF;
		cl[i] = x;
	}
	if( tch != tt ) return tt;
	initPalette();
	apply();
	return -1;
}

function initPalette() {
	var pmc = this.attachMovie("palette","palinst",0);
	if( pmc == null )
		return;
	pmc.gotoAndStop(cl[0]%pmc._totalframes+1);
	var bounds = pmc.getBounds(pmc);
	var bmp = new flash.display.BitmapData(bounds.xMax,bounds.yMax);
	bmp.draw(pmc);
	pmc.removeMovieClip();
	var count = palette.length;
	palette = new Array();
	for( var i = 0; i < count; i++) {
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

function apply() {
	applyRec(this);
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


_