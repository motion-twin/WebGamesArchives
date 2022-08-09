import flash.Key;


typedef Rocher = { > flash.MovieClip,
	var _rocherMove : flash.MovieClip;
}

import mt.kiroukou.math.MLib;

class Map {

	static var WIDTH = 300;
	static var HEIGHT = 250;
	static var ZBORDER = 50;
	static var SMIN = 10;
	static var THEIGHT = 40;
	static var MARROON = 0x572413;

	public var dmanager : mt.DepthManager;
	var bg : flash.MovieClip;
	var scroll : flash.MovieClip;
	var inf : flash.MovieClip;
	var text : {> flash.MovieClip, field : flash.TextField };
	var confirm : {>flash.MovieClip, yes:flash.MovieClip, no:flash.MovieClip, field:flash.TextField};
	var cache : flash.MovieClip;
	var onConfirm : Void->Void;
	var sx : Float;
	var sy : Float;
	var scale : Float;
	var textVisible : Bool;
	var wbounds : { xMin : Int, yMin : Int, xMax : Int, yMax : Int };
	public var blinks : Array<{t:Float, mc:flash.MovieClip}>;
	public var fl_moveMode : Bool;
	var dots : Array<flash.MovieClip>;
	var fl_lock : Bool;
	var fl_coord : Bool;
	var lang : String;

	public var places : Hash<Place>;
	var current : Place;

	var time : Float;
	public function new( scroll : flash.MovieClip, bg : flash.MovieClip, data : MapData ) {
		mt.flash.Key.enableForWmode();
		scale = 1.0;
		this.scroll = scroll;
		this.bg = bg;
		blinks = new Array();
		dots = new Array();
		fl_moveMode = true;
		fl_lock = false;
		fl_coord = false;
		lang = data._lang.toLowerCase();
		dmanager = new mt.DepthManager(scroll);
		dmanager.reserve(bg, 0);
		inf = dmanager.empty(0);
		if( data._zone == 9 ) {
			var rocher : Rocher = cast dmanager.attach("_rocher", 0);
			rocher._x = 450;
			rocher._y = 350;
			rocher.gotoAndStop( data._state + 1);
			var rmove = rocher._rocherMove;
			rmove.forceSmoothing  = true;
			function tweenMove( target : flash.MovieClip ) {
				var tx = MLib.randRangeSym(10);
				var ty = MLib.randRangeSym(10);
				var dist = Math.sqrt( (target._x - tx) * (target._x - tx) + (target._y - ty) * (target._y - ty) );
				mt.kiroukou.motion.Tween.tween(target).to( dist / 4, _x = tx, _y = ty )
													.fx( TZigZag )
													.onComplete(function(t) tweenMove(t.target) );
			}
			tweenMove(rmove);
		}
		places = new Hash();
		for( p in data._places ) {
			var p = new Place(this, p);
			places.set(p.id, p);
			if( p.id == data._cur )
				current = p;
		}
		
		var b = {
			xMin : current.px,
			xMax : current.px,
			yMin : current.py,
			yMax : current.py,
		}
		
		/*
		var b = {
			xMin : 0,
			xMax : Std.int(scroll._width),
			yMin : 0,
			yMax : Std.int(scroll._height),
		}
		*/
		for( n in data._nexts ) {
			var p = places.get(n._id);
			p.selectAsTarget(n._text, n._conf);
			if( p.px < b.xMin ) b.xMin = p.px;
			if( p.px > b.xMax ) b.xMax = p.px;
			if( p.py < b.yMin ) b.yMin = p.py;
			if( p.py > b.yMax ) b.yMax = p.py;
			inf.lineStyle(5, 0xffffff, 40);
			inf.moveTo(current.px,current.py);
			inf.lineTo(p.px, p.py);
			inf.endFill();
		}
		if( data._nexts.length==0 && Reflect.field(flash.Lib._root,"act") != null ) {
			bg.onMouseDown = onClick;
			bg.useHandCursor = true;
		}
		b.xMin -= ZBORDER;
		b.xMax += ZBORDER;
		b.yMin -= ZBORDER;
		b.yMax += ZBORDER;
		b.xMax -= WIDTH;
		b.yMax -= HEIGHT;
		if( b.xMin < 0 ) b.xMin = 0;
		if( b.yMin < 0 ) b.yMin = 0;
		var bounds = bg.getBounds(bg);
		bounds.xMax -= WIDTH;
		bounds.yMax -= HEIGHT;
		if( b.xMax > bounds.xMax ) b.xMax = Std.int(bounds.xMax);
		if( b.yMax > bounds.yMax ) b.yMax = Std.int(bounds.yMax);
		if( b.xMax - b.xMin < SMIN * 2 ) {
			var h = Std.int((b.xMax + b.xMin) / 2);
			if( h < SMIN ) h = SMIN else if( h > bounds.xMax - SMIN ) h = Std.int(bounds.xMax - SMIN);
			b.xMin = h - SMIN;
			b.xMax = h + SMIN;
		}
		if( b.yMax - b.yMin < SMIN * 2 ) {
			var h = Std.int((b.yMax + b.yMin) / 2);
			if( h < SMIN ) h = SMIN else if( h > bounds.yMax - SMIN ) h = Std.int(bounds.yMax - SMIN);
			b.yMin = h - SMIN;
			b.yMax = h + SMIN;
		}
		wbounds = b;
		current.selectAsCurrent();
		if( data._nexts.length == 0 ) {
			blinks.push( {mc:current.mc,t:0.0} );
			fl_moveMode = false;
		}
		text = cast flash.Lib.current.attachMovie("infos", "infos", 1);
		text._y = HEIGHT + THEIGHT;
		updateScroll(0);
		
		time = flash.Lib.getTimer();
	}

	public function loop() {
		mt.kiroukou.motion.Tween.updateTweens( 0.001 * (flash.Lib.getTimer() - time ) );
		time = flash.Lib.getTimer();
		
		if( mt.flash.Key.isDown(Key.ESCAPE) ) {
			if( mt.flash.Key.isDown("Z".charCodeAt(0)) ) {
				fl_coord = true;
				bg.onMouseDown = onClickCoord;
			}
		}
		if( fl_coord ) {
			var b = scroll.getBounds(scroll);
			scroll._x = -b.xMin;
			scroll._y = -b.yMin;
			var z = Math.max(
				(b.xMax - b.xMin) / WIDTH,
				(b.yMax - b.yMin) / HEIGHT
			);
			scroll._xscale = scroll._yscale = 100 / z;
			showText(Std.int(scroll._xmouse)+":"+Std.int(scroll._ymouse));
			return;
		}

		for( b in blinks ) {
			b.t += 0.2;
			var f;
			if( fl_moveMode ) {
				f = Math.abs(Math.sin(b.t));
			} else {
				f = Math.sin(b.t);
				if( f < 0 ) {
					f = 0;
				}
			}
			b.mc.filters = [new flash.filters.GlowFilter(0xffffff,f,5,5,5)];
		}
		updateScroll(0.7);
	}

	function updateScroll( k : Float ) {

		sx = wbounds.xMin + (wbounds.xMax - wbounds.xMin) * flash.Lib._root._xmouse / WIDTH + WIDTH / 2;
		sy = wbounds.yMin + (wbounds.yMax - wbounds.yMin) * flash.Lib._root._ymouse / HEIGHT + HEIGHT / 2;

		var swidth = scale * WIDTH;
		var sheight = scale * HEIGHT;
		var px = sx - swidth / 2;
		var py = sy - sheight / 2;
		var b = bg.getBounds(bg);
		var opx = px;
		if( px < b.xMin )
			px = b.xMin;
		else if( px + swidth > b.xMax )
			px = b.xMax - swidth;
		if( py < b.yMin )
			py = b.yMin;
		else if( py + sheight > b.yMax )
			py = b.yMax - sheight;

		var nx = Std.int(scroll._x * k + (1 - k) * -px / scale);
		var ny = Std.int(scroll._y * k + (1 - k) * -py / scale);
		var ns = scroll._xscale * k + (1 - k) * 100 / scale;

		if( nx != scroll._x || ny != scroll._y || ns != scroll._xscale ) {
			scroll._x = nx;
			scroll._y = ny;
			scroll._xscale = scroll._yscale = ns;
		}

		if( !textVisible ) {
			text._y = -100;
			/*text._y += 3;
			if( text._y > HEIGHT + THEIGHT )
				text._y = HEIGHT + THEIGHT;*/
		} else {
			text._x = flash.Lib._root._xmouse + 20;
			text._y = flash.Lib._root._ymouse;
			if( text._x + text.field.textWidth + 5 >= WIDTH ) {
				text._x = flash.Lib._root._xmouse - 8 - text._width;
			}
			text._y = Math.max(10, text._y);
			text._y = Math.min(HEIGHT-20, text._y);
			/*text._y -= 4;
			if( text._y < HEIGHT )
				text._y = HEIGHT;*/
		}
	}

	function drawLine( p : Place ) {
		for( d in dots ) {
			d.removeMovieClip();
		}
		dots = new Array();
		if( p == null ) {
			return;
		}

		var x : Float = current.px;
		var y : Float = current.py;
		var ang = Math.atan2(p.py - current.py, p.px - current.px);
		var dist = 0.0;
		do {
			dist = Math.sqrt(Math.pow(p.px-x, 2) + Math.pow(p.py-y, 2));
			var dot = dmanager.attach("dot", 1);
			dot._x = x;
			dot._y = y;
			dots.push(dot);
			x += Math.cos(ang) * 10;
			y += Math.sin(ang) * 10;
		} while(dist > 10);

		if( p == null )
			return;
	}

	public function show( p : Place ) {
		showText(p.text);
		if( p.target )
			drawLine(p);
	}

	function showText( txt : String ) {
		text.field.text = txt;
		if( text.field.textHeight < 20 ) {
			text.gotoAndStop(1);
		} else {
			text.gotoAndStop(2);
		}
		textVisible = true;
	}

	function lock() {
		fl_lock = true;
		cache = cast flash.Lib.current.attachMovie("cache", "cache", 2);
		cache._alpha = 50;
		Reflect.deleteField( bg, "onMouseDown" );
	}

	function showConfirm(txt:String) {
		cache = cast flash.Lib.current.attachMovie("cache", "cache", 2);
		cache._alpha = 50;

		confirm.removeMovieClip();
		confirm = cast flash.Lib.current.attachMovie("confirm", "confirm", 5);
		confirm._x = WIDTH * 0.5;
		confirm._y = HEIGHT * 0.5;
		confirm.field.text = txt;
		confirm.filters = [new flash.filters.GlowFilter(0x0, 1, 1,1, 3,3), new flash.filters.GlowFilter(MARROON, 0.8, 8,8, 1, 3) ];
		confirm.yes.filters = [new flash.filters.GlowFilter(MARROON, 0.8, 5,5, 1, 3)];
		confirm.no.filters = [new flash.filters.GlowFilter(MARROON, 0.8, 5,5, 1, 3)];
		var me = this;
		confirm.yes.onRollOver = function() { me.onOverConfirm(me.confirm.yes); };
		confirm.yes.onRollOut = function() { me.onOutConfirm(me.confirm.yes); };
		confirm.no.onRollOver = function() { me.onOverConfirm(me.confirm.no); };
		confirm.no.onRollOut = function() { me.onOutConfirm(me.confirm.no); };

		confirm.yes.onRelease = onConfirm;
		confirm.no.onRelease = hideConfirm;
	}

	function hideConfirm() {
		confirm.removeMovieClip();
		cache.removeMovieClip();
		confirm = null;
	}

	function onOverConfirm(mc:flash.MovieClip) {
		mc.filters = [ new flash.filters.GlowFilter(0xffffff, 1, 3,3, 5) ];
	}
	function onOutConfirm(mc:flash.MovieClip) {
		mc.filters = [ new flash.filters.GlowFilter(0x572413, 1, 5,5, 1, 3) ];
	}

	public function goto( p : Place, confirm : Bool ) {
		if( fl_lock || this.confirm != null ) return;
		if( confirm ) {
			var me = this;
			onConfirm = function() { me.executeGoto(p); };
			var nbsp = String.fromCharCode(160);
			if( lang == "es" )
				showConfirm("¿"+nbsp + p.text + nbsp+"?");
			else
				showConfirm(p.text + nbsp+"?");
		} else {
			executeGoto(p);
		}
	}

	function executeGoto(p:Place) {
		confirm.removeMovieClip();
		lock();
		for( pl in places ) {
			Reflect.deleteField( pl, "onRelease" );
		}
		flash.Lib.getURL(Reflect.field(flash.Lib._root, "goto")+p.id);
	}

	public function onClickCoord() {
		if( fl_coord ) {
			flash.System.setClipboard( Std.int(scroll._xmouse)+":"+Std.int(scroll._ymouse) );
		}
	}

	public function onClick() {
		if( fl_lock ) return;
		lock();
		flash.Lib.getURL( Reflect.field(flash.Lib._root,"act") );
	}

	public function hideText() {
		drawLine(null);
		textVisible = false;
	}
}
