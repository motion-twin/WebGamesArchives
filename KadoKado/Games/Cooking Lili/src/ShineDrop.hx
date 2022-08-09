import mt.Timer;

class ShineDrop extends Fx{
	var dx					: Float;
	var dy					: Float;

	public function new(g,x,y) {
		super(g);
		mc = game.dm.attach("fx_shine",Const.DP_FX);
		mc._x = x;
		mc._y = y;
		mc._xscale = Std.random(50)+50;
		mc._yscale = mc._xscale;
		dx = (Std.random(5)+1) * (Std.random(2)*2-1);
		dy = -Std.random(5)-5;
	}

	override public function update() {
		super.update();
		if ( dy<=0 || mc._y<=30 ) {
			dy+=Const.FX_GRAVITY*Timer.tmod;
			dx*=0.95;
		}
		else {
			dx*=0.7;
			dy*=0.92;
//			dx+= (Std.random(10)/10) * (Std.random(2)*2-1);
		}
		mc._rotation+=dx*2;
		mc._x+=dx;
		mc._y+=dy;
		mc._alpha -=Timer.tmod*2;
		if ( mc._alpha<=0 ) {
			destroy();
		}
	}
}
