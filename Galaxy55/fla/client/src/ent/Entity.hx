package ent;

class Entity {
	
	var game : Game;
	
	public var x : Float;
	public var y : Float;
	public var z : Float;

	public function new() {
		this.game = Game.inst;
	}
	
	function collide(x, y, z:Float) {
		return game.level.collide(x, y, z);
	}
	
	public function recallZ(h:Int) {
		var ix = Std.int(x);
		var iy = Std.int(y);
		if( h < 0 ) h = 1;
		while( collide(ix,iy,h) )
			h++;
		while( h > 1 && !collide(ix,iy,h-1) )
			h--;
		z = h;
	}
	
	inline function real( v : Float ) {
		return game.agame.realFloat(v);
	}
	
	inline function realDist( v : Float ) {
		return game.agame.realDist(v);
	}
	
}