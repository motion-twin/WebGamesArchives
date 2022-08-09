package fx;
import Protocole;
import mt.bumdum9.Lib;

class GroundGrab extends mt.fx.Fx{//}
	
	var sprite:pix.Sprite;
	var vy:Float;
	var step:Int;
	var timer:Int;

	public function new(rew:_Reward) {
		super();
		
		var h = World.me.hero;
		
		//
		sprite = new pix.Sprite();
		sprite.drawFrame( world.ent.Reward.getFrame(rew) );
		h.island.dm.add(sprite, world.Island.DP_FX);
		sprite.x = h.root.x;
		sprite.y = h.root.y;
		Filt.glow(sprite,2,4,0x550000);
		
		//
		h.sprite.setAnim(Gfx.hero.getAnim("hero_happy_jump"), true);
		
		//
		sprite.y -= 5;
		vy = -4;
		step = 0;
		timer = 0;
		//
		World.me.setControl(false);
	}
	
	override function update() {
		switch(step) {
			case 0:
				vy *= 0.85;
				sprite.y += vy;
				if( timer++ > 28 ) {
					step ++;
					timer = 0;
					
				}
			case 1:
				timer++;
				Col.setColor(sprite, 0, timer * 10);
				if( timer++ > 20 ) {
					sprite.filters = [];
					sprite.setAnim(Gfx.fx.getAnim("bonus_vanish"));
					sprite.anim.onFinish = sprite.kill;
					kill();
					World.me.hero.face();
					World.me.setControl(true);
					world.Inter.me.majStatus();
				}
				
				
		}

	}
	


	
//{
}








