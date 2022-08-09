package it;

import mt.flash.Volatile;

class KPoint extends GenericItem {
	public var pk		: api.AKProtocol.SecureInGamePrizeTokens;
	
	public function new(p:api.AKProtocol.SecureInGamePrizeTokens) {
		super();
		
		pk = p;
		
		//var rlist = new mt.deepnight.RandList();
		//rlist.add(0, 100);
		//rlist.add(1, 40);
		//var p : Int = rlist.draw(rseed.random);
			
		color = switch(pk.frame) {
			default : 0xFFCC00;
		}
		
		var mc = new lib.Kadeo();
		spr.addChild(mc);
		mc.gotoAndStop(pk.frame);
		
		spr.visible = fl_active = pk.score.get()==0;
	}
	
	public override function pickUp() {
		super.pickUp();
		api.AKApi.takePrizeTokens(pk);
		fx.popKPoint(xx,yy, pk);
	}
	
	public override function update() {
		if( !fl_active )
			if( game.time%10==0 && api.AKApi.getScore()>=pk.score.get() )
				activate();
				
		super.update();
	}
}
