package ac ;

import Fighter.Mode ;
import Fight ;

class Goto extends State {

	public var flSpin:Bool ;
	public var flEnding:Bool ;
	var a : Fighter ;
	var tx : Float;
	var ty : Float;
	var fxt:_GotoEffect;

	public function new(f : Fighter, x:Float,y:Float, ?fxt:_GotoEffect ) {
		super();
		tx = x;
		ty = y;
		this.fxt = fxt;
		this.a = f ;
		addActor(a);
		flEnding = false;
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
			if(flSpin){

				a.backToDefault();
				a.setSens(-1);
				a.mode = Dead;
				//a.root._rotation += 30;
				//a.playAnim("attack");
			}
			if(flEnding)a.kill();

			end();

		}
	}

}