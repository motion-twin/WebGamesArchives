package bad;
import mt.bumdum9.Lib;
import Protocol;

class Skull extends ent.Bad {

	var fwait:Int;

	inline static var CHASE_SPEED = 3.5;

	public function new() {
		bid = 1;
		super();
		fwait = 5 + Game.me.rnd(5);
		spc = 0.03;
		
		stopChase();
		skin.play("skull_base");
	}
	
	override function update() {
		super.update();
		if( step == MOVE && speedMult > 2.0 && Game.me.gtimer%2==0 ) {
			var ec = function() return (Math.random() * 2 - 1) * 8;
			var p = new mt.fx.Part(new gfx.Disco());
			p.setPos(root.x + ec(), root.y + ec());
			p.timer = 10 + Std.random(90);
			p.fadeType = 2;
			Level.me.dm.add(p.root, Level.DP_FX);
			p.root.blendMode = flash.display.BlendMode.ADD;
			p.vx = ec() * 0.1;
			p.vy = ec() * 0.1;
			p.frict = 0.96;
		}
	}
	
	override function checkMove() {
		super.checkMove();
		fwait--;
		switch(step) {
			case MOVE :
				if( step == MOVE && speedMult > 2.0  ) stamp();
				if( fwait == 0 ) {
					if( speedMult < CHASE_SPEED ) initChase();
					else 				stopChase();
				}
			case SPECIAL :
			default :
		}
	}
	
	function initChase() {
		var e = new fx.Focus(100, 10, 0.04, 0.6);
		Level.me.dm.add(e.root, Level.DP_FX);
		step = SPECIAL;
		e.setPos(root.x, root.y);
		e.curveIn(2);
		e.onFinish = release;
		e.root.blendMode = flash.display.BlendMode.ADD;
		//
		hunter = 20;
		speedMult = CHASE_SPEED;//was 4
		uturn = true;
		skin.anim.stop();
	}
	
	function stopChase() {
		speedMult = 1.0;
		fwait = 5 +  Game.me.rnd(15);
		hunter = 4;//1
		speedMult = 1.0;
		uturn = false;
		skin.play("skull_base");
	}
	
	function release() {
		stamp();
		for( i in 0...3 ){
			var e = new fx.Focus(0,80-i*20,0.1+i*0.025,0.1);
			e.setPos(root.x, root.y);
			Level.me.dm.add(e.root, Level.DP_FX);
			e.root.blendMode = flash.display.BlendMode.ADD;
			if( i == 0 ) e.onFinish = dash;
		}
	}
	
	function dash() {
		step = MOVE;
		fwait = 7;
		skin.play("skull_fire");
	}
	
	function stamp() {
		var cycle = 80;
		var color = Col.hsl2Rgb((Game.me.gtimer % cycle) / cycle);
		Game.me.plasma.setPixel32(square.x, square.y, 0xFF000000 | color);
	}
}
