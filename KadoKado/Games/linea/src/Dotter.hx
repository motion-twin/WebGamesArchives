import flash.display.BitmapData;
import flash.MovieClip;
import mt.flash.PArray;
import mt.bumdum.Lib;

typedef DOT = {x:Int, y : Int, color32 : Int, color : Int, stopped : Bool, started : Bool, a : Float, ready : Bool, merged : Bool, idx:Int, uid : Int }

class Dotter {

	var dots : PArray<DOT>;
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
		root.attachBitmap( plane, 0, "Never", false );
	
		dots = new PArray();
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
		var col = Col.addAlpha( color );
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
		var varsin = 0.5 * mt.white.Geom.sin( sinct );
		ct.blueMultiplier = 0.98 + varsin / 50;
		ct.greenMultiplier = 0.98 + varsin / 50;
		ct.redMultiplier = 0.98 + varsin / 50;
		ct.alphaOffset  = 128;
		plane.colorTransform(plane.rectangle,ct);

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
						dy = Math.ceil( mt.white.Geom.sin( dot.a ) * 5 ) + first.y - dot.y;
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
		mt.white.Geom.drawBitmapLine( x, y, x1, y1, col, plane );

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
