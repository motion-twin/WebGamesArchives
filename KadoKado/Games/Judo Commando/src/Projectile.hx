import Protocole;
import mt.bumdum.Lib;

class Projectile extends Ent {//}


	var damage:Int;
	var friendlyFireTimer:Int;

	public function new(mc){
		super(mc);
		type = BULLET;
		initPhys();
		vx = 0;
		vy = 0;
		ray = 0.1;
		phaseDist = 0.15;
		friendlyFireTimer = 0;
	}



	public function aimAt(e:Ent,speed){
		var dx = e.root._x - root._x;
		var dy = e.root._y - root._y;
		var a = Math.atan2(dy,dx);
		vx = Math.cos(a)*speed;
		vy = Math.sin(a)*speed;
		setSens();
	}

	override function phase(){

		if( friendlyFireTimer> 0 )friendlyFireTimer--;

		if( friendlyFireTimer == 0 ){
			var a = getNears(Cs.CS*0.5,MONSTER);
			for( m in a ){
				var mon:Mon = cast m;

					switch(mon.state){
						case KnockOut:
							hitKoMonster(mon);
							return;

						case Normal:
							if( mon.checkStealth() )break;
							if( oy<0.5 )mon.tryDodge();
							if( oy >= 0.4 && mon.is(LongJumper) )mon.longJump();

							if( !mon.flCrouch && mon.state==Normal){
								hitStandingMonster(mon);
								return;
							}

						case Wheel,Script, Jump :
							if( mon.checkStealth() )break;
							hitStandingMonster(mon);
							return;


						default:
					}

			}
		}



		if( Game.me.hero.isTargetable() ){
			var dist = getHeroDistance();
			if( dist < 0.6 ){
				hitHero();
				return;
			}
		}
	}

	function hitKoMonster(mon){
		mon.damage(damage);
		fleshKill();
	}
	function hitStandingMonster(mon:Mon){
		mon.flSafe = true;
		mon.knockOut(2*sens,-1.5,Cs.DAMAGE_BULLET);
		mon.oy = 0.6;
		fleshKill();
	}

	function hitHero(){
		var h = Game.me.hero;
		if( h.holdStyle == LIFT && h.sens!=sens )h.bodyShieldImpact(damage);
		else h.hit(sens,damage);
		fleshKill();
	}


	function getHeroDistance(){
		var h = Game.me.hero;
		var dx = (h.px+h.ox) - (px+ox);
		var dy = (h.py+h.oy) - (py+oy);
		if( dy>0 && h.state == Crouch )dy += 0.5;

		if( h.isTouchingGround() ){
			dx = Math.abs(dx)+0.3;
		}
		return Math.sqrt(dx*dx+dy*dy);
	}

	function fleshKill(){
		Game.me.fxAttach("mcBlood",root._x,root._y);
		kill();
	}


	override function onCollision(sx,sy){
		super.onCollision(sx,sy);
		Game.me.fxAttach("fxShotImpact",root._x,root._y);
		kill();
	}


//{
}




















