package world.ent;
import Protocole;




class Portal extends world.Ent {//}
	

	static var RUNE_POS = [2, 6, 2, 9, 1, 12, 16, 6, 16, 9, 16, 12, 9, 2];
	

	public var pow:Int;
	public static var me:Portal;
	
	public  function new(island, sq) {
		me = this;
		type = EOther;
		super(island, sq);
		block = true;
		
		var base = new pix.Element();
		base.y -= 4;
		base.drawFrame(Gfx.world.get("portal"));
		addChild(base);
		
		// RUNE
		pow = 0;
		var runes = world.Loader.me.getRunes();
		for( id in runes ) {
			var rune = new pix.Sprite();
			rune.setAlign(0, 0);
			rune.setAnim(Gfx.world.getAnim("portal_stone"));
			addChild(rune);
			rune.x = base.x+RUNE_POS[id * 2] - 10 ;
			rune.y = base.y+RUNE_POS[id * 2 + 1] - 8;
			rune.anim.gotoRandom();
			pow ++;
		}
		
		// LIGHT
		var light = new pix.Sprite();
		light.setAnim(Gfx.world.getAnim("portal_light"));
		light.x = base.x;
		light.y = base.y+2;
		light.alpha = pow / 6;
		light.anim.playSpeed = light.alpha;
		addChild(light);
		
	}

	override function trigSide() {
		if( pow < Data.RUNE_MAX || !World.me.sendReady() || World.me.hero.sq.y - sq.y != 1 ) {
			World.me.setControl(true);
			return true;
		}
		
		// END GAME
		new fx.EnterPortal();
		return false;
	}
	
	override function isTrig() {
		return pow == Data.RUNE_MAX;
	}
	
	override function heroIn() {
		if( !World.me.sendReady() ) return;
		
		// END GAME HERE
		var h = World.me.hero;
		
		h.goto(h.sq.dnei[3]);
	}
	
	
	override function getProtectValue() {
		return 10;
	}
	
	
//{
}








