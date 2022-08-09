package fx;
import Protocole;
import mt.bumdum9.Lib;


private typedef Mon = { type:MonsterType, folk:Folk };

class OppQueue extends mt.fx.Fx {//}
	

	public var monsters:Array<Folk>;

	public function new(a:Array<MonsterType>) {
		
		super();

		monsters = [];
		
		var color = Scene.me.bmp.getPixel(Cs.mcw - 10, 102);
		
		var x = 0;
		for ( mid in a ) {
			var folk = new Folk();
			Scene.me.dm.add(folk, Scene.DP_UNDER_FX);
			folk.x = Cs.mcw+60+((a.length-x++)*50);
			folk.y = 102;
			folk.setMonster(mid);
			folk.box.scaleX *= 0.5;
			folk.box.scaleY *= 0.5;
			//folk.scaleX = folk.scaleY = 0.5;
			Col.setPercentColor(folk, 1, color);
			monsters.push(folk);
		}


		//moveAll();
		
	}

	
	// UPDATE
	override function update() {
		super.update();


		
	}

	function moveAll() {

		
		var x = Cs.mcw - 50;
		for ( mon in monsters ) {
	

			var sens = 1;
			if ( x > mon.x ) sens = -1;
			mon.setSens(sens);

			var dif = x - mon.x;
			var spc = 5 / Math.abs(dif);
			
			mon.play("run");
			
			var e = new mt.fx.Tween(mon, x, mon.y,spc);
			e.onFinish = callback(endMove, mon);
			x -= 50;
		}
		
	}
	
	function endMove(mon:Folk) {
		mon.play("stand");
		mon.setSens( 1);
	}
	
	public function lastLeave(onFinish) {
		var mon = monsters.shift();
		
		var spc = 0.05;
		var e = new mt.fx.Tween(mon, Cs.mcw+50, mon.y,spc);
		e.onFinish = callback(endMove, mon);
		mon.play("run");
		mon.setSens( -1);
		e.onFinish = function() { moveAll(); onFinish(); };
		
	}
	
//{
}