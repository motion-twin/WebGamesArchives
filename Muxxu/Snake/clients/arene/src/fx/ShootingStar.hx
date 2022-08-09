package fx;
import Protocole;
import mt.bumdum9.Lib;

class ShootingStar extends Fx {//}

	static var SPEED = 20;

	var star:pix.Element;
	var trg:Fruit;
	var tid:Int;

	var life:Int;
	
	public function new(fr:Fruit) {
	
		super();
		star = new pix.Element();
		star.x = fr.x;
		star.y = fr.y;
		star.drawFrame(Gfx.fx.get("mini_star"));
		Stage.me.dm.add(star, Stage.DP_FX);
		
		life = Game.me.numCard(SHOOTING_STAR)*3;
		
	}
	
	override function update() {
		super.update();
		
		if ( trg!=null && (trg.death || trg.dummy || tid != trg.initId ) ) trg = null;
		
		if ( trg == null && life > 0 ) getTarget();
		if ( trg == null ) {
			kill();
			return;
		}
		
		var dx = trg.x - star.x;
		var dy = trg.y - star.y;
		
		var dist = Math.sqrt(dx * dx + dy * dy);
		
		if ( dist > SPEED ) {
			dx *= SPEED / dist;
			dy *= SPEED / dist;
			dist = SPEED;
		}else {
			life--;
			trg.star = true;
			new FruitToTarget(trg, 10,sn);
			if ( Game.me.fruits.length == 0 ) kill();
		}
		
		
		star.x += dx;
		star.y += dy;
		
		// QUEUE
		var ray = 1;
		var sp = new SP();
		var p = new mt.fx.Part(sp);
		sp.graphics.beginFill(0xFFFFFF, 1);
		sp.graphics.drawRect(0, -ray, dist, 2 * ray);
		//sp.graphics.drawRect(0, 0, 4,4);
		Stage.me.dm.add(sp, Stage.DP_UNDER_FX);
		
		p.setPos( star.x, star.y ) ;
		sp.rotation = 180 + Math.atan2(dy, dx) / 0.0174;
		p.timer = 10;
		p.fadeType = 2;
		
		Filt.glow(p.root, 10, 1, 0xFFFFFF);
		sp.blendMode = flash.display.BlendMode.ADD;
		
		
	}
	
	function getTarget() {
		
		for ( fr in Game.me.fruits ) {
			if ( !fr.dummy ) {
				trg = fr;
				tid = trg.initId;
				break;
			}
		}
		
		
	}
	

	override function kill() {
		super.kill();
		star.kill();
	}
	
	

	
	

		
	
//{
}
