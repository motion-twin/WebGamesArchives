class Bonus {

	var game : Game;
	var mc : MovieClip;
	var x : int;
	var type:int;
	var falling : bool;
	

	function new(g,x,y,t) {
		game = g;
		this.x = x;
		type = t;
		falling = true;
		mc = game.dmanager.attach("bonus",Const.PLAN_BONUS);
		mc.gotoAndStop(string(type+1))
		recall(x,y);
	}

	function destroy() {
		mc.removeMovieClip();
	}

	function recall(x,y) {
		if( x != null )
			mc._x = x * Const.BLK_WIDTH + Const.DELTA_X;
		if( y != null )
			mc._y = (game.level.base_y - y) * Const.BLK_HEIGHT + Const.DELTA_Y;
	}

}