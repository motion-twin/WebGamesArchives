package fx;
import Protocole;
import mt.bumdum9.Lib;

class Ghost extends Fx {//}

	
	var ghost:Part;
	var float:Int;
	var acc:Float;
	
	public function new() {
		super();
		float = 0;

		// GHOST GFX
		ghost = Part.get();
		ghost.sprite = new pix.Sprite();
		ghost.sprite.setAnim( Gfx.fx.getAnim("ghost") );
		ghost.sprite.anim.stop();
		ghost.ray = 3;
		ghost.dropShade(false);
		
		// PROP
		ghost.frict = 0.91;
		acc = 0.025;
		
		// START POS
		var pos = Stage.me.getRandomPos(20, 100);
		ghost.x = pos.x;
		ghost.y = pos.y;
		ghost.z = -10;
		
		// ADD TO STAGE
		Stage.me.dm.add(ghost.sprite, Stage.DP_FX);
		
	}
	
	override function update() {
		super.update();
		
		// ANGLE
		var dx = sn.x - ghost.x;
		var dy = sn.y - ghost.y;
		
		var a = Math.atan2(dy, dx);
		
		var cur = ghost.sprite.anim.cursor;
		var trg = (a / 6.28) * 16;
		
		var dif = Num.hMod(Math.round(trg-cur), 8);
		
		if( dif > 0 ) cur++;
		if( dif < 0 ) cur--;
		
		ghost.sprite.anim.goto( Num.sMod(cur, 16) );
		
		//
		ghost.vx += Snk.cos(a) * acc;
		ghost.vy += Snk.sin(a) * acc;
		
		// ACCELERATION
		acc += 0.0001;
		
		// Z
		float = (float + 9) % 628;
		ghost.z = -9 + Snk.cos(float * 0.01) * 6;
		
		// COLLISION
		if( ghost.z > -6 && Math.sqrt(dx * dx + dy * dy) < 12 ) {
			var e = new mt.fx.ShockWave(16, 46, 0.05);
			e.setPos(ghost.x,ghost.y);
			Stage.me.dm.add(e.root, Stage.DP_UNDER_FX);
		
			var sp = ghost.sprite;
			var e = new mt.fx.Tween(sp, sn.x, sn.y,0.2);
			e.onFinish = function() { sp.visible = false;};
			ghost.sprite = new pix.Sprite();
			ghost.kill();
			kill();
			new Exit();
		}
		
	
		
		if( sn.dead ) vanish();
		

	}
	
	

	
	function vanish() {

		ghost.timer = 10;
		ghost.fadeType = 1;
		kill();
		
	}
	


	
//{
}












