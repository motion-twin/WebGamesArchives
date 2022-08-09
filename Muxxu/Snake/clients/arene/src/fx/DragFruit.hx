package fx;
import mt.bumdum9.Lib;

class DragFruit extends Fx{//}

	
	var fid:Int;
	var fruit:Fruit;
	var speed:Float;
	var frict:Float;
	
	public function new(fr:Fruit,pow:Int) {
		fruit = fr;
		fid = fruit.initId;
		super();
		speed = 3+pow*0.5;
		frict = 0.95;
		switch(pow) {
			case 1 : 	frict = 0.91;
			case 2 : 	frict = 0.95;
			case 3 : 	frict = 0.97;
			default : 	frict = 0.98;
		}
	}
	
	override function update() {
		
		if( fruit.death || fruit.initId != fid  ) {
			kill();
			return;
		}
		
		var trg:Fruit = null;
		var dist = 9999.9;
		for( fr in Game.me.fruits ) {
			if( fr == fruit ) continue;
			var dx = fr.x - fruit.x;
			var dy = fr.y - fruit.y;
			var d = Math.sqrt(dx * dx + dy * dy);
			if( d < dist ) {
				trg = fr;
				dist = d;
			}
		}
	
		if( trg != null ) {
			if( dist>18 ){
				var dx = trg.x - fruit.x;
				var dy = trg.y - fruit.y;
				var a = Math.atan2(dy, dx);
				fruit.x += Snk.cos(a) * speed;
				fruit.y += Snk.sin(a) * speed;
				fruit.updatePos();
				fruit.sprite.pxx();

				// FX
				if( Game.me.gtimer%3 == 0 ) fruit.fxShade(Gfx.col("green_0"),flash.display.BlendMode.ADD);
				
			}
			speed *= frict;
		}
		
		
		if( speed < 0.5 ) kill();
		

		
	}
		
	
	
//{
}