package it;

import mt.flash.Volatile;

class Time extends GenericItem {
	public function new() {
		super();
		
		color = 0xB4BFCD;
		fl_repop = false;
		
		var mc = new lib.Chrono();
		spr.addChild(mc);
	}
	
	public override function pickUp() {
		super.pickUp();
		fx.popTime(xx,yy, 20);
		game.addTime(20);
	}
}
