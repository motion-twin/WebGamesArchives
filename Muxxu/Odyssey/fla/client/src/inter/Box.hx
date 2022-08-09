package inter;
import Protocole;
import mt.bumdum9.Lib;


class Box extends MC {//}

	public var mcw:Int;
	public var mch:Int;
	

	
	public function new(ww,hh) {
		super();
		mcw = ww;
		mch = hh;
		drawBg();
	}
	
	public function drawBg() {
		
		var gfx = graphics;	
		gfx.clear();
		var ec = 1;
		for ( i in 0...3 ) {
			gfx.beginFill([0,0xFFFFFF,0][i]);
			var ma = ec * i;
			gfx.drawRect(ma, ma, mcw-2*ma, mch-2*ma);
		}
	
	}
	

	
//{
}