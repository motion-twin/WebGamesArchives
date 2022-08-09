class Toy {

	var game : Game;
	var rail : Rail;

	var mc : {> MovieClip, but : MovieClip };
	var x : float;
	var kdo : bool;
	var lock : bool;
	var t : int;

	static var TOYS = [1,4,5,2,6,8,9];

	function new(g,t,r,flCursor) {
		game = g;
		rail = r;
		mc = downcast(game.dmanager.attach("toy",1));
		setType(t);
		if(!flCursor){
			mc.but.onPress = callback(game,selectToy,this);
			mc.but._alpha = 0;
			KKApi.registerButton(mc.but)
		}
		mc._y = Const.RAIL_Y_BASE + Const.RAIL_Y_DELTA * r.pos;
		x = 350;
	}

	function setType(t) {
		this.t = t;
		if( t == -1 ) {
			mc.gotoAndStop("20");
			mc.but.useHandCursor = false;
		} else {
			mc.but.useHandCursor = true;
			mc.gotoAndStop(string(TOYS[t]));
		}
	}

	function update(dx) {
		x -= dx;

		var center = Const.RAIL_END;
		var delta = 10;

		if( x >= center - delta && x <= center + delta ) {
			lock = true;
			if( t != -1 && t < Const.BONUS_PLUS20 ) {
				var p = 1 - Math.abs(center - x) / delta;
				if( !kdo && x <= center )
					p = 1;
				rail.cruncher._y = -50 + p * 35;
			}
		}

		if( !kdo && x <= Const.RAIL_END ) {
			rail.active(this);
			kdo = true;
			if( t != -1 && t != Const.BONUS_PLUS20 && t != Const.BONUS_X2 && t != Const.BONUS_SPEED )
				mc.gotoAndStop("7");
		}
		mc._x = int(x);
		if( x < -30 ) {
			destroy();
			return false;
		}
		return true;
	}

	function destroy() {
		mc.removeMovieClip();
	}

}