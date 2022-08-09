package fx;
import mt.bumdum9.Lib;
using mt.bumdum9.MBut;
import Protocol;

using mt.Std;
@:build(mt.kiroukou.macros.IntInliner.create([
	BONUS_BOMB,
	BONUS_ANIMALS_ESCAPE,
	BONUS_POINTS_MULT,
	BONUS_QUIETNESS,
])) class Bonus extends mt.fx.Fx {

	public var type(default, null):Int;
	public var mc:gfx.Bonus;
	public var square:Square;

	public function new(sq, ?pType:Array<Int>) {
		super();
		square = sq;
		square.bonus = this;
		
		mc = new gfx.Bonus();
		Game.me.dm.add(mc, Game.DP_GROUND);
		
		var pos = square.getCenter();
		mc.x = pos.x;
		mc.y = pos.y;
		
		mc.blendMode = flash.display.BlendMode.ADD;
		mc.alpha = 0.5;
		Filt.glow(mc, 8, 0.8, 0xFFFFFF);
		
		if( pType == null ) {
			type = [BONUS_BOMB, BONUS_ANIMALS_ESCAPE, BONUS_POINTS_MULT, BONUS_QUIETNESS][Game.me.random(4, "bonus")];
		} else {
			type = pType[Game.me.random(pType.length, "bonus")];
		}
		mc.gotoAndStop(type + 1);
	}
	
	override function update() {
		super.update();
		mc.alpha = (Game.me.gtimer % 24 < 16) ? 0.5 : 0.2;
	}
	
	public function trig() {
		// SPECIAL
		var ball = square.getBall();
		// EFFECT
		var enabled = true;
		switch(type) {
			case BONUS_BOMB : // BOMB
				var ray = 1;
				var max = ray * 2 + 1;
				for( dx in 0...max ) {
					for( dy in 0...max ) {
						var nx = square.x + dx - 1;
						var ny = square.y + dy - 1;
						var sq = Game.me.getSquare(nx, ny);
						if( sq == null ) continue;
						var ball = sq.getBall();
						if( ball == null ) continue;
						ball.burst();
					}
				}
			
			case BONUS_ANIMALS_ESCAPE : // ESCAPE ALL ANIMAL KIND
				var ball = square.getBall();
				var wait = 4;
				for( b in Game.me.balls.copy() ) {
					if( b.type == ball.type ) {
						Game.me.incScore(Cs.BONUS_ESCAPE_POINTS.get(), b.x, b.y);
						b.unregister();
						var e = new fx.Escape(b, wait++);
					}
				}
				
			case BONUS_POINTS_MULT :// 2x POINTS MULTIPLICATOR
				//nothing to do
				enabled = false;
			
			case BONUS_QUIETNESS:
				Game.me.addExtraRound();
				Game.me.addExtraRound();
				
		}
		if( enabled ) {
			// FX
			fxTrig();
			kill();
		}
	}
	
	public function splash() {
		kill();
		fxVanish();
	}
	
	override function kill() {
		square.bonus = null;
		mc.parent.removeChild(mc);
		super.kill();
	}
	
	// FX
	function fxVanish() {
		var p = new mt.fx.ShockWave(60, 120, 0.1);
		Game.me.dm.add(p.root, Game.DP_FX);
		p.root.blendMode = flash.display.BlendMode.ADD;
		p.setAlpha(0.5);
		p.setPos(mc.x, mc.y);
		p.curveIn(0.5);
	}
	
	function fxTrig() {
		// ICON
		var icon = new gfx.Bonus();
		icon.gotoAndStop(type + 1);
		Game.me.dm.add(icon, Game.DP_FX);
		var p = new mt.fx.Part(icon);
		p.setPos(mc.x, mc.y);
		p.setScale(1.5);
		p.sfr = 1.01;
		p.fadeType = 1;
		p.timer = 36;
		p.fadeLimit = 20;
		p.root.blendMode = flash.display.BlendMode.ADD;
		
		// COLOR BURST
		var max = 16;
		for( i in 0...max ) {
			var p = new mt.fx.Spinner( new gfx.Twinkle(), 2+Math.random()*16 );
			p.launch(i * 6.28 / max, Math.random() * 3, Math.random()*8);
			p.setPos(mc.x, mc.y);
			p.timer = 15 + Std.random(30);
			if( Std.random(8) == 0 ) p.timer += 30;
			p.fadeType = 2;
			p.frict = 0.99;
			Game.me.dm.add(p.root, Game.DP_FX);
			p.root.blendMode = flash.display.BlendMode.ADD;
			Col.setColor(p.root, Col.getRainbow2(Math.random()));
		}
	}
}
