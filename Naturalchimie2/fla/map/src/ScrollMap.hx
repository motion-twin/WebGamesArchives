import flash.Key ;
import mt.bumdum.Lib ;
import PopInfo.TypeInfo ;


class ScrollMap {
	
	public static var WIDTH = 500 ;
	public static var HEIGHT = 300 ;
	public static var SMIN = 5 ;
	public static var THEIGHT = 40 ;
		
	
	static var DEFAULT_LINK = "/act/map" ;
	static var GOTO_LINK = "/act/move?to=" ;
	static var TELEPORT_LINK = "/act/tp?to=" ;
	
	public var bg : flash.MovieClip;
	public var scroll : flash.MovieClip;
	var sx : Float ;
	var sy : Float ;
	var scale : Float ;
	public var wbounds : { xMin : Float, yMin : Float, xMax : Float, yMax : Float } ;
	public var center : {x : Float, y : Float} ;
	var textVisible : Bool;
	var map : Map ;
	public var dmanager : mt.DepthManager;
	var fl_lock : Bool ;
	var fl_coord : Bool ;
	public var fl_moveMode : Bool ;
	var text : {> flash.MovieClip, mc : {>flash.MovieClip, field : flash.TextField , _pa : {> flash.MovieClip, _field : flash.TextField}}} ;
	public var dmt : mt.DepthManager;
	var inf : flash.MovieClip;
	public var blinks : Array<{t:Float,mc:flash.MovieClip, c : Int}> ;
	var dots : Array<flash.MovieClip> ;
	var bf : Int ;
	public var ba : { xMin : Float, yMin : Float, xMax : Float, yMax : Float } ;
	public var noMove : Bool ;
	public var farView : Bool ;
	
	public var userViewer : Display ;
	public var mcDisplay : flash.MovieClip ;
	public var mcUser : {>flash.MovieClip, _bmp : flash.display.BitmapData} ;
	
	
	
	public var places : Hash<Place> ;
	public var current : Place ;
	public var dcoords : {x : Float, y : Float} ;

	
	
	public function new(m : Map) {
		map = m ;
		scale = 0.5 ;
		fl_moveMode = true;
		fl_lock = false;
		fl_coord = false;
		bf = 8 ;
		noMove = false ;
		farView = false ;
		text = cast m.mdm.empty(Map.DP_TEXT) ;
		dmt = new mt.DepthManager(text) ;
		text.mc = cast dmt.attach("infos",5) ;
		text.mc.filters = [new flash.filters.DropShadowFilter(1,75, 0x000000,0.4,2, 2, 3)] ;
		text._y = HEIGHT + THEIGHT ;
		//text._xscale = text._yscale = 75 ;
	}
	
	public function getZBorder() : Int {
		return if (farView) 210 else 50 ;
	}
	
	
	public function loop() {
		if( mt.flash.Key.isDown(Key.ESCAPE) ) {
			if( mt.flash.Key.isDown("Z".charCodeAt(0))) {
				fl_coord = true;
				bg.onMouseDown = onClickCoord;
			}
		}
		if ( fl_coord ) {
			showText(Std.int(bg._xmouse * 100 / 125)+":"+Std.int(bg._ymouse * 100 / 125));
			return;
		}
		
		for (b in blinks) {
			b.t+=0.17;
			var f;
			if ( fl_moveMode ) {
				f = Math.abs(Math.sin(b.t));
			}
			else {
				f = Math.sin(b.t);
				if ( f<0 )
					f=0;
			}
			//b.mc.filters = [new flash.filters.GlowFilter(b.c,0.4 + 0.6 * f, 2 + 4 * f, 2 + 4* f, bf, 2, false, true)] ;
			
			b.mc.filters = [
				new flash.filters.GlowFilter(0xFFFDD1,0.6+ 1*f ,1.3+ 1*f ,1.3+ 1*f ,10, 2, true, true),
				new flash.filters.GlowFilter(b.c,0.6,6.4+ 8*f,6.4+ 8*f,2+ 1.5*f, 2, false, false)
				] ;
			
			//b.mc._alpha = f * 25 ;
			//trace(b.mc._alpha) ;
		}
	}
	
	
	
	function resetBlinks() {
		for (b in blinks) {
			Place.setDefaultGlow(b.mc, b.c) ;
		}
		blinks = [] ;
	}
	
	function setBlinks(m, ?c = 0xffffff) {
		resetBlinks() ;
		blinks.push( {mc:m,t:0.0, c : c} );
	}
	
	
	public function mouseScroll() {
		var trg = null ;
		
		if (Map.me.scroll._xmouse == 0 && Map.me.scroll._ymouse == 0)
			return ;

		var ma = 40 ;
		var speed = 30 ;
		var vx = 0 ;
		var vy = 0 ;
		if( Map.me.root._xmouse < ma )
			vx += speed ;
		if (Map.me.root._xmouse > WIDTH - ma) 
			vx -= speed ;
		if (Map.me.root._ymouse < ma) 
			vy += speed ;
		if (Map.me.root._ymouse > HEIGHT - ma)
			vy -= speed ;
				
		var bi = {xMin : -Map.me.scroll._x - Map.me.bg._x,
				xMax : -Map.me.scroll._x - Map.me.bg._x + WIDTH,
				yMin : -Map.me.scroll._y - Map.me.bg._y,
				yMax : -Map.me.scroll._y - Map.me.bg._y + HEIGHT
		} ;
		
		
		
		var a = HEIGHT - wbounds.yMax ;
		var b = bg._y + vy + Map.me.scroll._y ;
		var c = Map.me.scroll._y -wbounds.yMin ;
		
		trg = {
			x : Num.mm(WIDTH -wbounds.xMax, bg._x + vx + Map.me.scroll._x, Map.me.scroll._x -wbounds.xMin),
			y : Num.mm(a, b, c)
		}
		trg.x = Num.mm(WIDTH - bg._width - Map.me.scroll._x, trg.x, 0 ) ;
		trg.y = Num.mm(HEIGHT -bg._height - Map.me.scroll._y, trg.y, 0 ) ;
		
		
		/*if (Key.isDown(Key.SPACE)) {
			trace(trg.x + " ### " + a + ", " + b + ", " + c + " ########## " + Map.me.scroll._x) ;	
		}*/
		
		var noFocus = false ;
		if (trg == null /*|| (vx == 0 && vy == 0)*/ || (trg.x == 0 && trg.y == 0))
			noFocus = true ;
		
		if (!fl_coord && !noFocus && !noMove) {
			var c = 0.3 ;
			var lim = 50 ;
			var dx = trg.x- bg._x ;
			var dy = trg.y- bg._y ;
			bg._x += Num.mm(-lim,dx,lim)* c ;
			bg._y += Num.mm(-lim,dy,lim)* c ;
			

			if( Math.abs(dx)<1 ) bg._x = trg.x;
			if( Math.abs(dy)<1 ) bg._y = trg.y;
		}
		
		if( !textVisible )
			text._y = -100;
		else {
			text._x = flash.Lib._root._xmouse+20;
			text._y = flash.Lib._root._ymouse;
			if ( text._x+text._width+5>=WIDTH ) {
				text._x = flash.Lib._root._xmouse-8-text._width;
			}
			text._y = Math.max(10,text._y);
			text._y = Math.min(HEIGHT-20,text._y);
		}
	}
	
	
	
	public function showUser(p : Place) {
		
		var face = Reflect.field(flash.Lib._root,"face") ;
		
		mcDisplay = Map.me.dm.empty(10) ;
		mcDisplay._alpha = 0 ;
		mcDisplay._x = mcDisplay._y = -1000 ;
		
		
		mcUser = cast Map.me.rMap.dmanager.empty(5) ;
		mcUser._x = p.mc._x ;
		mcUser._y = p.mc._y ;
		//mcUser._alpha = 0 ;
		
		userViewer = new Display(mcDisplay) ;
		userViewer.extraTypeView = 1 ;
		userViewer.initPerso(0,0,face, initUserDisplay) ;
	}
	
	
	public function initUserDisplay() {
		
		userViewer.update() ;
		userViewer.update() ;
	
		var cm = new flash.filters.ColorMatrixFilter( [0.678610265254974,0.389040946960449,0.0523488000035286,0,12.5399971008301,0.19701024889946,0.870640933513641,0.0523488000035286,0,12.5399971008301,0.19701024889946,0.389040946960449,0.53394877910614,0,12.5399971008301,0,0,0,1,0] );

		 userViewer.MCalchemist._alchemist._p0.filters = [
			cm,
			new flash.filters.GlowFilter(0xFFFDD1,0.9,1.3,1.3,8, 3, false, false),
			new flash.filters.GlowFilter(0xFCF89C,0.6,1.3,1.3,4, 2, false, false)
			];


		var sc = 0.18 ;
		
		mcUser._bmp = new flash.display.BitmapData(Std.int(200 * sc), Std.int(322 * sc),true,0);
		
		var m = new flash.geom.Matrix();
		m.scale(sc, sc) ;
		
		mcUser._bmp.draw(mcDisplay, m, null, "normal") ;
		
		mcUser.attachBitmap(mcUser._bmp, 1) ;
		  
		mcUser._x -= mcUser._width / 2 ;
		mcUser._y -= mcUser._height / 2  ;
		
		mcDisplay.removeMovieClip() ;
		userViewer = null ;
	}
	
	
	public function setToCenter(?c : {x : Float, y : Float}, ?move : Bool) {
		if (move == null)
			move = false ;
		
		if (center == null && c == null)
			return ;
		
		center = c ;
		
		sx = center.x ;
		sy = center.y ;
		
		var swidth = scale * WIDTH;
		var sheight = scale * HEIGHT;
		var px = sx - swidth / 2;
		var py = sy - sheight / 2;
		var b = bg.getBounds(bg) ;
		var opx = px;
		if( px < b.xMin )
			px = b.xMin;
		else if( px + swidth > b.xMax )
			px = b.xMax - swidth;
		if( py < b.yMin )
			py = b.yMin;
		else if( py + sheight > b.yMax )
			py = b.yMax - sheight;

		var nx = Std.int(-px / scale);
		var ny = Std.int(-py / scale);
		var ns = /*100 / scale ;*/ 100 / 1.0 ;
		
		
		if((move) && (nx != bg._x || ny != bg._y || ns != scroll._xscale)) {
			bg._x = nx + scroll._x ;
			bg._y = ny + scroll._y ;
			scroll._xscale = scroll._yscale = ns;
		}
	}


	
	public function onClickCoord() {
		if ( fl_coord ) {
			flash.System.setClipboard( Std.int(bg._xmouse * 100 / 125)+":"+Std.int(bg._ymouse * 100 / 125) );
		}
	}
	
	
	function showText( txt : String, ?p : Place) {
		text.mc.field.text = txt;
		
		if (p == null || !p.objects)
			text.mc.gotoAndStop(2) ;
		else
			text.mc.gotoAndStop(1) ;
		
		text.mc.field._y = -2 ;
		text.mc.smc._y = 30 ;
		
		if (p != null && p.target) {
			text.mc._pa._field.text = Std.string(p.pa) ;
			text.mc._pa._alpha = 100 ;
		} else
			text.mc._pa._alpha = 0 ;
		
		
		if (text.mc.field.textHeight<20 ) {
			text.mc.field._y = 6 ;
		} else {
			text.mc.smc._y = text.mc.field.textHeight ;
		}
		textVisible = true;
		if (p != null && Map.me.toMoveChain != null && !Map.me.toMoveChain && p != Map.me.chainPlace)
			Map.me.showChain(p) ;
	}
	
	public function show( p : Place ) {
		if ( map.loader.isLocked() || fl_lock ) return;
		
		showText(p.text, p) ;
			
		highlightRoad(p) ;
	}
	
	public function highlightRoad(p : Place) {
		if ( p.target ) {
			drawLine(p) ;
			setBlinks(p.mc, p.gColor) ;
		}
		
	}
	
	
	function drawLine( pl : Place ) {
		for (d in dots) {
			d.removeMovieClip();
		}
		dots = new Array();
		
		if ( pl==null )
			return ;
		var pfrom = if (pl.from != null) pl.from else current ;
		
		
		
		while (pfrom != null) {
			var road = if (pl.road == null) [[pfrom.px, pfrom.py], [pl.px, pl.py]] else pl.road ;
			var p1 = road[0] ;
			var p2 = road[1] ;
			var i = 1 ;
			while (i < road.length) {
				var x : Float = p1[0];
				var y : Float = p1[1] ;
				var ang = Math.atan2(p2[1] - p1[1], p2[0] - p1[0]) ;
				
				var dist = Math.sqrt(Math.pow(p2[0] - x, 2) + Math.pow(p2[1] - y, 2)) ;
				
				var between = 12 ;
				
				var p = Math.floor(dist / between) + 1 ;
				var r = dist - (p * between) ;
				if (r > 15)
					p-- ;
				var n = dist / p ;
				
				var dang = 180 * ang / 3.14 + 90 ;
				
				var frame = 0 ;
				
				for (i in 0...p) {
					dist = Math.sqrt(Math.pow(p2[0] - x, 2) + Math.pow(p2[1] - y, 2)) ;
					var dot = dmanager.attach("dot", 4) ;
					dot.gotoAndStop(1) ;
					dot._rotation = dang ;
					dot.smc.gotoAndStop(frame + 1) ;
					frame = ((frame + 1) % 5) ;
					
					switch(pl.pa) {
						case 0 : Col.setPercentColor(dot, 100, 0x3dc601) ;
						case 1 : //nothing to do
						//case 2 : Col.setPercentColor(dot, 40, 0xf6a42e) ;
						//default : Col.setPercentColor(dot, 40, 0xf41e13) ;
					}
					
					dot._x = x ;
					dot._y = y ;
					dots.push(dot) ;
					x += Math.cos(ang) * n ;
					y += Math.sin(ang) * n ;
				}
				
				i++ ;
				p1 = p2 ;
				p2 = road[i] ;
			}
			
			if (pfrom == current) 
				break ;
			else {
				pl = pfrom ;
				pfrom = if (pl.from != null) pl.from else current ;
			}
		}
	}
	
	
	public function setBounds(b : Dynamic, ?c : {x : Float, y : Float}) {
		if (c != null)
			center = c ;
		
		var intra = true ;
		
		
		if (center != null) {
			var bi = {xMin : center.x - WIDTH / 2,
				xMax : center.x + WIDTH / 2,
				yMin : center.y - HEIGHT / 2,
				yMax : center.y + HEIGHT / 2
			}
			
			if (bi.xMin < b.xMin) {
				intra = intra && Math.abs(b.xMin - bi.xMin) > getZBorder() ;
				//trace("intra 1 " + intra) ;
				b.xMin = bi.xMin ;
			} else intra = false ;
			if (bi.yMin < b.yMin) {
				intra = intra && Math.abs(b.yMin - bi.yMin) > getZBorder() ;
				//trace("intra 2 " + intra) ;
				b.yMin = bi.yMin ;
			} else intra = false ;
			if (bi.xMax > b.xMax) {
				intra = intra && Math.abs(bi.xMax - b.xMax) > getZBorder() ;
				//trace("intra 3 " + intra) ;
				b.xMax = bi.xMax ;
			} else intra = false ;
			if (bi.yMax > b.yMax) {
				intra = intra && Math.abs(bi.yMax - b.yMax) > getZBorder() ;
				//trace("intra 4 " + intra) ;
				b.yMax = bi.yMax ;
			} else intra = false ;
		}
		
		if (!intra) {
			b.xMin -= getZBorder() ;
			b.xMax += getZBorder() ;
			b.yMin -= getZBorder() ;
			b.yMax += getZBorder() ;
		}
		
		var sb = Map.REGION_SCALE / 100 ;
		
		b.xMin = b.xMin * sb ;
		b.xMax = b.xMax * sb ;
		b.yMin = b.yMin * sb ;
		b.yMax = b.yMax * sb ;
		
		
		if( b.xMin < 0 ) b.xMin = 0 ;
		if( b.yMin < 0 ) b.yMin = 0 ;
		if( b.xMax > Map.me.mWidth) b.xMax = Std.int(Map.me.mWidth) ;
		if( b.yMax > Map.me.mHeight) b.yMax = Std.int(Map.me.mHeight) ;
			
		//trace(b) ;
		
		/*var n = dmanager.empty(12) ;
		n.beginFill(1, 20) ;
		n.moveTo(b.xMin, b.yMin) ;
		n.lineTo(b.xMax, b.yMin) ;
		n.lineTo(b.xMax, b.yMax) ;
		n.lineTo(b.xMin, b.yMax) ;
		n.lineTo(b.xMin, b.yMin) ;
		n.endFill() ;*/
		
		wbounds = b ;
	}
	
	
	public function hideText() {
		if ( map.loader.isLocked() || fl_lock ) return;
		hideRoad() ;
		textVisible = false;
		text._y = -200;
		
		if (Map.me.toMoveChain != null) {
			Map.me.hideChain() ;
		}
		
	}
	
	
	public function hideRoad() {
		resetBlinks() ;
		drawLine(null);
	}
	
	public function goto( p : Place, confirm : Bool ) {
		if ( map.loader.isLocked() || fl_lock ) return;
		/*if( !confirm || flash.external.ExternalInterface.call("mapConfirm") == true ) {
			lock();
			for (pl in places ) {
				Reflect.deleteField( pl, "onRelease" );
			}
			flash.Lib.getURL(GOTO_LINK+p.id);
		}*/
		
		if (p.pa > 0 && map.data._pa < p.pa) {
			if ((cast Map.me).info != null)
				(cast Map.me).info.kill() ;
			(cast Map.me).info = new PopInfo(if (Map.me.data._ppa > 0) MorePa else if (map.data._siflex) Chouettex else Tired, /*Map.me.rMap*/cast p.map, Map.me.rMap.ba, p) ;
		} else 
			callMove(p, confirm, false) ;
		
		
	}
	
	
	public function callMove(p : Place, confirm : Bool, pa : Bool) {
		//trace("callMove " + pa) ;
		if (!confirm || flash.external.ExternalInterface.call("mapConfirm") == true ) {
			lock();
			for (pl in places ) {
				//trace("delete on " + pl.text) ;
				Reflect.deleteField( pl, "onRelease" );
			}
			Map.me.loader.initLoading(1) ;
			flash.Lib.getURL(GOTO_LINK+p.id + (if (pa) "&p=1" else ""));
		}
	}
	
	public function teleport(id : String, confirm : Bool) {
		if ( map.loader.isLocked() || fl_lock ) return;
		if( !confirm || flash.external.ExternalInterface.call("mapConfirm") == true ) {
			lock();
			Map.me.rMap.noMove = false ;
			Map.me.loader.initLoading(1) ;
			for (pl in places ) {
				Reflect.deleteField( pl, "onRelease" );
			}
			flash.Lib.getURL(TELEPORT_LINK+id);
		}
	}
	
	
	
	public function lock() {
		fl_lock = true;
		var cache = cast flash.Lib.current.attachMovie("cache","cache",2);
		cache._alpha = 50;
		Reflect.deleteField( bg, "onMouseDown" );
	}
	

	public function onClick() {
		if ( fl_lock ) return;
		lock();
		flash.Lib.getURL(DEFAULT_LINK);
	}
	
	
	public function kill() {
		if (text != null)
			text.removeMovieClip() ;
		blinks = [] ;
		if (dots != null) {
			for (d in dots)
				d.removeMovieClip();
		}
		
		if (places != null) {
			for (p in places)
				p.kill() ;
		}
		
		if (map != null)
			return ;
		
		if (bg != null)
			bg.removeMovieClip() ;
		if (scroll != null)
			scroll.removeMovieClip() ;
	}



	
}