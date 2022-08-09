class Block { //}

	var game : Game;
	var mc : MovieClip;
	var x : int;
	var y : int;
	var dy : float;
	var speed : float;
	var ann : MovieClip;
	var time : float;

	function new(g,x,y) {
		game = g;
		this.x = x;
		this.y = y;
		dy = 0;
		initBlock();
	}

	function initBlock() {
		mc = game.dmanager.attach("block",Const.PLAN_BLOCK);
		setPos();
	}

	function setPos() {
		mc._x = x * Const.BLK_WIDTH + Const.DELTA_X;
		mc._y = (game.level.base_y - y) * Const.BLK_HEIGHT + Const.DELTA_Y + dy;
	}

	function destroy() {
		mc.removeMovieClip();
	}
	
	
//{
}