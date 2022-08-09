package bad;
import mt.bumdum9.Lib;

class Coward extends Bad  {
	var sk:gfx.Coward;
	var stress:Int;
	
	public function new() {
		super(COWARD);
		setFamily();
		ray = 9;
		sk = cast setSkin(new gfx.Coward(), 8);
		sk.stop();
		setFloat( 5, 5, 33);
		frict = 0.94;
		stress = 0;
	}

	override function update() {
		super.update();
		//
		var danger = Game.me.bulletField.getRed(x, y);
		if( danger < 20 ) {
			var an = getHeroAngle();
			var acc = 0.35;
			vx += Math.cos(an) * acc;
			vy += Math.sin(an) * acc;
			if( stress > 0 ) stress -= 2;
		} else {
			if( stress < 80 ) stress++;
		}

		// ESCAPE
		var an = Game.me.bulletField.getEscape(x, y, 12, 32+stress);
		var acc = 0.5;
		vx += Math.cos(an) * acc;
		vy += Math.sin(an) * acc;
	}
	
	override function damage(n,sh:Shot) {
		
		var an = Math.atan2(sh.vy, sh.vx);
		var pow = 7;
		vx += Math.cos(an) * n * pow;
		vy += Math.sin(an) * n * pow;
		return super.damage(n, sh);
	}
}
