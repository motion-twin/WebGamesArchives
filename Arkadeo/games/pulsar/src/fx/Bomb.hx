package fx;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import Protocol;
import api.AKApi;

class Bomb extends mt.fx.Sequence {
	
	var ray:Float;
	
	public function new(ray) {
		super();
		this.ray = ray;
		var h = Game.me.hero;
		h.slowCoef = 2;
		//
		destroyInRay();
		// SHOCKWAVE
		var e = new mt.fx.ShockWave(ray * 0.9, ray * 1.1, 0.04, 0.75);
		e.curveIn(0.5);
		e.setPos(h.x, h.y);
		Game.me.dm.add(e.root, Game.DP_FX);
		Filt.glow(e.root, 8, 4, 0xCC00FF);
		e.root.blendMode = flash.display.BlendMode.ADD;
		e.onFinish = kill;
		
		// PARTS
		var max = Game.me.lowQuality ? 12 : 64;
		var cr  = 6;
		for( i in 0...max) {
			var p = new mt.fx.Part(new gfx.LightBall());
			var an = i * 6.28 / max;
			var pow = 0.5 + Math.random() * 8;
			p.vx = Math.cos(an) * pow;
			p.vy = Math.sin(an) * pow;
			p.setPos(h.x + p.vx * cr, h.y + p.vy * cr);
			p.setScale(0.025 + Math.random() * 0.025);
			Filt.glow(p.root, 4, 1, 0xCC00FF);
			p.root.blendMode = flash.display.BlendMode.ADD;
			Game.me.dm.add(p.root, Game.DP_FX);
			p.frict = 0.96;
			p.timer = 32 + Std.random(5) - Std.int(pow*2);
			p.fadeType = 2;
		}
	}
	
	override function update() {
		super.update();
		destroyInRay();
	}
	
	public function destroyInRay() {
		var h = Game.me.hero;
		// DESTROY
		for( b in Game.me.bads.copy() ) {
			var dx = b.x - h.x;
			var dy = b.y - h.y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if( dist < ray ) b.explode(Math.atan2(dy,dx));
		}
		
		for( sp in Spawn.ALL.copy() ) {
			var dx = sp.trg.x - h.x;
			var dy = sp.trg.y - h.y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if( dist < ray ) sp.kill();
		}
		
		for( sh in Game.me.shots.copy() )  {
			var dx = sh.x - h.x;
			var dy = sh.y - h.y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if( dist < ray ) sh.kill();
		}
	}
}
