import Protocole;

typedef BlocksMc = {>flash.display.MovieClip, px : Float, py : Float }
typedef BlocksLine = {v:Float,pieces:List<BlocksMc>,last:Int,stop:Bool,force:Int};

class Blocks extends Game {

	var scroll : Float;
	var lines : Int;
	var rand : Int;

	var scale : Float;
	var pieces : Int;
	var colors : Int;
	var w : Float;
	var alines : Array<BlocksLine>;
	var bwin:Bool;

	override function init(dif:Float){
		gameTime =  200 + Std.random(100);
		super.init(dif);

		var b1 = dm.attach("mcBlocksBand",3);
		var b2 = dm.attach("mcBlocksBand2",3);
		b2.x = Cs.mcw;

		alines = new Array();
		scroll = 1.2+dif;
		lines = 5;
		
		//var cycle = Std.int(80 / scroll);
		//gameTime += cycle;
		

		var max = Cs.mcw / 40;
		scale = max / lines * 100;
		pieces = 5;
		rand = Math.ceil( (dif * 5 )) + 1;
		w = 40 * scale / 100;

		bwin = true;

		attachElements();
	}

	function attachElements(){
		bg = dm.attach( "mcEclipseBg2", 0 );

		var white = if( Std.random( 2 ) == 0 ) true else false;
		var pv = white;
		var sens = true;
		for( i in 0... lines ) {
			var firstTrick =  3 + Std.random( 3 );
			var b = new List();
			if( sens ) {
				var f = if( pv ) 1 else 2;
				b.add( block( -w, i * w, f ) );
				pv = !pv;
				var force = -1;
				for( j in 0... pieces ) {
					f = if( pv ) 1 else 2;
					if( j == firstTrick ) {
						f = if( f == 1 ) 2 else 1;
					}
					var c = block(j * (w), i * w, f );
					b.add( c );
					pv = !pv;
				}
				var last = if( f == 1 ) 2 else 1;
				alines.push( {v: scroll, pieces :b, last : last, stop : false, force :-1 } );
			}
			else {
				pv = !pv;
				var f = 0;
				for( j in 0... pieces ) {
					f = if( pv ) 1 else 2;
					b.add( block(j * (w), i * w, f ) );
					pv = !pv;
				}
				f = if( pv ) 1 else 2;
				b.add( block( (pieces ) * (w) , i * w, f ) );
				alines.push( {v: -scroll, pieces :b, last : f, stop : false, force:-1 } );
			}
			sens = !sens;
		}
	}

	function block(x,y,f) {
		var d : BlocksMc = cast dm.attach( "mcBlocksBlock", 2 );
		d.gotoAndStop( f );
		d.scaleX = d.scaleY = scale*0.01;
		d.x = x;
		d.y = y;
		d.x = d.x;
		d.y = d.y;
		var me = this;
		//d.onPress = function() { me.swapColor(d ); };
		d.addEventListener( flash.events.MouseEvent.CLICK, function(e) { me.swapColor(d); } );
		return d;
	}

	function swapColor(b : BlocksMc ) {
		b.gotoAndStop( if( b.currentFrame == 1) 2 else 1 );
	}

	override function update() {
		var first = Lambda.array(alines[0].pieces)[0];
	
		if( gameTime == 1 ) {
			if( Math.abs(first.x + 41) > 2 ) gameTime++;
		}
		switch(step){
			case 1:
				scrollPieces();
		}

		super.update();
	}
	
	function scrollPieces() {

		for( l in alines ) {
			if( l.stop ) continue;

			var first = l.pieces.first();
			var firstx = first.x;
			var lastx = l.pieces.last().x;
			for( p in l.pieces ) {
				p.x += l.v;
				p.x = p.x;
				if( l.v > 0 && p.x >= Cs.mcw ) {

					if( l.force > 0 ) {
						p.gotoAndStop( l.force );
						l.force = -1;
						l.last = if( p.currentFrame == 1 ) 2 else 1;
					}
					else {
						var t = Std.random( 10 ) < rand;
						if( t ) {
							var f = if( l.last == 1 ) 2 else 1;
							p.gotoAndStop( f );
							l.force = f;
						}
						else {
							p.gotoAndStop( if( l.last == 1 ) 2 else 1 );
							l.last = p.currentFrame;
						}
					}

					l.pieces.remove( p );
					p.x = firstx + l.v -w;
					l.pieces.push( p );
				}
				else if( l.v < 0 && ( p.x + w ) <= 0 ) {

					if( l.force > 0 ) {
						p.gotoAndStop( l.force );
						l.force = -1;
						l.last = if( p.currentFrame == 1 ) 2 else 1;
					} else {
						var t = Std.random( 10 ) < rand;
						if( t  ) {
							var f = if( l.last == 1 ) 2 else 1;
							p.gotoAndStop( f );
							l.force = f;
						}
						else {
							p.gotoAndStop( if( l.last == 1 ) 2 else 1 );
							l.last = p.currentFrame;
						}
					}

					l.pieces.remove( p );
					p.x = lastx + w;
					l.pieces.add( p );
				}
			}
		}
	}

	override function outOfTime(){
		for( l in alines ) {
			if( l.stop ) continue;

			l.stop = true;
			
			var c = l.pieces.length -1;
			var a = Lambda.array( l.pieces );
			var attached = false;

			for( i in 0...a.length ) {
				var p = a[i];
				p.mouseEnabled = false;

				if( p.x < 0 || p.x + w > Cs.mcw || p.x > Cs.mcw ) {
					p.parent.removeChild(p);
					p = null;
					a[i] = null;
				}
			}

			// XXX  à coder si on change la vitesse
			var recal = 0.0;
			/*
			if( l.v < 0 ) {
				recal = a[1].x - w ;
			} else {
				var x = Math.floor( a[1].x );
			}*/

			//var n = 0;
			var last:Null<Int> = null;
			for( i in 0...a.length ) {
				var p = a[i];
				if( p == null ) continue;

				p.x += recal;

				// XXX surligner les mauvais blocks (clignoter en rouge) ?
				if( last != null && p.currentFrame == last && !attached) {
					var b = dm.attach("mcBlocksBad",2);
					b.x = 0;
					b.y = p.y;
					b.scaleX = p.scaleX;
					b.scaleY = p.scaleY;
					attached = true;
					bwin = false;
				}else{
					last = p.currentFrame;
				}
				//	trace(last);
				//n++;
			}
			//trace("---"+n);
		}
		var me = this;
		if( !bwin ) {
			haxe.Timer.delay( function() { me.setWin(false); }, 200 );
			return;
		}
		haxe.Timer.delay( function() { me.setWin(true); }, 1000 );
	}

}
