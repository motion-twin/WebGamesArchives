import Common;
import mt.flash.Volatile;

typedef Bg = { idx : Int, frame : Int, type : Int }

class SceneManager {

	static var bgs : List<Bmp>= new List();
	static var nbgs : List<Bg> = new List();
	static var newBackIndex : Volatile<Int> = 0;
	static var game : Game = null;
	static var previousType : Volatile<Int> = -1;
	static var initScene : Bool = true;
	static var initDone = false;

	public static var lock = false;

	public static function init(g) {
		previousType = -1;
		game = g;
		prepare();

		for( i in 0...3) {
			var bg = nbgs.pop();
			var s = getScene(bg);
			var scene = makeNextScene( s, Const.HEIGHT );
			scene._y = scene.y = -Const.HEIGHT * i;
			s.removeMovieClip();
			bgs.add( scene );
		}
		
		initDone = true;
	}

	public static function update(scroll) {
		if( lock ) return;

		for( scene in bgs ) {
			scene.y += scroll;
			scene._y = scene.y;
		}
	}

	public static function clean() {
		if( lock ) return;

		for( scene in bgs ) {
			if( scene._y > Const.HEIGHT && !scene.disposed ) {
				var prev= bgs.last();
				addElements(prev.y);
				scene.bmp.dispose();
				scene.disposed = true;
				scene.removeMovieClip();
				scene = null;
				bgs.pop();
				if( nbgs.length < 2 ) {
					prepare();
				}
			}
		}
	}

	public static function prepare() {		 		
		var type = if( !initDone ) 0 else Std.random(2)+1;
		newBackIndex = Const.SCENE_BASE + Std.random( Const.SCENE_RANDOM );	

		for( i in 0...newBackIndex ) {
			var bg = {idx:-1, frame:1, type : type };
			bg.idx = i;

			// transition
			if( i == 0 ) {
				bg.type = -1;									
				if( previousType == -1 ) {	
					switch( type ) {
						case 0 :
							bg.frame = 5;
						case 1 :
							bg.frame = 4;
						case 2 : 
							bg.frame = 8;
					}
				} else {
					switch( previousType ) {
						case 0 :
							switch( type ) {
								case 0 :
									bg.frame = 1;
								case 1 :
									bg.frame = 4;
								case 2 :
									bg.frame = 8;
							}
						case 1 :
							switch( type ) {
								case 0 :
									bg.frame = 5 ;
								case 1 :
									bg.frame = 2 ;
								case 2 :
									bg.frame = 7 ;
							}
						case 2 :
							switch( type ) {
								case 0 :
									bg.frame =  9 ;
								case 1 :
									bg.frame =  6 ;
								case 2 :
									bg.frame = 3;
							}
					}
				}
			} else {
				bg.frame = type + 1;
			}

			nbgs.add( bg );
		}

		previousType = type;
	}

	public static function addElements(y=0.0) {
		var bg = nbgs.pop();
		var s = getScene(bg);
		var scene = makeNextScene( s, Const.HEIGHT );
		scene._y = scene.y = -Const.HEIGHT + y;
		s.removeMovieClip();
		scene.type = bg.type;
		bgs.add( scene );
	}

	static function  makeNextScene( mc, h ) {
		var scene : Bmp = cast game.dm.empty( Const.DP_BG );
		scene.bmp = new flash.display.BitmapData( Const.HEIGHT, h , false, 0 );
		scene.attachBitmap( scene.bmp, Const.DP_BG );
		scene.bmp.draw( mc, Const.getMatrixFromMc( mc ) );
		return scene;
	}

	static function getScene( bg : Bg ) {
		var s = game.dm.attach( "mcBg", Const.DP_BG );
		s.gotoAndStop(bg.frame);
		s._alpha = Std.random( 80 ) + 20;		
		return s;
	}

	public static function drawOnScene( mc : flash.MovieClip ) {
		for( b in bgs ) {
			if( b._y >= Const.HEIGHT ) continue;
			if( b._y + Const.HEIGHT <= 0  ) continue;			

			var bh = b._y + Const.HEIGHT;
			if( bh < Const.HEIGHT ) {
				var r = new flash.geom.Rectangle( 0, 0, Const.HEIGHT, Std.int( b._y + Const.HEIGHT ) );
				if( r.contains( mc._x, mc._y ) ) {					
					b.bmp.draw( mc, Const.getMatrixFromMc( mc, 0, -b._y  ) );
				}
				break;
			}

			var r = new flash.geom.Rectangle( 0, Std.int( b._y ), Const.HEIGHT, Std.int( Const.HEIGHT - b._y ) );
			if( r.contains( mc._x, mc._y ) ) {
				b.bmp.draw( mc,Const.getMatrixFromMc( mc, 0, -b._y ) );
			}
		
		}
	}

	public static function getSceneType() {
		var drawAgain = false;
		for( b in bgs ) {
			if( b._y >= 0 && b._y <= Const.HEIGHT ) continue;	

			switch( b.type ) {
				case null : continue;
				case -1 : continue;
				case 0 : return 1;
				case 1 : return 2;
				case 2 : return 1;
			}
		}
		return 1;
	}

	public static function getSceneTypeForObject() {
		var drawAgain = false;
		var prev = -1;
		for( b in bgs ) {
			if( b == null ) continue;

			if( b._y >= 0 && b._y <= Const.HEIGHT ) {
				prev = b.type;
				continue;	
			}

			switch( b.type ) {
				case null : continue;
				case -1 : return -1;
				case 0 : return 0;
				case 1 : return 1;
				case 2 : return 2;
			}
		}

		return prev;
	}

	public static function pasteMc( mc : flash.MovieClip, hitTest = false ) : Float {
		for( b in bgs ) {
			if( b._y >= 0 && b._y <= Const.HEIGHT ) continue;	
		
			switch( b.type ) {
				case null : continue;
				case -1 : continue;
				case 0 : if( mc._currentframe > 15 ) continue;
				case 1 : if( mc._currentframe > 22 ) continue;
				case 2 : if( mc._currentframe < 23 ) continue;
			}

			var r = new flash.geom.Rectangle( b._x, b._y, Const.HEIGHT, Const.HEIGHT );
			if( r.containsRectangle( new flash.geom.Rectangle( mc._x -mc._width/2, mc._y  - mc._height/2, mc._width, mc._height ) ) ) {
				if( hitTest )
//					b.bmp.draw( mc, Const.getMatrixFromMc( mc, 0, -b._y ) );
					b.bmp.draw( mc, Const.getMatrixFromMc( mc, 0, 0 ) );
				else 
					b.bmp.draw( mc, Const.getMatrixFromMc( mc, 0, -b._y ) );

				return b._y;
			}
		}
		return -1;
	}

	public static function paste( mc ) {
		var y = -1.0;
		for( b in bgs ) {
			if( b._y >= 0 && b._y <= Const.HEIGHT ) continue;	
			var m = Const.getMatrixFromMc( mc, 0, -b.y  );
			b.bmp.draw( mc, m );
			y =  b._y;
		}
		return y;
	}
	
}	
