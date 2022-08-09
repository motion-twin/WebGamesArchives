package ac ;

import Fighter.Mode ;
import Fight ;

class MoveTo extends State {

	var a : Fighter ;
	var tx : Float;
	var ty : Float;


	public function new(f : Fighter, x:Float,y:Float ) {
		super();
		tx = x;
		ty = y;
		this.a = f ;
		addActor(a);

	}


	override function init() {
		a.playAnim("run");
		a.saveCurrentCoords();
		var dist = a.getDist({x:tx,y:ty});
		spc = a.runSpeed / dist ;
		a.moveTo(tx,ty);
	}


	public override function update() {
		super.update();
		if(castingWait)return;

		a.updateMove(coef);
		if(coef==1 ){
			a.backToDefault();
			end();
		}
	}

}