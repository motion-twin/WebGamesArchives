package iso;

import Iso;
import Common;

class Skully extends Iso {
	public static var CURRENT : Skully = null;
	var mc				: lib.Skully;
	
	public function new(x,y) {
		super();
		CURRENT = this;
		
		//fl_static = false;
		cx = x;
		cy = y;
		xr = 1.2;
		yr = 0.1;
		glowClick = false;
		glowOver = false;
		
		mc = new lib.Skully();
		sprite.addChild(mc);
		mc.y = getFeet().y;
		
		mc._head.gotoAndStop(1);
		setShadow(true);
		setClick(0,10, 9, Tx.Skully, function() {
			if( !man.interfaceLocked() ) {
				mc._head.scaleX = -mc._head.scaleX;
				mc._eyes.scaleX = mc._head.scaleX;
				man.tw.terminate(mc);
				man.tw.create(mc, "y", mc.y-1, TLoop, 100);
				Manager.SBANK.handUp01().play(0.7);
			}
		});
	}
	
	public function lookAt(?dx=1) {
		mc._head.scaleX = dx>=0 ? 1 : -1;
		mc._eyes.scaleX = mc._head.scaleX;
	}
	
	public function blinkEyes() {
		mc._eyes.gotoAndPlay(1);
	}
	
	public function saySomething() {
		lookAt(-1);
		say( man.tg.m_skully() );
		mc._head.gotoAndPlay(1);
	}
	
	public override function update() {
		super.update();
		if( !cd.has("talking") )
			mc._head.gotoAndStop(1);
	}
}

