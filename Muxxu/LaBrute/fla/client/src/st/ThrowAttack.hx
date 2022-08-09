package st;
import Data;

class ThrowAttack extends State{//}

	static var SPEED = 30;

	var flBack:Bool;

	var att:Fighter;
	var def:Fighter;
	var damage:Int;

	var sx:Float;
	var sy:Float;
	var dx:Float;
	var dy:Float;

	var wp:Phys;


	public function new(aid,tid,damage) {
		this.damage = damage;
		super();

		att = Game.me.getFighter(aid);
		def = Game.me.getFighter(tid);

		setMain();

		att.playAnim("prepareThrow");
		step = 0;
		cs = 0.06;




	}



	override function update() {
		super.update();

		switch(step){
			case 0:
				if(coef==1)throwWeapon();

			case 1:
				wp.x = sx + dx*coef;
				wp.y = sy + dy*coef;
				if(coef==1)strike();
			case 2 :
				if(coef==1){
					wp.kill();
					att.backToNormal();
					def.backToNormal();
					end();
					kill();
				}
		}

		//att.root._alpha = Std.random(100);


	}


	public function throwWeapon(){
		att.playAnim("throw");
		att.removeWeapon(att.wp);
		step = 1;
		coef = 0;

		sx = att.x - att.side*10;
		sy = att.y - 12;
		dx = def.x - sx;
		dy = def.y - sy;

		wp = new Phys( Game.me.dm.attach("mcWeapon",Game.DP_FIGHTERS) );
		wp.root.gotoAndStop( Type.enumIndex(att.wp)+1 );
		wp.x = sx;
		wp.y = sy;
		wp.z = -25;
		wp.ray =10;
		wp.dropShadow();
		wp.updatePos();
		wp.root._xscale = -att.side * 100;

		cs = SPEED/Math.abs(dx);

		if( Data.WEAPONS[Type.enumIndex(att.wp)].type != Throw ){
			att.setWeapon(att.gladiator.defaultWeapon);
		}


	}

	public function strike(){
		step = 2;
		coef = 0;
		cs = 0.1;

		if( damage>0 ){
			def.hurt(damage);
			wp.kill();
		}else if( damage < 0 ){
			def.dodge();
			var a = Math.atan2(dy,dx);
			wp.vx =  Math.cos(a)*SPEED;
			wp.vy =  Math.sin(a)*SPEED;

		}else{
			def.parry();
			wp.kill();
		}


	}



//{
}