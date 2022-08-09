package ac ;

import mt.bumdum.Lib;
import Fighter.Mode ;
import Fight ;

class Wait extends State {
	var endTime:Float;

	public function new(ms) {
		super();
		endTime = flash.Lib.getTimer()+ms;
	}

	override function update(){
		super.update();
		if( flash.Lib.getTimer() > endTime )end();
	}
}
















