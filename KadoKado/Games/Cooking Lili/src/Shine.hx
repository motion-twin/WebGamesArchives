import mt.Timer;

class Shine extends Fx{
	var dx					: Float;
	var dy					: Float;
	var fl_h				: Bool;

	public function new(g,x:Float,y:Float,fl_h) {
		super(g);
		mc = game.dm.attach("fx_shine",Const.DP_FX);
		mc._x = x + Std.random(15)*(Std.random(2)*2-1);
		mc._y = y + Std.random(10)*(Std.random(2)*2-1);
		mc._xscale = Std.random(100)+50;
		mc._yscale = mc._xscale;
		mc._alpha = Std.random(30)+70;
		dy = (Std.random(50)/10+4);
		if ( fl_h ) {
			dx = dy * (Std.random(2)*2-1);
			dy = 0;
			mc._rotation = 90;
		}
		else {
			mc._y+=10;
		}
	}

	override public function update() {
		super.update();
		dx*=0.9;
		dy*=0.9;
		mc._alpha -= Timer.tmod*3;
		mc._xscale -= Timer.tmod*2;
		mc._yscale = mc._xscale;
		mc._x+=dx;
		mc._y+=dy;
		if ( mc._alpha<=0 ) {
			destroy();
		}
	}
}
