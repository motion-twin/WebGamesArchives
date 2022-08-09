package iso;

import Iso;
import Common;

import flash.display.MovieClip;

class MiscFurn extends Iso {
	//public static var ALL : Array<MiscFurn> = [];
	
	public var mc			: MovieClip;
	
	public function new(fmc:MovieClip, x,y, ?flip=false, ?dy=0) {
		super();
		//ALL.push(this);
		
		fl_static = true;
		glowClick = false;
		glowOver = false;
		
		mc = fmc;
		cx = x;
		cy = y;
		
		addFurnMc(mc, flip, 0,dy);
		mc.stop();
	}
	
	//override function destroy() {
		//super.destroy();
		//ALL.remove(this);
	//}
}

