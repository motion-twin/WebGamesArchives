package bad;
import mt.bumdum9.Lib;

class Shield extends Arrow  {

	var turnSpeed:Float;
	var mc:gfx.ReflectBall;
	var sk:gfx.ReflectBall;
	
	public function new() {
		super(SHIELD);
		setFamily();
		ray = 16;
		speed = 1;
		sk = cast setSkin(new gfx.ReflectBall(),12);
		setFloat( 12, 4, 43);
		turnSpeed = 0.015;
		if ( have(SHIELD_TURN) ) turnSpeed = 0.036;
	}
	
	override function setPos(x,y) {
		super.setPos(x,y);
		angle = getHeroAngle();
		majAngle();
	}
	
	override function update() {
		super.update();
		follow( hero.x, hero.y, turnSpeed );
		majAngle();
	}
	
	override function damage(n, shot:Shot) {
		var an = Math.atan2(shot.vy, shot.vx);
		var lim = 1.75;
		
		if ( Math.abs(Num.hMod(an - angle, 3.14)) < lim ) {
			new mt.fx.Shake(skin, 5,0);
			return super.damage(n, shot);
		}else {
			an += 3.14;
			var da = Num.hMod(this.angle-an , 3.14);
			an += 2 * da;
			if ( have(SHIELD_REFLECT) ) {
				var sp = 6;
				shot.vx = Math.cos(an) * sp;
				shot.vy = Math.sin(an) * sp;
				shot.orient(an);
				shot.setType(1);
				shot.skin.gotoAndPlay(10);
				new mt.fx.Flash(shot, 0.2, 0xFFCC00,0.25);
			} else {
				var el:EL = new EL();		// WTF o_O
				el.play("shot_dead",false);
				Game.me.dm.add(el, Game.DP_FX);
				
				var sp = 3 + Math.random() * 3;
				var p = new part.Basic(el);
				p.setPos(x+Math.cos(an)*ray, y+Math.sin(an)*ray);
				p.vx = Math.cos(an) * sp;
				p.vy = Math.sin(an) * sp;
				p.vz -= 3 + Math.random() * 3;
				p.zh = -4;
				p.updatePos();
				p.weightZ = 0.6;
				el.anim.onFinish = p.kill;
				
				p.frict = 0.97;
				shot.kill();
			}
			
			#if sound
			Sfx.play(14,0.4);
			#end
			
			return false;
		}
	}
	
	function majAngle() {
		var fr = Std.int(Num.sMod( angle/0.0174 - 90, 360));
		sk.gotoAndStop(fr>>1);
	}

}
