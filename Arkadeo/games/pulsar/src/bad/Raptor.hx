package bad;
import mt.bumdum9.Lib;

class Raptor extends Arrow  {
	
	public static var RYTHM = 36;
	
	var mode:Int;
	var limit:Int;
	var step:Int;
	var sk:gfx.Speedster;
	
	public function new() {
		super(RAPTOR);
		setFamily();
		ray = 18;
		sk = cast setSkin(new gfx.Speedster(),12);
		angle = (rnd(100)/100) * 6.28;
		frict = 0.97;
		mode = 0;
		reset();
		zh = -8;
		setFloat( 6, 6, 9);
		skin.scaleX = skin.scaleY = 1.2;
	}

	override function update() {
		super.update();
		
		var reactorCoef = 0.02+Math.random()*0.05;
		var reactorCoef = 0.04+Math.random()*0.02;
		switch(step) {
			case 0 :
				if( rnd(40) == 0 ) {
					var turn = 0.05;
					va = [ -turn, 0, turn][rnd(3)];
				}
				if( timer > 0 ) {
					va = 0;
					vx = Math.cos(angle) * speed;
					vy = Math.sin(angle) * speed;
					timer = 0;
					speed = 0;
					step++;
					for ( r in reactors ) r.targetSize = 0;
				}
			case 1 :
				reactorCoef = 0.0;
				action();
				
			case 2 :
				reactorCoef = 0.16*(1-timer/40);
				if ( timer > 40 ) reset();
		}
		
		majAngle();
		
		if ( !Game.me.lowQuality )
			{
			// REACTOR
			var mc = new gfx.Explo();
			var ec = 10;
			var bx = x - Math.cos(angle)*3;
			var by = root.y - Math.sin(angle)*3;
			var shake = 2;
			var sc = reactorCoef;
			var m = new MX();
			for( i in 0...2 ) {
				var an = angle + 1.57 * (i * 2 - 1);
				var tx = bx + Math.cos(an)*ec;
				var ty = by + Math.sin(an) * ec;
				
				tx += (Math.random() * 2 - 1) * shake;
				ty += (Math.random() * 2 - 1) * shake;
				
				m.identity();
				m.scale(sc, sc);
				m.translate(tx,ty);
				Game.me.plasma.draw(mc, m);
			}
		}
	}
	
	function action() {
		angle =  getHeroAngle();
		switch(mode) {
			case 0 :
				if ( timer > 60 ) {
					var impulse = 16;
					vx = Math.cos(angle) * impulse;
					vy = Math.sin(angle) * impulse;
					step++;
					timer = 0;
					for ( r in reactors ) {
						r.targetSize = 1;
						r.size = 4;
						r.fxBurst(16);
					}
				}
				
			case 1 :
				if( timer % 8 == 0 ) {
					fire(angle, 16);
					#if sound
					Sfx.play(13);
					#end
				}
				if( timer > 60 ) reset();
		}
	}

	function reset() {
		step = 0;
		var wait = 100 - rnd(20);
		if ( have(RAPTOR_ATTACK_SPEED ) ) wait >>= 1;
		timer = -wait;
		speed = 4;
		if ( have(RAPTOR_FIRE) ) mode = (mode + 1) % 2;
	}
	
	function majAngle() {
		skin.rotation = angle / 0.0174;
		var fr = Std.int(Num.sMod( 180-skin.rotation, 360));
		sk._shadow.gotoAndStop(fr);
	}
}
