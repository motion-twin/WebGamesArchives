package bad;
import mt.bumdum9.Lib;

class Lord extends Arrow  {
	
	var spawnMax:Int;
	var step:Int;
	var panic:Float;
	var sk:gfx.Spwaner;
	var gyros:Array<gfx.Gyro>;
	
	public function new() {
		super(LORD);
		setFamily();
		ray = 16;
		
		sk = cast setSkin(new gfx.Spwaner(), 16);
		gyros = [];
		
		speed = 1;
		panic = 0;
		zh = -8;
		
		spawnMax = 3 ;
		if( have(LORD_SPAWN_BONUS) ) spawnMax += 2;
		
		setFloat( 8, 12, 13);
		brainSpawn();
	}
	
	override function update() {
		panic *= 0.9;
		var panicSpeed = have(LORD_PANIC)?5:1;
		speed = 0.75 + panic + (1-life / data.life)* panicSpeed;
		
		super.update();
		switch(step) {
			case 0 :
				if ( timer >= 120 && panic < 0.5 ) {
					step++;
					timer = 0;
					sk._top.gotoAndPlay("open");
				}
				
			case 1 :
				if( timer == 30 ) pop();
				
			case 2 :
				if( timer == 40 ) endPop();
			
		}
	}
	
	function brainSpawn() {
		for ( i in 0...spawnMax ) {
			var mc = new gfx.Gyro();
			var pos = getSpawnPos(i);
			mc.x += pos.x;
			mc.y += pos.y;
			sk.empty.addChild(mc);
			gyros.push(mc);
			var e = new mt.fx.Spawn(mc, 0.025, false, true);
		}
	}
	
	function pop() {
		step++;
		timer = 0;
		sk._top.gotoAndPlay("close");
		
		for ( i in 0...spawnMax ) {
			var b:bad.Gyro = cast spawn(GYRO);
			
			var pos = getSpawnPos(i);
			b.angle = pos.a;
			b.x += pos.x;
			b.y += pos.y + zh;
			b.updatePos();
			b.updatePos();
		}
		
		for( mc in gyros ) mc.parent.removeChild(mc);
		gyros = [];
		
	}
	
	function endPop() {
		timer = 0;
		step = 0;
		brainSpawn();
	}
	
	override function damage(n,an) {
		angle = rnd(628) * 0.01;
		panic = 5;
		return super.damage(n,an);	
	}
	
	override function explode(?angle) {
		super.explode(angle);
		if ( !have(LORD_REVENGE) ) return;
		var max = 12;
		var ray = 12;
		for ( i in 0...max ) {
			var a = i * 6.28 / max;
			var b = spawn(GYRO);
			b.x += Math.cos(a)*ray;
			b.y += Math.sin(a) * ray;
			b.setAngle(a);
		}
	}
	
	public function getSpawnPos(i:Int) {
		var a = 4 + i * 6.28 / spawnMax;
		var n = 6 ;
		return {
			a:a,
			x : Math.cos(a) * n,
			y : Math.sin(a) * n - 2,
		}
	}
}
