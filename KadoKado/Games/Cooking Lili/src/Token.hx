import Level;
class Token {
	var game				: Game;
	public var mc			: { > flash.MovieClip, ice: flash.MovieClip };
	public var id			: Int;
	public var combo		: T_Combo;
	public var fall			: Int;
	public var moveDist		: Float;
	public var x			: Int;
	public var y			: Int;
	public var fl_armor		: Bool;

	public var mul			: Int;

	public function new(g,i) {
		game = g;
		fall = 0;
		fl_armor = false;
		setId(i);
	}

	public function copy() {
		var t = new Token(game,id);
		t.x = x;
		t.y = y;
		return t;
	}

	public function setId(i) {
		id = i;
		if ( id<3 )
			mul = 1;
		else
			mul = 2 + id-3;
	}

	public function attach(x,y) {
		if ( mc==null ) {
			mc = cast game.dm.attach("token",Const.DP_TOKENS);
			mc.ice._rotation = Std.random(360);
			mc.smc._rotation = Std.random(4)*90;
			mc.smc._alpha = Std.random(15)+85;
			mc.smc._x+=Std.random(4) * (Std.random(2)*2-1);
			mc.smc._y+=Std.random(2) * (Std.random(2)*2-1);
//			mc.blendMode = "screen";
		}
		mc._x = Level.x_ctr(x);
		mc._y = Level.y_ctr(y);
//		mc._width = Const.TWID;
//		mc._height = Const.THEI;
		mc.smc.gotoAndStop(id+1);
		mc.ice._visible = fl_armor;
		if ( fl_armor ) {
//			mc._alpha = 70;
		}

	}

	public function debug() {
		return mc._name;
	}

}
