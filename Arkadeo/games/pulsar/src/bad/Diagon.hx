package bad;
import mt.bumdum9.Lib;


class Diagon extends Bad  {//}
	
	public static var RYTHM = 36;
	
	var dir:Int;
	var turn:Bool;
	
	var sk:gfx.Fly;
	
	public function new() {
		super(DIAGON);
		setFamily();
		ray = 8;
		frict = 0.95;
		
		sk = cast setSkin(new gfx.Fly(),8);
		
		setDir(rnd(4));
		timer = RYTHM;
	}

	override function update() {
		// FX
		if ( timer < 20 && timer % 2 == 0 ) 
		{
			Game.me.setFx("diagon_point", x,y, Game.DP_UFX );
		}
		super.update();
		
		if ( timer >= RYTHM ) {
			var impulse = 6;
			if ( turn ) setDir((4+dir + rnd(3) - 1) % 4);
			
			var a = 0.77 + dir * 1.57;
			vx += Math.cos(a)*impulse;
			vy += Math.sin(a)*impulse;
			timer = 0;
			turn = true;
		}
	}
	
	public function setDir(di) {
		dir = di;
		skin.rotation = dir * 90;
	}
	
	override function onRecal(n:Int) {
		if (!turn) return;
		switch(n) {
			case 0 :
				vx *= -1;
				if ( dir == 0 ) setDir(1);
				else if ( dir == 1 ) setDir(0);
				else if ( dir == 2 ) setDir(3);
				else if ( dir == 3 ) setDir(2);

				
			case 1 :
				vy *= -1;
				if ( dir == 0 ) setDir(3);
				else if ( dir == 1 ) setDir(2);
				else if ( dir == 2 ) setDir(1);
				else if ( dir == 3 ) setDir(0);
	
		}
		turn = false;
		
		if ( age < 60 ) return; // YOUNG ONE DONT BREED
		if ( Game.me.bads.length > 80 ) return; // TOO MANY BADS !
		
		var ok = true;
		var a = Game.me.getBadList(DIAGON_EGG);
		for ( b in a ) {
			if ( getDist(b) < 36 ) {		//32
				ok = false;
				break;
			}
		}
		if ( ok ){
			var max = 2;
			if ( have(DIAGON_EGG_BONUS) ) max += 3;
			for ( i in 0...max ) {
				var p = spawn(DIAGON_EGG);
				p.noisePos();
			}
		}
	}
}
