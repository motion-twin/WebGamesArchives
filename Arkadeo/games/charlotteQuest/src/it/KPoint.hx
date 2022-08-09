package it;

import api.AKProtocol;
import mt.flash.Volatile;

class KPoint extends Item {
	var pk		: api.SecureInGamePrizeTokens;
	
	public function new(from:Entity, pk:api.SecureInGamePrizeTokens) {
		super();
		
		autoKillOutsider = true;
		radius = 25;
		copyPos(from);
		this.pk = pk;
		followScroll = false;
		
		var pt = getScreenPoint();
		dx = if( pt.x<=Game.WID*0.5 ) 0.1 else -0.1;
		dy = if( pt.y<=Game.HEI*0.5 ) -0.1 else -0.25;
		
		frictX = 0.98;
		frictY = 0.95;
		gravity = 0.002;
		autoKill = Entity.KillCond.LeaveScreen;
		
		var mc = new lib.Kado();
		var f = 1;
		var s = 0.6;
		switch( pk.amount.get() ) {
			case 1 : f = 1; color = 0x93FF00; s = 0.6;
			case 5 : f = 2; color = 0xFFDD1A; s = 0.7;
			case 10 : f = 3; color = 0x95CAFF; s = 0.85;
			case 20 : f = 4; color = 0xF1B8FE; s = 1;
			default :
				destroy();
				return;
		}
		mc._smc.gotoAndStop(f);
		mc.scaleX = mc.scaleY = s;
		mc.filters = [
			new flash.filters.GlowFilter(0xffffff,1, 2,2,4),
			new flash.filters.GlowFilter(color, 0.7, 8,8, 2),
			new flash.filters.DropShadowFilter(12,90, 0x0,0.2, 8,8, 1),
		];
		spr.addChild(mc);
	}
	
	override function toString() {
		return super.toString()+"[KPoint]";
	}
	
	public override function pickUp() {
		super.pickUp();
		api.AKApi.takePrizeTokens(pk);
		var pt = getPoint();
		var v = pk.amount.get();
		game.pop( pt.x, pt.y, v==1 ? Lang.PK : Lang.PKs({_n:pk.amount.get()}), color, 1200 );
	}
	
	public override function update() {
		super.update();
	}
}
