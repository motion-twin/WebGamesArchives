package bad;
import mt.bumdum9.Lib;

class Chaser extends Bad  {
	
	public static var SPEED = 2;
	//
	var angle:Float;
	var va:Float;
	var sk:gfx.Blob;
	public var chase:Int;
	public var decFloat:Int;

	public function new() {
		super(CHASER);
		setFamily();
		ray = 8;
		//goto(1,"chaser");
		
		sk = cast setSkin(new gfx.Blob(),8);
		angle = rnd(628)*0.01;
		va = 0;
		chase = 0;
		decFloat = rnd(628);
	}
	
	override function update() {
		super.update();
		var speed = SPEED;
		if ( chase > 0 ) {
			chase--;
			var a = getHeroAngle();
			var da = Num.hMod(a - angle, 3.14);
			var lim = 0.1;
			angle += Num.mm( -lim, da*0.5, lim);
			speed += 2;
		} else {
			va += rnc(true) * 0.1;
			va *= 0.9;
			angle += va;
		}
		
		x += Math.cos(angle) * speed;
		y += Math.sin(angle) * speed;
		
		orient(angle, 4);
		
		decFloat =  (decFloat + 7) % 628;
		zh = -(12 + Math.cos(decFloat * 0.01) * 8);
	}
	
	override function explode(?angle) {
		super.explode(angle);
		var a:Array<Chaser> = cast Game.me.getBadList(CHASER);
		for ( b in a ) {
			if( getDist(b) < 120 )	b.chase += 30+rnd(20);
		}
	}
	
	override function onRecal(n:Int) {
		var dx = Math.cos(angle);
		var dy = Math.sin(angle);
		switch(n) {
			case 0 : angle = Math.atan2(dy,-dx);
			case 1 : angle = Math.atan2(-dy,dx);
		}
	}
}

