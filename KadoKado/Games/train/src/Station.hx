import Common;
import mt.flash.Volatile;
import mt.flash.PArray;

typedef P = {>Ob, d:Float}

class Station {
	public static var station : Ob;
	public static var nextStation : Volatile<Float>;

	static var limit : Ob;
	static var panneaux : mt.flash.PArray<P>;
	static var nextCounter : Volatile<Float>;
	static var nextStationCycle : Volatile<Int>;
	static var cycle : Volatile<Int>;
	static var game : Game;
	static var stationDisplayed : Bool;
	static var stop = false;
	static var p1 = false;
	static var p2 = false;
	static var p3 = false;

	public static var lock = false;

	public static function init(g) {

		game = g;
		limit = cast game.dm.attach( "mcLimite_station", Const.DP_DECOR );
		limit._visible = false;
		panneaux = new PArray();
		goNextStation();
		nextStationCycle = 1;
		cycle = 0;
		nextCounter = 0;

	}

	public static function scroll( scroll ) {
		if(lock) return;

		station.y +=scroll;
		station._y = station.y;
		limit.y += scroll;
		limit._y = limit.y;
	}

	public static function update( scroll : Float ) {
		if(lock) return;

		nextStation -= scroll;

		if( nextStation < -(Const.LOCO_H ) && Const.SPEED == 0 ) {
			if( Const.SPEED <= 0 && !stop ){
				if( Loco.mc._y - Const.LOCO_H + 10 > limit._y ) {
					stop = true;
					game.addCoal();
				} 
			}
			nextStation = 0;
		}

		if( nextStation > 300 && nextStation < 1000 ) {
			if( nextStation > Const.P1 && !p1 && !p2 && !p3  ) {
				attachPanneau( 3 );
				p1 = true;
			}
			else if( nextStation < Const.P3 && !p3) {
				attachPanneau( 1 );
				p3 = true;
			}
			else if( nextStation < Const.P2 && !p2 && !p3 ) {			
				attachPanneau( 2 );
				p2 = true;
			}
		}
		
		for( panneau in panneaux ) {
			panneau.y +=scroll;
			panneau._y = panneau.y;
			if( panneau._y > Const.HEIGHT + panneau._height * 3 ) {
				if( panneau.d > Const.P1 && p1) {
					p1 = false;
				}
				else if( panneau.d < Const.P3 && p3 ) {
					p3 = false;
				}
				else if( panneau.d < Const.P2 && p2 ) {
					p2 = false;
				}
				
				panneaux.remove( panneau );
				panneau.removeMovieClip();
				panneau = null;
			}
		}

		if( limit._y > Const.HEIGHT ){
			limit._visible = false;
		}

		if( station._y > Const.HEIGHT + Const.LOCO_H * 2 ) {
			station.removeMovieClip();
			station = null;
		}

		if( nextStation < Const.STATION_TRIGGER ) {
			if( !stationDisplayed ) {
				station =  cast game.dm.attach( "mcStation", Const.DP_STATION );
				station._x = 260;
				station.y = station._y = -Const.STATION_TRIGGER;
				station.gotoAndStop( SceneManager.getSceneType() );
				stationDisplayed = true;

				limit._x = Const.CENTER_X;
				limit.y = limit._y = station.y - Const.LOCO_H;
				limit._visible = true;
				return;
			}
		}

		if( nextStation + Const.LOCO_H + Const.STATION_HEIGHT <= 0 && stationDisplayed ) {
			goNextStation();
			stationDisplayed = false;
			stop = false;
		}
	}

	static function attachPanneau( frame ) {
		var panneau : P = cast game.dm.attach( "mcPaneaux",Const.DP_PANNEAUX );
		panneau._x = 186;
		panneau.gotoAndStop( frame );
		cast( panneau.smc).text = nextStation - panneau._height;
		panneau.y = panneau._y = -panneau._height;
		SceneManager.paste( panneau );
		panneau._visible = false;
		panneaux.push( panneau );
		panneau.d = nextStation;
	}

	static function goNextStation() {
		nextStation = KKApi.val( Const.NEXT_STATION );
		Gem.newFactor();
	}

	public static function hit(mc : flash.MovieClip ) {
		if( station._visible ) {	
			return Const.hit(  mc, station.hit1 );
		}
		for( p in panneaux )  {
			if( Const.hit( mc, p ) )
				return true;
		}
		return false;
	}

	public static function hitTest(mc : flash.MovieClip ) {
		if( Const.hit(  mc, station ) ) return true;

		for( p in panneaux )  {
			if( Const.hit( mc, p ) )
				return true;
		}
		return false;
	}

}
