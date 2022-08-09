package ac ;

import Fighter.Mode ;
import mt.bumdum.Lib ;

class Escape extends State {
	var f : Fighter ;
	public function new(f: Fighter) {
		super();
		this.f = f ;
		addActor(f);
	}

	override function init() {
		f.playAnim("run");
		var m = 50.0+f.ray;
		var tx = -m;
		var ty = f.y;
		if( !f.side )tx+= Cs.mcw+2*m;
		var dist = f.getDist({x:tx,y:ty});
		spc = f.runSpeed / dist ;
		f.moveTo(tx,ty);
	}

	public override function update(){
		super.update();
		if( castingWait ) return;
		f.updateMove(coef);
		if( coef == 1 ){
			f.kill();
			end();
		}
	}
}