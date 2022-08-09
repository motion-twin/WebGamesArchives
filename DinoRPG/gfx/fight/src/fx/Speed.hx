package fx;

import mt.bumdum.Lib;

typedef SpeedRay = {>Phys, coef:Float};

class Speed extends State {

	var caster:Fighter;
	var list:Array<SpeedRay>;
	var trg:Array<Fighter>;
	var speed:Float;
	var step:Int;

	public function new( f, a:Array<Fighter> ) {
		super();
		caster = f;
		addActor(f);
		trg = a;
	}

	override function init() {
		super.init();
		step = 0;
		speed = 0;
		list = [];
		for( i in 0...20 ) {
			var p:SpeedRay  = cast new Phys( Scene.me.dm.attach("mcGhostQueue", Scene.DP_FIGHTER) );
			p.x = Math.random() * Cs.mcw;
			p.y = Scene.getRandomPYPos();
			p.coef = 0.5 + Math.random() * 0.5;
			p.root.stop();
			p.z = -20;
			list.push(p);
			Filt.glow(p.root, 10, 1, 0xFFFF00);
		}
		spc = 0.01;
	}

	public override function update() {
		super.update();
		if( castingWait ) return;
		switch(step) {
			case 0:
				speed += 1;
				moveLines();
				glowFighters();
				if( speed > 100 ) step++;
			case 1:
				speed -= 1.5;
				moveLines();
				if( speed <= 0 ) {
					while(list.length > 0) list.pop().kill();
					end();
				}
				glowFighters();
		}
	}
	
	function moveLines() {
		for( p in list ) {
			p.x += speed * p.coef;
			if( p.x > Cs.mcw ) {
				p.x = -p.root._xscale;
				p.y = Scene.getRandomPYPos();
			}
			p.root._yscale = Math.min(speed * p.coef, 100);
			if( step == 0 ) p.root._xscale = speed * p.coef * 10;
		}
	}

	function glowFighters() {
		for( f in trg ) {
			Col.setPercentColor(f.root, speed * 2, 0xFFFFFF);
			Filt.glow(f.root, 10, 1, 0xFFFF00);
		}
	}
}
