import Common;
import mt.flash.Volatile;
import flash.geom.Rectangle;
import flash.geom.Point;

class ObjectManager {

	public static var lock = false;
	static var game : Game;
	static var cycles : Volatile<Float>;

	public static function init(g:Game ) {
		game = g;
		cycles = 10;
		for( i in  0... 20 ) {
			placeObject();
		}
	}

	public static function update( scroll : Float ) {
		if( lock ) return;
		if(  Const.SPEED <= 0 ) return ;

		cycles -= scroll;
		if( cycles <= 0 ){	
			placeObject();
		}
	}

	static function placeObject( ) {
		var type = SceneManager.getSceneTypeForObject();
		if( type < 0 || type == null ) {
			return;
		}

		var o : DOb= null;
		var frame : Int = 0;
		switch type {
			case 0 : 
				pattern( "mcObjets_terre", 5, 8, 10 );

				if( Std.random( 10 ) == 1 ) {
					pasteObject(  "mcObjets_terre", if( Std.random( 2) == 0 ) 4 else 7 );
				}
				else if( Std.random( 100 ) < 5) {
					addTunnel(0);
				}
				else {
					var f = Const.Ea[Std.random( Const.Ea.length )];
					addObject( f, "mcObjets_terre", "mcObjets_terre_ombre" );

					if( Std.random( 30 ) == 0 ) {
						var f = Const.Ga[Std.random( Const.Ga.length )];
						addObject( f, "mcObjets", "mcObjets_ombre" );
					}
				}

				return;
			case 1 : 
				pattern( "mcObjets_neige", 5, 5, 10 );

				var f = Const.Sa[Std.random( Const.Sa.length )];
				addObject( f, "mcObjets_neige", "mcObjets_neige_ombre" );

				if( Std.random( 100 ) < 5 ) {
					addTunnel(1);
				}
				else if( Std.random( 30 ) == 0 ) {
					var f = Const.Ga[Std.random( Const.Ga.length )];
					addObject( f, "mcObjets", "mcObjets_ombre" );
				}
				return;
			case 2 : 
				pattern( "mcObjets_herbe", 4, 1, 10 );

				if( Std.random( 100 ) < 5 ) {
					addTunnel(2);
				}
				else if( Std.random( 10 ) == 0 ) {
					var f = Const.Ga[Std.random( Const.Ga.length )];
					addObject( f, "mcObjets", "mcObjets_ombre" );
				}				
				return;
		}
	}

	static function pasteObject( name : String, frame : Int ) {
		var o : DOb= cast game.dm.attach(name, Const.DP_OBJECTS );
		o.gotoAndStop( frame );
		placeMc(o);
		SceneManager.paste(o);
		var x = o._x;
		var y = o._y;
		var w = o._width;
		var h = o._height;
		o.removeMovieClip();
		o = null;
	}

	static function pattern( name : String, frames : Int, addFrames : Int, max : Int ) {
		var o : DOb= cast game.dm.attach(name, Const.DP_OBJECTS );
		o.gotoAndStop( Std.random( frames ) + addFrames );
		placeMc(o);
		SceneManager.paste(o);
		var x = o._x;
		var y = o._y;
		var w = o._width;
		var h = o._height;
		o.removeMovieClip();
		o = null;

		for( i in 0... Std.random( max ) ) {
			var p : DOb= cast game.dm.attach(name, Const.DP_OBJECTS );
			p.gotoAndStop( Std.random( frames ) + addFrames );
			p._x = x + Std.random( Std.int( w ) );
			p._y = y + Std.random( Std.int( w ) );
			SceneManager.paste(p);
			p.removeMovieClip();
			p = null;
		}
	}

	static function addObject(frame : Int, name : String, shadow : String) {
		var o : DOb= cast game.dm.attach(name, Const.DP_OBJECTS );
		o.gotoAndStop( frame );
		placeMc(o);
		if( Station.hitTest( o ) ) {
			o.removeMovieClip();
			return;
		}
		o.cacheAsBitmap = true;
		var s : DOb = cast game.dm.attach( shadow, Const.DP_SHADOW );
		s._y = o._y;
		s._x = o._x;
		s.gotoAndStop( frame );
		Scroller.add( s );
		Scroller.add( o );
	}

	static function addTunnel( type ) {
		var o : DOb= cast game.dm.attach("mcTunnels", Const.DP_OBJECTS );
		o.gotoAndStop( 1 +  
			switch(type) {
				case 0 :
					if( Std.random( 10 ) == 0 ) 0 else 3;
				case 1 :
					if( Std.random( 10 ) == 0 ) 1 else 4;
				case 2 : 
					if( Std.random( 10 ) == 0 ) 2 else 3;
			} );

		o._x = Const.CENTER_X;
		o.y = o._y = -Const.HEIGHT;
		cycles = Scroller.next(o);

		if( Station.hitTest( o ) ) {
			o.removeMovieClip();
			return;
		}
		Scroller.add( o );
	}

	static function placeMc( mc : DOb ) {
		mc._x = Scroller.getX(mc);
		mc.y = mc._y = -50;
		cycles = Scroller.next(mc);
	}
}
