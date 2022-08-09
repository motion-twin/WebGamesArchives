import Protocole;
import mt.bumdum.Lib;

class Rocket extends Projectile {//}


	var smokeLoop:Int;

	public function new(){
		super(Game.me.dm.attach("mcRocket",Game.DP_PROJECTILES));
		friendlyFireTimer = 8;
		damage = Cs.DAMAGE_BULLET;
		smokeLoop = 0;
	}

	override function update(){
		super.update();
		if(smokeLoop++ == 2){
			var mc = Game.me.dm.attach("fxSmoke",Game.DP_FX);
			mc._x = root._x - (2+Std.random(2))*sens;
			mc._y = root._y + Std.random(5)-2;
			smokeLoop = 0;
		}
	}



	override function hitStandingMonster(mon){
		boum();
	}
	override function hitKoMonster(mon){
		boum();
	}
	override function hitHero(){
		boum();
	}

	function boum(){
		Game.me.fxShake(20);
		explode(24);
		kill();
	}
	override function onCollision(sx,sy){
		var sq = Game.me.getSq(px+sx,py+sy);
		if(sq.type==BLOCK)Game.me.explodeSquare(px+sx,py+sy);
		boum();
	}



//{
}




















