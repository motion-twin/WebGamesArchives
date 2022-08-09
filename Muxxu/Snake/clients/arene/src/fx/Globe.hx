package fx;
import mt.bumdum9.Lib;
import Protocole;


class Globe extends CardFx {//}

	var angle:Float;
	var sum:Float;
	
	public function new(ca) {
		super(ca);
		angle = sn.angle;
		sum = 0;
	}
	
	override function update() {
		super.update();
		
		var da  = Num.hMod(sn.angle-angle, 3.14);
		angle = sn.angle;
		sum += da;
		
		var lim = 6.28;
		if( sum > lim ) {
			sum -= lim;
			incTime(1);
		}
		if( sum <= -lim ) {
			sum += lim;
			incTime(-1);
		}
		
		
	}
	
	public function incTime(inc) {
		Game.me.gtimer += 50 * inc;
		if( Game.me.gtimer < 0 ) Game.me.gtimer = 0;
		card.fxUse();
	}
	

	
//{
}












