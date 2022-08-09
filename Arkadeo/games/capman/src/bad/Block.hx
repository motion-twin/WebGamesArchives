package bad;
import mt.bumdum9.Lib;
import Protocol;

class Block extends ent.Bad {

	var freezeCycle:Int;
	var freeze:Int;
	var dashDir:Int;
	
	public function new() {
		bid = 2;
		super();
		
		freeze = 10;
		freezeCycle = 35;
		step = WAIT;
		dashDir = -1;

		spc = 0.15;
		free = 4;
		hunter = 2;
		uturn = true;
		
		skin.play("blocker_base");
	}
	
	override function update() {
		super.update();
		switch(step) {
			case WAIT :
				freeze--;
				
				if( freeze < 8 ){
					for( di in 0...4 ) {
						var nsq = square;
						while( true ) {
							if( nsq.getWall(di) > 0 ) break;
							nsq = nsq.dnei[di];
							if( nsq == null || nsq.isBlock() ) break;
							if( nsq.htrack > 1 ) {
								dashDir = di;
								break;
							}
						}
						if( dashDir >= 0 ) break;
					}
				}
				
				if( dashDir >= 0 ) {
					step = MOVE;
					spc = 0.0;
					dir = dashDir;
					skin.play("blocker_angry");
				} else if( freeze <= 0 ) {
					step = MOVE;
				}
				
			case MOVE :
				if( dashDir >= 0 ) spc += 0.02;
				
			case SPECIAL :
				freeze--;
				var lim = 36;
				skin.x = Std.int(freeze * 0.1) * ((freeze % 6) < 3? -1:1);
				if( freeze == 0 ) {
					skin.play("blocker_base");
					step = WAIT;
				}
			default:
		}
	}
	
	override function checkMove() {
		if( dashDir >= 0 ) {
			if( square.getWall(dashDir) > 0 ) bam();
		} else {
			step = WAIT;
			moveCoef = 0;
			freeze = freezeCycle;
			seekDir();
		}
		// SEEK HERO
	}
	
	function bam() {
		// FX SHAKE
		var e = new mt.fx.Shake(Level.me, 0, 8);
		e.fitPix = true;
		
		// BURST WALL
		if( square.getWall(dashDir) == 1 ) {
			var nsq = square.dnei[dashDir];
			if( nsq != null && !nsq.isBlock() ) square.burstWall(dashDir);
		}
		
		moveCoef = 0;
		dashDir = -1;
		step = SPECIAL;
		freeze = 50;
		spc = 0.2;
		
		skin.play("blocker_bam");
		seekDir();
	}
}
