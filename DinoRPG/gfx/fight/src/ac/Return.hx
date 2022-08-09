package ac ;

import Fighter.Mode ;
import Fight;

class Return extends State {

	var f : Fighter ;

	public function new(f : Fighter) {
		super();
		this.f = f ;
		addActor(f);
	}

	override function init() {
		var behaviour = [0, null];
		if( f.haveStatus(_SFly) || f.haveProp(_PGroundOnly) )
			behaviour.shift();
		f.initReturn( behaviour[Std.random(behaviour.length)] );
	}

	public override function update() {
		super.update();
		if(castingWait) return;
		f.updateMove(coef);
		if(coef == 1) {
			f.backToDefault();
			end();
		}
	}
}