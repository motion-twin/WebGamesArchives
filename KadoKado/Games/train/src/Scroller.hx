import Common;
import mt.flash.PArray;
import flash.geom.Rectangle;

class Scroller {

	static var f : Int = 0;
	static var objects : mt.flash.PArray<DOb>;
	static var gems : mt.flash.PArray<DOb>;
	static var cleanCount : Int = 10;
	public static var cycles = 0.0;
	public static var lock = false;

	public static function add(mc:DOb, y = 0.0) {
		if( objects == null ) objects = new mt.flash.PArray();
		mc.y = mc._y = if( y == 0.0 ) Const.OBJECTS else y;
		objects.push(mc);

		Game.game.dm.ysort( Const.DP_OBJECTS );
	}

	public static function addGem(mc : DOb, y = 0.0 ) {
		if( gems == null ) gems = new mt.flash.PArray();
		mc.y = mc._y = if( y == 0.0 ) Const.OBJECTS else y;
		gems.push(mc);
	}

	public static function next(mc : flash.MovieClip ) {
		cycles = mc._height + mc._height * 1.5;
//		cycles = mc._height + mc._height * 0.5;
		return cycles;
	}

	public static function scroll(scroll : Float) {
		cycles -= scroll;

		if( objects.cheat ) KKApi.flagCheater();

		if( Const.SPEED <= 0 ) return;
		if( lock ) return;
		if( objects == null ) return;
		if( objects.length < 0 ) return;

		doScroll( objects, scroll );
		doScroll( gems, scroll );		
	}

	static function doScroll(objects : PArray<DOb>, scroll : Float ) {
		for( o in objects ) {
			o._visible = true;
			o.y += scroll;
			o._y = o.y;	
			if( o._y > Const.HEIGHT  + o._height ) {	
				o.d = true;
			}
		}	
	}

	public static function hitSmoke( y1 : Float, y2 : Float) {
		for( o in objects ) {
			if( !o.smokoff )  continue;
			if( o._y < 0 ) continue;
			if( o._y > y1 ) {
				return true;
			}
			if( o._y < y2 ) {
				return true;
			}
		}
		return false;
	}


	public static function hideObjects() {
		hide( objects );
		hide( gems );
	}

	public static function showObjects( ) {		
		show( objects );
		show( gems );
	}

	static function show( list : mt.flash.PArray<DOb> ) {
		for(  o in list ) {
			o.hit1._visible = true;
			o.hit2._visible = true;
		}
	}

	static function hide( list : mt.flash.PArray<DOb>) {
		for( o in list ) {
			if( o._y + o._height <  0 ) {
				o._visible = false; 
				return;
			}

			if( o._y - o._height > Const.HEIGHT ) {
				o._visible = false; 
				return;
			}
		}
	}

	/* ------------------------------- COLLISIONS ----------------------------*/

	public static function hitPiouz(mc:flash.MovieClip ) {
		for( o in gems ) {
			if( o.piouz ) {	
				if( Const.hit( mc, o ) ) {
					Gem.piouzCrash( o );
					return;
				}
			}
		}
	}

	public static function hitGem( mc : flash.MovieClip, f : DOb -> Void ) {
		for( o in gems ) {		
			if( o.gem ) {
				if( Const.hit( mc, o ) ) {
					f( o );
					continue;
				}
			}
		}
	}

	// Collision sur l'objet dans sa globalité
	public static function hitRoot( mc : flash.MovieClip ) {
		for( o in objects ) {
			if( Const.hit( o, mc ) ) return true;
		}

		for( o in gems ) {		
			if( o.gem ) {
				if( Const.hit( mc, o ) ) {
					return true;
				}
			}
		}		
		return false;
		
	}

	// collision sur les zones de collision de l'objet
	public static function hit( mc : flash.MovieClip ) {
		for( o in objects ) {
			if( o.hit1 != null ) {
				if( Const.hit( o.hit1, mc ) ) {
					return true;
				}
			}
			if( o.hit2 != null ) {
				if( Const.hit( o.hit2, mc ) ) {
					return true;
				}
			}
		}

		for( o in gems ) {		
			if( o.gem ) {
				if( Const.hit( mc, o ) ) {
					return true;
				}
			}
		}		
		return false;
	}

	// gestion des depths
	public static function changeDepth( mc : flash.MovieClip ) {
		for( o in objects ) {

			var smcY = mc._y + ( mc._height / 2 );
			if( o.hit1 != null ) {
				if( Const.hit( o.hit1, mc ) ) {
					if( smcY >= o._y ) {
						Game.game.dm.over( mc );							
					} else if(  Math.floor( smcY ) == Math.floor( o._y ) ){					
						Game.game.dm.over( mc );
					} else {
						Game.game.dm.under( mc );
					} 
				} 				
			}

			// test sur la deuxième zone de collision
			if( o.hit2 != null ) {
				if( Const.hit( o.hit2, mc ) ) {
					if( smcY >= o._y ) {
						// devant
						Game.game.dm.over( mc );							
					} else if(  Math.floor( smcY ) == Math.floor( o._y ) ){	
						// par dessus
						Game.game.dm.over( mc );
					} else { 
						// derrière
						Game.game.dm.under( mc );
					} 
				}
			}

			// pas de collision avec les zones de collision mais passage par l'arrière
			if( Const.hit( o, mc ) ) {
				if( smcY < o._y ) {
					Game.game.dm.under( mc );
				}
			}
		}
		return false;
	}

	public static function clean() {
		if( cleanCount-- < 0 ) {
			for( i in 0...objects.length ) {
				var o = objects[i];
				if(!o.d) continue;
				o.removeMovieClip();
				objects.splice( i, 1 );
			}
			cleanCount = 10;
		}
	}

	public static function getX(o : flash.MovieClip ) : Float {
		var left = Std.random( 2 ) == 0;
		var x : Float = 0.0;

		if( left ) {
			x = o._width / 2 + Std.random( Math.floor( 110 - o._width ) );
		} else {
			x = 170 + o._width + Std.random( Math.floor( Const.HEIGHT - 150 - o._width ) );
		}

		if( x <= o._width / 2 ) x = o._width * 2;
		if( x >= Const.HEIGHT - o._width / 2 ) x = Const.HEIGHT - o._width * 2;

		return x;
	}

}
