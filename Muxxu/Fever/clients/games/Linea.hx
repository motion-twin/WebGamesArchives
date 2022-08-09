import flash.display.BitmapData;
import flash.display.MovieClip;
import mt.bumdum9.Lib;

typedef EMC = {>flash.display.MovieClip, color : Int, stopped : Bool, started : Bool, linked : Bool, a : Float, prevX : Int, prevY : Int }
typedef OBJECT = {>EMC, line : Bool, bonus: Bool, vscroll : Float, added : Bool, camper : Bool, lineDone : Bool }

class Linea extends Game{

	var scroller : Scroller;
	var dotter : Dotter;
	var xspeed : Float;
	var yspeed : Float;
	var count : Int;
	var baseCount : mt.flash.Volatile<Int>;
	var scroll : Int;
	var frontier : Float;
	var objects : Array<OBJECT>;
	var arma : Bool;
	var gameOver : Int;
	var theme : Int;
	var line : flash.display.MovieClip;
	var finish : flash.display.MovieClip;
	var camper : Int;

	override function init(dif:Float){
		gameTime = 240;
		super.init(dif);
		camper = 0;
	
		scroller = new Scroller( cast box, Cs.mcw, Cs.mch );
		dotter = new Dotter( dm.empty( 1 ), Cs.mcw,Cs.mch, 0, 0, Std.int( Cs.mch / 2 ), 5 );
		scroller.addLayer( untyped __unprotect__("mcLineaBg") );
		scroll = Math.ceil( dif * 2 + 5 );
		dotter.addDot( getRandomColor(true) );
		objects = new Array();
		baseCount = 8 - Std.int( 2 * dif );
		count = baseCount;
		finish = dm.attach("mcLineaFinish", 1 );
		finish.gotoAndStop(1);
		finish.y = Cs.mcw / 2;
		frontier = Math.min( Cs.mcw/2 + dif*( Cs.mcw / 3 ) - 10, Cs.mcw - finish.width );
		finish.x = frontier;
//		finish._alpha = 20;
		theme = Std.random( Colorss.DOTCOLORS.length );
		line = dm.empty(1);
		line.graphics.lineStyle( 1, getRandomColor(true), 70);
		line.graphics.moveTo(frontier, 0);
		line.graphics.lineTo(frontier,Cs.mch);
		var f = new flash.filters.GlowFilter();
		f.color = 0xFFFFFF;
		f.blurX = 2;
		f.blurY = 2;
		line.filters = [f];
		arma = false;
		step = 1;
		gameOver = 10;
	}

	override function update(){
		switch( step ) {
			case 1 :
				scrollObjects();
				var first = dotter.getFirst();
				var pos = getMousePos();
				var dy = 0;
				if( first != null ) dy = Std.int( (pos.y - first.y ) / 5);
				if( dy == 0 ) {
					camper++;
				}
				var dx = 3;
				dotter.updateSpeed( dx, dy );
				scroller.update(1, 1, 0 );
				dotter.update( 1, 0, 1, function(d){} );
			case 2 :
				if( gameOver-- < 0 ) {
					setWin( false,4 );
				}
		}
		super.update();
	}

	function scrollObjects() {

		if( camper > 30 ) addObject();

		if( objects.length <= 0 ) {
			addObject();
		}

		if( count-- <0 ) {
			count = baseCount;
			addObject();
		}

		var first = dotter.getFirst();
		if( first.x > frontier ) {
			setWin(true,15);

			if(!arma ) {
				new mt.fx.Flash(line);
				//fxFlash( line, 100, 1 );
				finish.gotoAndStop(2);
				arma = true;
			}
			
			while( objects.length > 0 ) {
				var obj = objects.pop();
				new mt.fx.Vanish(obj,10+Std.random(8));
			}
			
			return;
		}

		for( i in 0...objects.length ) {
			var p = objects[i];

			if( p == null ) {
				objects.remove( p );
				continue;
			}

			if( !p.stopped ) {
				p.x -= ( scroll + p.vscroll );
				p.x = p.x;
			}

			// disparition des blocks
			if( p.x + p.width < 0 ) {
				p.parent.removeChild(p);
				objects.remove( p );
				continue;
			}

			if( (p.x - first.x ) <= 1 && first.x <= p.x + p.width ) {
				if( hit(p, first.x, first.y ) ) {
					fxShake( 3 );
					new mt.fx.Flash( p );
					dotter.remove( first.uid );
					step = 2;
					blow( first.x, first.y, 0xFFFFFF );
					p.stopped = true;
				}
			}
				
		}
	}

	function blow( x, y, color, max = 15 ) {
		var r = 2;
		var a = 360 / max;
		for( j in 0...4 ) {
			for( i in 0...max ) {
				var o = dm.empty(3);
				WGeom.drawPoint( o, 0xFFFFFF);
				Col.setColor( o, getRandomColor() );
				var an = a * i;
				o.x = x + WGeom.cos( an ) * (r * j );
				o.y = y + WGeom.sin( an ) * (r * j );
				o.scaleX = o.scaleY = 1 + Math.random() * 3;
				var p = new Phys( o );
				p.timer = 20;
				p.vx = WGeom.cos( an ) * ( 8 / (j +1) );
				p.vy = WGeom.sin( an ) * ( 8 / (j + 1) );
			}
		}
	}

	function getRandomColor( o = false ) {
		if( !o ) return Colorss.OBJECTCOLORS[theme][Std.random(4)];
		return Colorss.DOTCOLORS[theme][Std.random(4)];
	}

	function hit( mc : OBJECT, x, y ) {
		if( x < mc.x )  return false;
		if( x > mc.x +mc.width )  return false;
		return y >= mc.y && y <= mc.y + mc.height;
	}

	function addObject(dx : Float = 0) {

		var o : OBJECT = cast dm.attach( "mcLineaSquare", 1 );
		o.x = o.x = Cs.mcw - 3;
		o.vscroll = 0;
		if( camper > 30 ) {
			var y = dotter.getFirst().y;
			o.y = o.y = y - o.height / 2;
			o.vscroll = 1.5;
			camper = 0;
		} else {
			var cdif = Std.random(Std.int(scroll * 10)) * if( Std.random(2)==0 ) 1 else -1;
			o.scaleX = o.scaleY = 1 + cdif*0.01;
			o.vscroll += cdif / 20;
			o.y = o.y = Std.random(  Cs.mch );
		}
		var col = getRandomColor();
		Col.setColor( o, col );
		o.color = col;
		o.stopped = false;
		objects.push( o );
	}

	override function outOfTime() {
		setWin( false );
		step = 2;
	}

}

class Colorss {
	public static var DOTCOLORS = [
		[Col.rgb2Hex( 125,198,34),Col.rgb2Hex( 0,170,189),Col.rgb2Hex( 243,194,0),Col.rgb2Hex(226,0,120)],
		[Col.rgb2Hex( 245,211,0),Col.rgb2Hex( 44,180,49),Col.rgb2Hex( 150,129,183),Col.rgb2Hex(207,2,38)],
		[Col.rgb2Hex( 191,177,211),Col.rgb2Hex( 187,219,136),Col.rgb2Hex( 249,244,0),Col.rgb2Hex(191,2,34)],
		[Col.rgb2Hex( 187,219,136),Col.rgb2Hex( 245,211,0),Col.rgb2Hex( 241,175,0),Col.rgb2Hex(207,2,38)],
		[Col.rgb2Hex( 0,177,174),Col.rgb2Hex( 94,189,71),Col.rgb2Hex( 212,85,33),Col.rgb2Hex(254,248,134)],
		[Col.rgb2Hex( 112,199,212),Col.rgb2Hex( 255,213,114),Col.rgb2Hex( 250,114,54),Col.rgb2Hex(205,208,10)],
		[Col.rgb2Hex( 220,151,161),Col.rgb2Hex( 197,107,35),Col.rgb2Hex( 161,17,53),Col.rgb2Hex(163,47,117)],
	];

	public static var OBJECTCOLORS = [
		[Col.rgb2Hex( 125,198,34),Col.rgb2Hex( 0,170,189),Col.rgb2Hex( 243,194,0),Col.rgb2Hex(226,0,120), 0xFFFFFF],
		[Col.rgb2Hex( 245,211,0),Col.rgb2Hex( 44,180,49),Col.rgb2Hex( 150,129,183),Col.rgb2Hex(207,2,38), 0xFFFFFF],
		[Col.rgb2Hex( 191,177,211),Col.rgb2Hex( 187,219,136),Col.rgb2Hex( 249,244,0),Col.rgb2Hex(191,2,34), 0xFFFFFF],
		[Col.rgb2Hex( 187,219,136),Col.rgb2Hex( 245,211,0),Col.rgb2Hex( 241,175,0),Col.rgb2Hex(207,2,38), 0xFFFFFF],
		[Col.rgb2Hex( 0,177,174),Col.rgb2Hex( 94,189,71),Col.rgb2Hex( 212,85,33),Col.rgb2Hex(254,248,134), 0xFFFFFF],
		[Col.rgb2Hex( 112,199,212),Col.rgb2Hex( 255,213,114),Col.rgb2Hex( 250,114,54),Col.rgb2Hex(205,208,10), 0xFFFFFF],
		[Col.rgb2Hex( 220,151,161),Col.rgb2Hex( 197,107,35),Col.rgb2Hex( 161,17,53),Col.rgb2Hex(163,47,117), 0xFFFFFF],
	];
}


typedef Scrollable = {>flash.display.MovieClip, created : Bool, ydiff : Float }
typedef Layer = { idx : Int, scroller : Array<Scrollable>, linkage : String, xSpeed : Float, verticalScrollEnabled : Bool, maxVScroll : Bool }

class Scroller {
	
	var dm : mt.DepthManager;
	var scroller : Array<Scrollable>;
	var width : Float;
	var height : Float;
	var depth : Int;
	var margin : Float;
	var gotInfo : Bool;
	var vscroll : Bool;
	var verticalScrollBlocked : Bool;
	var maxVScroll : Bool;
	var layers : IntHash<Layer>;
	var cl : Int;

	public function new( root : flash.display.Sprite, width : Int, height : Int ){
		if( root == null ) throw "root is null";

		cl = 0;
		layers = new IntHash();
		this.width = width;
		this.height = height;
		this.dm = new mt.DepthManager(root);
	}

	public function addLayer( linkage : String, xSpeed : Float = 0.0, verticalScrollEnabled : Bool = false, maxVScroll : Bool = true ) {
		if( linkage == null ) throw "linkage needed";
		var scroller = new Array();
		layers.set( ++cl, { idx : cl, scroller : new Array(), linkage : linkage, xSpeed : xSpeed, verticalScrollEnabled : verticalScrollEnabled, maxVScroll : maxVScroll } );
		add(layers.get( cl) , 0);
	}

	function add( layer : Layer, x : Float ) {
		if( layer == null ) throw "unknown layer";

		var m : Scrollable = cast dm.attach( layer.linkage, layer.idx );
		m.x = m.x = x;

		if( !gotInfo ) {
			if( m.height >= height ) {
				margin = (( m.height - height ) / 2);
			} else {
				margin = (( height - m.height ) / 2);
			}
			gotInfo = true;
		}

		m.y = m.y = -margin;
		m.ydiff = 0;
		layer.scroller.push( m );
	}

	public function update( xSpeed : Float, xMod : Float, ySpeed : Float ) {
		if( xSpeed == 0 && ySpeed == 0 ) return;

		for( l in layers.iterator() ) {
			var scroller = l.scroller;
			for( s in scroller ) {

				if( xSpeed != 0 ) {
					if( s.x <= 0 && !s.created ) {
						add(l,  s.x + s.width );
						s.created = true;
					}

					if( s.x + s.width <= 0 ) {
						scroller.remove( s);
						s.parent.removeChild(s);
					}
					s.x -= xSpeed + if( xMod < 0 && Math.abs( xMod ) > xSpeed ) 0 else xMod;
				}

				if( ySpeed == 0 ) continue;

				if( Math.abs( s.ydiff ) < margin ) {
					s.y -= ySpeed;
					s.ydiff += ySpeed;
					continue;
				}

				if( s.ydiff <= 0 && s.ydiff <= margin && ySpeed > 0 ) {
					if( s.y >= margin ) continue;

					s.y -= ySpeed;
					s.ydiff += ySpeed;
					continue;
				}


				if( s.ydiff >= 0 && s.ydiff >= margin && ySpeed < 0 && s.y <= 0 ) {
					s.y -= ySpeed;
					s.ydiff += ySpeed;
					continue;
				}
			}
		}
	}

	public function clean() {
		for( s in scroller ) {
			scroller.remove(s);
			s.parent.removeChild(s);
		}
		scroller = null;
	}
}

typedef DOT = {x:Int, y : Int, color32 : Int, color : Int, stopped : Bool, started : Bool, a : Float, ready : Bool, merged : Bool, idx:Int, uid : Int }

class Dotter {

	var dots : Array<DOT>;
	var startPos : Int;
	var startAim : Int;
	var margin : Int;
	var plane : BitmapData;
	var xSpeed : Int;
	var ySpeed : Int;
	var xMargin : Int;
	var yMargin : Float;
	var sinct : Float;
	var scroll : Int;
	var ldy : Int;
	var width : Float;
	var height : Float;
	var merge : Bool;
	var uid : Int;
	var marginThickness : Int;

	public var cannotGoY : Bool;

	public function new( root : MovieClip, width : Int, height : Int, xMargin : Int, yMargin : Float, startPos : Int = 0, startAim : Int = 0, margin : Int = 10 ) {

		plane = new BitmapData( width, height, true, 0xFF );
		//root.attachBitmap( plane, 0, "Never", false );
		root.addChild( new flash.display.Bitmap( plane ) );
		
		dots = new Array();
		sinct = 0;
		marginThickness = 1;
		this.startPos = if( startPos == 0 ) Math.round( width / 2 ) else startPos;
		this.startAim = if( startAim == 0 ) Math.round( width / 6 ) else startAim;
		this.margin = margin;
		xSpeed = 0;
		ySpeed = 0;
		ldy = 0;
		this.xMargin = xMargin;
		this.yMargin = yMargin;
		this.width = width;
		this.height = height;
		this.scroll = 0;
		this.uid = 0;
	}

	public function addDot( color : Int = 0xFFFFFF ) {
		var dot : DOT = cast {};
		var aim = Lambda.filter( dots, function(dot:DOT) { return !dot.ready; } );
		dot.y = startPos + aim.length * 10;
		dot.x = 0;
		dot.a = 0;
		dot.idx = 0;
		dot.uid = uid++;
		//var col = Col.addAlpha( color );
		var col = 0xFFFFFFFF;
		plane.setPixel32( 0, startPos, col );
		dot.color32 = col;
		dot.color = color;
		dots.push( dot );
	}

	public function getFirst() {
		return dots[0];
	}

	public function getReady() {
		return Lambda.filter( dots, function(d : DOT ) { return d.ready; } );
	}

	public function getStarted() {
		return Lambda.filter( dots, function(d : DOT ) { return d.started; } );
	}

	public function updateSpeed( vx, vy ) {
		xSpeed = vx;
		ySpeed = vy;
	}

	public function getLength() {
		return dots.length;
	}

	public function remove( uid : Int ) {
		for( d in dots ) {
			if( d.uid == uid )
				dots.remove( d );
		}
	}

	public function update( sx : Int, sy : Int, scr : Int, cbk : DOT -> Void ) {
		this.scroll = scr;
		plane.scroll( -scroll, 0 );

		var ct = new flash.geom.ColorTransform();
		sinct += 5;
		var varsin = 0.5 * WGeom.sin( sinct );
		ct.blueMultiplier = 0.98 + varsin / 50;
		ct.greenMultiplier = 0.98 + varsin / 50;
		ct.redMultiplier = 0.98 + varsin / 50;
		ct.alphaOffset  = 128;
		plane.colorTransform(plane.rect,ct);

		var linked = Lambda.filter( dots, function(dot:DOT) { return dot.started; } );
		var first = linked.first();
		var last = linked.last();
//		var last = dots[dots.length-1];
		var min  = margin;

		// Lignes groupées
		var free = Lambda.filter( dots, function(dot:DOT) { return !dot.started; } );
		var aim = Lambda.filter( dots, function(dot:DOT) { return !dot.ready; } );
		var idx = -2;
		var firstWent = false;
		var count = aim.length;
		for( dot in linked ) {
			idx++;
			var dx = 0;
			var dy = 0;

			if( !dot.ready ) {
				var dest = if( dot.idx == 0 ) min * ( dots.length - aim.length ) else ( dot.idx ) * min;

				// On est arrivé à la bonne position
				if( Math.abs( first.x - dot.x) <= 3 && Math.abs( first.y + dest - dot.y) <= 3 ) {
					dot.ready = true;
					dot.x = first.x;
					dot.y = first.y + dest;
					if( dot.idx == 0 ) dot.idx = idx + 1;
					dot.a =  idx * 90;
					if( !dot.merged ) {
						cbk( dot );
					} else {
						dot.merged = false;
					}
					moveDot( dot, dx, dy );
					continue;
				}

				// Il n'y a pas assez d'espace pour accueillir la nouvelle ligne
				var t = this.height - this.xMargin - ( dest << 1 );
				if( first.y >= t ) {
					moveDot( dot, dx, dy );
					continue;
				}

				// On se dirige vers la bonne position
				var vx = sx * ( dot.idx + 1 ) / 2;
				var vy = sy * ( dot.idx + 1 ) / 2;
				var vary = first.y + dest - dot.y;
				var varx = first.x - dot.x;
				var a = Math.atan2( vary, varx );
				var dx = Math.cos( a ) * vx;
				var dy = Math.sin( a ) * vy;
				moveDot( dot, Math.ceil( dx ), Math.ceil( dy ) );
				continue;
			}

			if( dot.stopped ) {
				moveDot( dot, dx, dy );
				continue;
			}

			if( count ==  1 ) {
				if( ( dot.y <= yMargin + marginThickness && ySpeed >  0 )
					|| ( dot.y >= this.height - yMargin - marginThickness && ySpeed < 0 )
					|| ( dot.y < this.height - yMargin - marginThickness && dot.y > yMargin ) ) {
						dy = ySpeed;
						cannotGoY = false;
				}
				else {
					cannotGoY = true;
				}
			}
			else {
				if( (first.y <= ( yMargin - marginThickness  ) && ySpeed > 0  )
					|| ( dot.idx == first.idx && dot.y <= yMargin - marginThickness && ySpeed > 0 )
					|| (dot.y >= this.height - yMargin - marginThickness &&  ySpeed < 0 )
					|| (first.y >= this.height - yMargin - marginThickness &&  ySpeed < 0 )
					|| (last.y >= this.height - yMargin - marginThickness &&  ySpeed < 0 )
					|| (last.y <= this.height - yMargin - marginThickness && first.y >= yMargin && dot.y >= yMargin ) || firstWent ){

					if( dot.idx == first.idx ) firstWent = true;
					dy = ySpeed;
					cannotGoY = false;
				} else {
					if( dot.idx == first.idx ) firstWent = false;
//					trace( dot.idx + ":" + dot.y + " vs " + yMargin );
					dy = 0;
					cannotGoY = true;
				}
			}

			if( dot.x <= xMargin && xSpeed > 0
				|| ( dot.x >= this.height - xMargin && xSpeed < 0 )
				|| ( dot.x > xMargin && dot.x < this.height - xMargin ) ) {
				dx = xSpeed;
			}

			// Fusion
			if( dot.color != first.color ) {
				if( merge ) {
						dy = Math.ceil( WGeom.sin( dot.a ) * 5 ) + first.y - dot.y;
						dot.a += 45;
						dx = first.x - dot.x - xSpeed;
						dot.merged = true;
				} else {
					if( dot.merged ) {
						dot.ready = false;
					}
				}
			}
				
			moveDot( dot, dx, dy );
		}
	
		// Lignes non groupées
		for( dot in free ) {
			if( dot.x < startAim ) {
				moveDot( dot, sx, 0 );
				continue;
			}
			dot.started = true;
			moveDot( dot, 0, 0 );
		}
	}

	function moveDot( dot : DOT, dx : Int, dy : Int ) {
		var x = dot.x;
		var y = dot.y;

		var col = if( dot.ready ) dot.color32 else 0x60888888;

		// 1 - déplacement horizontal simple
		if( dy == 0 ) {
			for( i in 0...scroll + dx ) {
				plane.setPixel32( x+i, y, col  );
			}
			dot.x += dx;
			ldy = 0;
			return;
		}

		// 2 - déplacement vertical simple
		var x1 = x + scroll;
		var y1 = y + dy;
		plane.setPixel32( x, y, col );
		WGeom.drawBitmapLine( x, y, x1, y1, col, plane );

		// 3 - smooth (pas optmisé du tout mais bon ça ira)
		if( ldy <= 0 ) {
			if( dy > 0 ) {
				plane.setPixel32( x+2, y+1, col );
				plane.setPixel32( x+2, y+1, col );
				plane.setPixel32( x+3, y+1, col );
				plane.setPixel32( x+2, y+2, 0x60000000 );
			}
		}
		dot.y += dy;
		ldy += dy;
	}
	
}
