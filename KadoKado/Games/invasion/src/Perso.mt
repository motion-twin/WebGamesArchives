class Perso {

	var x : int;
	var y : int;

	var anim_delta : float;
	var adx : int;
	var ady : int;

	var mc : {> MovieClip, sub : MovieClip };
	var hero : bool;
	var game : Game;
	var kind : int;
	var cursig : int;
	var dir : int;

	var fx : {> MovieClip, remove : bool, visible : bool };
	var goutte : MovieClip;

	function new(g,h,x,y) {
		game = g;
		hero = h;
		anim_delta = 0;
		adx = 0;
		ady = 0;
		this.x = x;
		this.y = y;
		dir = game.dir(0,1);
		if( hero )
			kind = 0;
		else
			kind = Tools.randomProbas(Const.PROBAS_MONSTERS);
		fx = downcast(game.dmanager.attach(hero?"hero-apparition":"monster-apparition",Const.PLAN_PERSO));
		colorize(fx);
		Const.pos(fx,x,y);
		game.dmanager.compact(Const.PLAN_PERSO);
		game.dmanager.ysort(Const.PLAN_PERSO);
		game.wait.push(this);
	}

	function colorize(mc) {
		var color = null;
		switch( kind ) {
		case 1:
			var c = new flash.filters.ColorMatrixFilter();
			c.matrix = [
				0,1,0,0,0,
				0,1,0,0,0,
				1,0,0,0,0,
				0,0,0,1,0,
				0,0,0,0,1,
			];
			color = upcast(c);
			break;
		case 2:
			var c = new flash.filters.ColorMatrixFilter();
			c.matrix = [
				0,1,0,0,0,
				1,0,0,0,0,
				0,0,1,0,0,
				0,0,0,1,0,
				0,0,0,0,1,
			];
			color = upcast(c);
			break;
		}
		mc.filters = [color];
	}

	function attach() {
		mc = downcast(game.dmanager.attach(hero?"hero":"monster",Const.PLAN_PERSO));
		colorize(mc);
		mc.cacheAsBitmap = true;
		game.dmanager.compact(Const.PLAN_PERSO);
		game.dmanager.ysort(Const.PLAN_PERSO);
		update();
	}

	function color(col) {
		var c = new Color(game.cases[x][y]);
		if( col == null )
			c.reset();
		else {
			var k = 75;
			c.setTransform({
				ra : 100 - k,
				rb : int((col >> 16) * k / 100),
				ga : 100 - k,
				gb : int(((col >> 8) & 0xFF) * k / 100),
				ba : 100 - k,
				bb : int((col & 0xFF) * k / 100),
				aa : 100,
				ab : 0
			});
		}
	}

	function update() {
		Const.pos(mc,x,y);
		mc._x += adx * anim_delta;
		mc._y += ady * anim_delta;
		if( anim_delta == 0 )
			mc.gotoAndStop(string(dir+1));
	}

	function destroy() {
		fx = downcast(game.dmanager.attach(hero?"disparition-hero":"disparition-monster",Const.PLAN_FX));
		Const.pos(fx,x,y);
		fx._x += Const.SIZE / 2;
		fx._y += Const.SIZE / 2;
		game.wait.push(this);
	}

	function move(dx,dy,att) {
		dir = game.dir(dx,dy);
		x += dx;
		y += dy;
		adx = -dx;
		ady = -dy;
		anim_delta = Const.SIZE;
		if( hero )
			mc.gotoAndStop(string(dir+att?10:6));
		else
			mc.gotoAndStop(string(dir+7));
		update();
	}

	function anim() {
		anim_delta -= Timer.tmod * 3;
		if( anim_delta < 0 )
			anim_delta = 0;
		update();
		return (anim_delta != 0);
	}

	function signal(s) {
		cursig = s;
		switch(s) {
		case null:
			color(null);
			if( !hero )
				goutte.removeMovieClip();
			break;
		case Const.SDEF_FIRST:
			if( !hero ) {
				goutte.removeMovieClip();
				goutte = game.dmanager.attach("goutte",Const.PLAN_FX);
				Const.pos(goutte,x,y);
				goutte.gotoAndStop(string(dir+1));
			}
		case Const.SDEF:
			color(0xFF8282);
			break;
		case Const.SATT:
			color(0xEEEEEE);
			break;
		case Const.SNODEF:
			color(0xAAAAAA);
			break;
		case Const.SNOATT:
			color(0xAAAAAA);
			break;
		}
	}

}