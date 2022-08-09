package fx;
import Protocole;
import mt.bumdum9.Lib;

class SpawnStatue extends mt.fx.Fx{//}

	var mask:flash.display.Sprite;
	var sta:world.ent.Statue;
	var stoneCount:Float;
	
	public function new(ent) {
		sta = ent;
		super();
		sta.base.y = 300;
		coef = 0;
		stoneCount = 0;
		
		mask = new flash.display.Sprite();
		mask.x = ent.x;
		mask.y = ent.y;
		mask.graphics.beginFill(0xFF0000);
		mask.graphics.drawRect( -16, -32, 32, 36);
		World.me.island.dm.add(mask, world.Island.DP_ELEMENTS);
		sta.mask = mask;
		
		new mt.fx.Shake(World.me.screen, 4, 0, 0.97);
		
	}
	
	

	override function update() {
		super.update();

		// UP
		coef = Math.min(coef + 0.01, 1);
		var c = 1 - Math.pow(coef, 2.5);
		sta.base.y = Std.int(c * 22);
		
		// FX
		stoneCount += c;
		while( stoneCount > 0 ) {
			stoneCount--;
			var p = new pix.Part();
			p.drawFrame(Gfx.fx.get(Std.random(7), "dirt_stones"));
			p.xx = (Math.random() * 2 - 1) * 6;
			p.yy = - Std.random(24);
			p.updatePos();
			p.vx = (Math.random() * 2 - 1)*0.5;
			p.vy = -(1 + Math.random() * 2);
			p.weight = 0.2 + Math.random() * 0.1;
			p.timer = 10 + Std.random(20);
			p.frict = 0.95;
			sta.base.addChild(p);
			//World.me.island.dm.add(p, world.Island.DP_ELEMENTS);
		}
		
		
		if(coef == 1 ) {
			var fx = new mt.fx.Flash(sta,0.05);
			fx.glow(8, 4);
			kill();
		}
		
	}

	

	
//{
}








