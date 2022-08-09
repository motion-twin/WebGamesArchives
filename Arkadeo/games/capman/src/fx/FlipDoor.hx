package fx;
import mt.bumdum9.Lib;
import Protocol;


class FlipDoor extends mt.fx.Fx {//}
	
	
	var sens:Int;
	var door:Door;

	public function new(door,clockwise) {
		super();
		this.door = door;
		this.sens = clockwise?1:-1;
		Game.me.stepFx = this;
		
		curveInOut();
	}
	
	override function update() {
		super.update();
		coef  = Math.min(coef + 0.15, 1);
		
		
		
		door.rotation = -door.dir * 90 + curve(coef) * 90 * sens;
		if( coef == 1 ) {
			door.setDir(1 - door.dir);
			Game.me.hero.majHeroDist();
			Game.me.stepFx = null;
			kill();
		
		}
		
	}
	
	
	
//{
}












