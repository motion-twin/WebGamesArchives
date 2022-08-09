package seq;
import mt.bumdum9.Lib;
import Protocol;

/**
 * the hero has been hit and will die !
 */
class Hit extends mt.fx.Sequence {

	var vz:Float;
	
	public function new(b:ent.Bad) {
		super();
		vz = -6;
		Game.me.gstep = 1;
		
		var h = Game.me.hero;
		h.dead = true;
		
		if( h.canJump() )
			h.skin.play("hero_die_shoe" );
		else if( h.isInvincible() )
			h.skin.play("hero_die_cap" );
		else
			h.skin.play("hero_die" );
		
		h.skin.anim.loop = false;
	}
	
	override function update() {
		super.update();
		
		var h = Game.me.hero;
		vz += 0.5;
		h.z += vz;
		h.skin.updateAnim();
	
		if( h.z > 0 ) {
			h.z = 0;
			vz *= -0.6;
			if( Math.abs(vz) < 1 ){
				h.z = 0;
				vz = 0;
			}
		}
		
		h.updatePos();
		if( timer == 80 ) {
			api.AKApi.gameOver(false);
		}
	}
}
