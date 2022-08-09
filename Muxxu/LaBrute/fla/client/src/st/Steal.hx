package st;
import Data;

class Steal extends State{//}

	var flBack:Bool;

	var att:Fighter;
	var def:Fighter;

	var dx:Float;
	var dy:Float;
	var sx:Float;
	var sy:Float;


	public function new(aid,tid) {
		super();
		step = 0;
		att = Game.me.getFighter(aid);
		def = Game.me.getFighter(tid);

		jump();

		setMain();





	}


	override function update() {
		super.update();

		switch(step){
			case 0: // JUMP IN
				var ang = 3.0;
				if(flBack)ang = 3.14;

				att.x = sx +dx*coef;
				att.y = sy +dy*coef;
				att.z = -Math.sin(coef*ang)*260;
				if(coef>=1){
					if(flBack){
						att.backToNormal();
						def.backToNormal();
						att.setSens(1);
						end();
						kill();
					}else{
						att.setWeapon(def.wp);
						att.addWeapon(def.wp);
						def.removeWeapon(def.wp);
						def.setWeapon(def.gladiator.defaultWeapon);

						step = 1;
						att.setSens(-1);
						att.playAnim("steal");
						def.playAnim("stolen");
						cs = 0.05;
						coef = 0;
					}
				}


			case 1: // WAIT
				if(coef>=1){

					att.playAnim("jump");
					def.fxHurt();
					def.vx = 0;
					flBack = true;
					jump();

				}
			case 2:



				/*
				if(coef==1 && !att.flAnim && !def.flAnim ){
					att.backToNormal();
					def.backToNormal();
					end();
					kill();
				}
				*/

		}



	}

	function jump(){
		coef = 0;
		step = 0;
		var tx = def.x;
		var ty = def.y-1;

		if(flBack){
			tx = sx;
			ty = sy;
		}

		sx = att.x;
		sy = att.y;
		dx = tx - sx;
		dy = ty - sy;

		var dist = Math.sqrt(dx*dx+dy*dy);
		cs = 20/dist;
		att.playAnim("jump");
	}









//{
}