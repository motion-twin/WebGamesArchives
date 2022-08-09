package en.mob;

class Bomber extends en.Mob {
	static var LOOT = api.AKApi.const(1);
	static var XP = api.AKApi.const(4);
	
	public function new(x,y) {
		super(x,y);
		
		baseScore = 35;
		setSpeed(0.7);
		weight = 2;
		radius = 14;
		initLife(10);
		maxPathLen = 30;
		coward = true;
		
		setShadow(true);
		
		sprite.swap("bomber");
		sprite.setCenter(0.5, 1);
		sprite.defaultAnim = "walk";
	}
	
	override function getLoot() { return api.AKApi.const(1); }
	override function getXp() { return api.AKApi.const(4); }

	override function destroy() {
		super.destroy();
		play3dSound( S.BANK.explode01(), 0.5 );
	}
	
	override function hit(d) {
		super.hit(d);
		play3dSound(S.BANK.hit06(), 0.2);
	}
	
	public override function update() {
		super.update();
		
		if( !cd.has("shoot") )
			if( distance(game.hero)<=180 ) {
				sprite.playAnim("shoot", 1);
				cd.set("moveLock", 20);
				cd.set("shoot", 30*2.5);
				dx = dy = 0;
				
				play3dSound( S.BANK.explode06(), 0.5 );
				var pt = game.hero.getAnticipatedCoord();
				new en.Bomb(this, pt.x, pt.y);
				
				var s = game.char.getAndPlay("bomberExplosion", "explosion", 1);
				s.x = sprite.x;
				s.y = sprite.y-25;
				s.setCenter(0.5, 1);
				s.blendMode = flash.display.BlendMode.ADD;
				s.killAfterAnim = true;
				game.sdm.add(s, Const.DP_FX);
			}
		
	}
}

