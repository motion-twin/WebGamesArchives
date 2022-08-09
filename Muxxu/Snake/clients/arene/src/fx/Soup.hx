package fx;
import Protocole;

class Soup extends Fx {//}
	
	
	var timer:Int;
	var step:Int;
	var plate:Part;
	var sprite:Part;
	var max:Int;
	var todo:Array<Fruit>;
	
	public function new() {
		super();
		
		step  = 0;
		timer = 0 ;
		
		plate = Part.get();
		Stage.me.dm.add(plate.sprite, Stage.DP_FRUITS);
		plate.sprite.setAnim(Gfx.fx.getAnim("soup"));
		
		var p = Stage.me.getRandomPos(60, 20);
		
		plate.setPos(p.x,p.y, -20);
		
		
		
		plate.weight = 0.2;
		plate.frictBounceZ = 0.5;
		
		plate.dropShade(true);
		
		
	}
	
	override function update() {
		super.update();
		timer++;
		switch(step) {
			case 0 :
				if ( timer > 36 ) {
					
					step++;
					todo = Game.me.fruits.copy();
				}
			case 1 :
				var fr = todo.pop();
				if ( !fr.death && !fr.dummy ) {
					var e = new fx.FruitJumpTo( fr, plate.x, plate.y);
					e.onFinish = callback(add, fr);
					fr.timer += 200;
					fr.edible = false;
				}
				if ( todo.length == 0 ) {
					timer = 0;
					step++;
				}
				
			case 2:
				if ( timer  > 50 ) {
					plate.kill();
					var e = new mt.fx.ShockWave(32, 64, 0.1);
					e.setPos(plate.x, plate.y);
					Stage.me.dm.add(e.root, Stage.DP_UNDER_FX);
					kill();
				}
			
		}
		
		
	}
	
	
	public function add(fr:Fruit) {
		fr.kill();
		Game.me.incFrutipower(1.5);
	}
	

	
//{
}












