package bad;
import mt.bumdum9.Lib;

class Whale extends Bad  {
	
	var sk:gfx.Whale;
	var step:Int;
	var wait:Int;
	var tw:Tween;
	var di:Int;
	var range:Float;
	var speedBase:Float;

	public function new() {
		super(WHALE);
		setFamily();
		ray = 16;
		sk = cast setSkin(new gfx.Whale(), 16);
		sk.stop();
		setFloat( 8, 8, 13);
		step = 0;
		wait = 20;
		di = rnd(2);
		range = 80;
		frict = 0.9;
	}

	override function update() {
		super.update();
		switch(step) {
			case 0 :
				if( timer > wait ) move();
			case 1 :
				var c = Math.min(timer / speedBase, 1);
				var pos = tw.getPos( 0.5-Math.cos(c*3.14)*0.5 );
				setPos(pos.x,pos.y);
				if( c == 1 ) {
					step = 0;
					timer = 0;
					wait = Std.int((30 + rnd(30))*(1-age/400));
					range += 20;
					sk.gotoAndStop("stand");
				}
		}
	}
	
	override function damage(n,sh:Shot) {
		var an = Math.atan2(sh.vy, sh.vx);
		var pow = 2;
		vx += Math.cos(an) * n * pow;
		vy += Math.sin(an) * n * pow;
		if(step == 0) sk.gotoAndStop("hit");
		return super.damage(n, sh);
	}
	
	function move() {
		sk.gotoAndStop("bad");
		
		step++;
		timer = 0;
		
		var dx = Num.mm( -range, Game.me.hero.x - x, range);
		var dy = Num.mm( -range, Game.me.hero.y - y, range);
		
		if( di == 0 ) dx = 0;
		if( di == 1 ) dy = 0;
		
		tw = new Tween(x, y, x + dx, y + dy);
		speedBase = Math.min(tw.getDist() * 0.5, 32);
		
		di = (di + 1) % 2;
	}
}
