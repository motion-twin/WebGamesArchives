class Gem {

	static var MOVE = 0;
	static var EXPLODE = 1;
	static var GRAVITY = 2;
	static var FALL = 3;

	var group : Array<Gem>;
	var game : Game;
	var t : int;
	var id : int;
	var x : int;
	var y : int;

	var mc : MovieClip;
	var tx : int;
	var ty : int;
	var px : float;
	var py : float;
	var time : float;
	var frame : float;

	function new(g,id,x,y) {
		this.game = g;
		mc = game.dmanager.attach("gem",Const.PLAN_GEM+y);
		setId(id);
		setPos(x,y);
	}

	function setPos(x,y) {
		if( x != null ) {
			this.x = x;
			mc._x = Const.POSX + x * 36;			
		}
		if( y != null ) {
			this.y = y;
			game.dmanager.swap(mc,Const.PLAN_GEM+y);
			mc._y = Const.POSY + y * 36;			
		}
	}

	function setId(n) {
		this.id = n;
		mc.gotoAndStop(string(id+1));
		downcast(mc).skin.stop();
	}

	function move(tx,ty) {
		t = MOVE;
		x = tx;
		y = ty;
		game.dmanager.swap(mc,Const.PLAN_GEM+ty);
		downcast(mc).skin.gotoAndStop(2);
		this.tx = Const.POSX + tx * 36;
		this.ty = Const.POSY + ty * 36;
		px = mc._x;
		py = mc._y;
		game.moves.push(this);
	}

	function explode() {
		t = EXPLODE;
		px = mc._x + 18;
		py = mc._y + 18;
		time = 0;
		downcast(mc).skin.gotoAndPlay(1);
		game.moves.push(this);
	}

	function gravity() {
		t = GRAVITY;
		y++;
		game.dmanager.swap(mc,Const.PLAN_GEM+y);
		px = mc._y;
		py = 0;
		game.moves.push(this);
	}

	function fall(y) {
		t = FALL;
		py = (y - this.y) * 36;
		setPos(x,y);
		px = mc._y;
		game.moves.push(this);
	}

	function update() {
		switch(t) {
		case MOVE: return updateMove();
		case EXPLODE: return updateExplode();
		case GRAVITY: return updateGravity();
		case FALL: return updateFall();
		default: return false;
		}
	}

	function updateMove() {
		var r = true;
		var p = Math.pow(0.7,Timer.tmod);
		px = px * p + tx * (1 - p);
		py = py * p + ty * (1 - p);
		if( Math.abs(px - tx) + Math.abs(py - ty) < 2 ) {
			px = tx;
			py = ty;
			downcast(mc).skin.gotoAndStop(1);
			r = false;
		}
		mc._x = px;
		mc._y = py;
		return r;
	}

	function updateExplode() {
		if( time >= 0 ) {
			time -= Timer.deltaT;
			if( time < 0 )
				downcast(mc).skin.gotoAndPlay("death");				
		}
		var flg = (mc._name != null)
		if( !flg ) {			
			var i;
			var nparts = int(Math.max(1,5/Timer.tmod));
			for(i=0;i<nparts;i++) {
				var p = new Particule(game,id,px,py);
				game.parts.push(p);
			}
			mc.removeMovieClip();
		}
		return flg;
	}

	function updateGravity() {
		var fl = true;
		py += Timer.tmod * 10;
		if( py >= 36 ) {
			py = 36;
			fl = false;
		}
		mc._y = px + py;
		return fl;
	}

	function updateFall() {
		var fl = true;
		py -= Timer.tmod * 10;
		if( py <= 0 ) {
			py = 0;
			fl = false;
		}
		mc._y = px - py;
		return fl;
	}

}