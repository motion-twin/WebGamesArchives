import Common;

class RailManager {

	static var rails : Array<Idx> = new Array();
	static var nrails : List<Idx> = new List();
	static var displayed = false;
	static var game : Game = null;
	static var countRails = -1;
	static var countDone = false;
	public static var lock = false;

	public static function init( g ) {
		game = g;
		prepare();
		display();
	}

	public static function scroll(scr : Float) {
		if( lock ) return;
		for( r in rails ) {
			r.y += scr;
			r._y = r.y;
		}	
	}

	public static function update( scroll : Float ) {
		if( lock ) return;

		for( r in rails ) {

			var count = countRails;
			if( r.idx == count && r._y > Const.HEIGHT + Const.RAIL_H && r.idx > 0 && !countDone) {
				countDone = true;
				r.idx = -1;
				prepare();
			}

			if( r.idx == 0 && r._y >= -Const.RAIL_H && !displayed ) {
				countDone = false;
				r.idx = -1;
				display(r._y);
			}

			if( r._y > Const.HEIGHT + Const.RAIL_H ) {
				r.d = true;
			}
		}
	}

	public static function clean() {
		for( i in 0...rails.length ) {
			var r = rails[i];
			if( r.d ) {
				r.removeMovieClip();
				r = null;			
				rails.splice( i, 1);
			}
		}		
	}

	public static function prepare() {
		displayed = false;
		countRails = -1;
		for( i in 0...5 ) {
			var r : Idx =  cast game.dm.attach("mcRail", Const.DP_RAIL );
			r.gotoAndStop(1);
			r.idx = i;
			r._x = Const.CENTER_X;
			r._visible = false;
			r.cacheAsBitmap = true;
			r.d = false;			
			nrails.add( r );
			countRails++;
		}
	}

	public static function display(y = 0.0) {
		if( displayed )  return;

		var i = 0;
		for( r in nrails ){

			i++;
			r._visible = true;
			if( y == 0 )
				r.y = r._y = -Const.HEIGHT + i * Const.RAIL_H;
			else
				r.y = r._y = -Const.HEIGHT -Const.RAIL_H + y + ( -Const.HEIGHT + i * Const.RAIL_H );
			
			rails.push( r );
			nrails.remove( r );			
		}
		displayed = true;
	}
}
