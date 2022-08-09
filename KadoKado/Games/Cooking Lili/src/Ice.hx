import mt.Timer;

class Ice extends Fx{
	var dx					: Float;
	var dy					: Float;

	public function new(g,x,y) {
		super(g);
		mc = game.dm.attach("fx_ice",Const.DP_FX);
		mc._x = x;
		mc._y = y;
		mc._xscale = Std.random(50)+50;
		mc._yscale = mc._xscale;
		dx = (Std.random(5)+1) * (Std.random(2)*2-1);
		dy = -Std.random(5)-5;
	}

	override public function update() {
		super.update();
		dy+=Const.FX_GRAVITY*Timer.tmod;
		mc._rotation+=dx*2;
		mc._x+=dx;
		mc._y+=dy;
		if ( mc._y>=Const.GHEI+5 ) {
			destroy();
		}
	}
}
