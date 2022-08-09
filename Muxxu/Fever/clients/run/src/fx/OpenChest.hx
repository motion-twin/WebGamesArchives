package fx;
import Protocole;
import mt.bumdum9.Lib;

class OpenChest extends mt.fx.Fx{//}
	
	var sprite:pix.Sprite;
	var ent:world.ent.Reward;
	var mask:flash.display.Sprite;

	var tw:Tween;
	var vy:Float;
	var step:Int;

	public function new(ent:world.ent.Reward ,fr:pix.Frame) {
		this.ent = ent;
		super();
		
		var h = World.me.hero;
		
		//
		sprite = new pix.Sprite();
		sprite.drawFrame( fr );
		Filt.glow(sprite, 2, 4, 0x550000);
		h.island.dm.add(sprite, world.Island.DP_FX);
		sprite.x = h.root.x;
		sprite.y = h.root.y - 8;
		var end = ent.sq.getCenter();
		tw = new Tween(sprite.x, sprite.y, end.x, end.y);
		//
		//
		coef = 0;
		step = 0;
		//
		World.me.setControl(false);
	}
	
	override function update() {
		switch(step) {
			case 0:
				coef = Math.min(coef + 0.05, 1);
				var p = tw.getPos(coef);
				var d = Cs.DIR[[1,0,1,0][World.me.hero.dir]];
				
				var dist = Math.sin(coef*3.14)*20;
				p.x += d[0] * dist;
				p.y += d[1] * dist;
				
				sprite.x = p.x;
				sprite.y = p.y;
				sprite.pxx();
				if( coef == 1 ) open();
				
			case 1:
				coef = Math.min(coef + 0.04, 1);
				sprite.y += vy;
				vy *= 0.8;
				if( coef == 1 ) {
					step++;
					coef = 0;
				}
			
			case 2:
				coef = Math.min(coef + 0.05, 1);
				Col.setColor(sprite, 0, Std.int(coef*255));
				if( coef == 1 ) {
					sprite.filters = [];
					sprite.setAnim(Gfx.fx.getAnim("bonus_vanish"));
					sprite.anim.onFinish = sprite.kill;
					kill();
					World.me.setControl(true);
					world.Inter.me.majStatus();
				}
				
		}

	}
	
	function open() {
		coef = 0;
		step++;
		vy = -2.5;
		
		// FX
		var max = 16;
		var cr = 1;
		for( i in 0...max) {
			var a = i / max * 6.28;
			var speed = 0.5 + Math.random()*5;
			var p = new pix.Part();
			p.setAnim(Gfx.fx.getAnim("spark_twinkle"));
			p.anim.gotoRandom();
			World.me.hero.island.dm.add(p, world.Island.DP_FX);
			p.vx = Math.cos(a) * speed;
			p.vy = Math.sin(a) * speed;
			p.xx = sprite.x + p.vx * cr;
			p.yy = sprite.y + p.vy * cr;
			p.timer = 10+Std.random(10);
			p.frict = 0.8;
			p.updatePos();
		}
		
		//sprite.visible = false;
		
		//ent.sq.conquest();
		ent.majGfx();
		
		sprite.drawFrame(world.ent.Reward.getFrame(ent.rew));
		
		mask = new flash.display.Sprite();
		mask.x = sprite.x;
		mask.y = sprite.y;
		mask.graphics.beginFill(0xFF0000);
		mask.graphics.drawRect(-8, -32, 16, 32);
		World.me.hero.island.dm.add(mask, world.Island.DP_FX);
		
		sprite.mask = mask;
		
		
		
	}
	


	
//{
}








