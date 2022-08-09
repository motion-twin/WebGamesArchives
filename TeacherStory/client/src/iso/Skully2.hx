package iso;

import Iso;
import Common;

class Skully2 extends Iso {
	var mc			: lib.Bonaparte;
	
	public function new(x,y) {
		super();
		
		cx = x;
		cy = y;
		xr = 1.2;
		glowClick = false;
		glowOver = false;
		
		mc = new lib.Bonaparte();
		sprite.addChild(mc);
		mc.y = getFeet().y;
		mc._head.gotoAndStop(1);
		
		setShadow(true);
		setClick(0,10, 9, Tx.Skully2, function() {
			if( !man.interfaceLocked() ) {
				mc._head.scaleX = -mc._head.scaleX;
				mc._eyes.scaleX = mc._head.scaleX;
				man.tw.terminate(mc);
				man.tw.create(mc, "y", mc.y-1, TLoop, 100);
				Manager.SBANK.handUp01().play(0.7);
			}
		});
	}
}

