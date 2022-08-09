package st;
import Data;
import mt.bumdum.Lib;

class Grab extends State{//}

	static var RAY = 16;
	static var HEIGHT = 400;
	//static var DECAL = 100;

	var flBack:Bool;

	var att:Fighter;
	var def:Fighter;

	var damage:Int;

	var flip:Float;
	var cx:Float;
	var cy:Float;

	var dx:Float;
	var dy:Float;
	var sx:Float;
	var sy:Float;

	public function new(aid,tid,damage) {
		super();
		this.damage = damage;
		step = 0;
		att = Game.me.getFighter(aid);
		def = Game.me.getFighter(tid);

		goto();
		setMain();

	}


	override function update() {
		super.update();

		switch(step){
			case 0: // MOVE
				att.x = sx +dx*coef;
				att.y = sy +dy*coef;
				if(coef>=1){
					step = 1;
					//att.playAnim("hurt3");
					//def.playAnim("hurt3");
					att.vx = -att.side*4;
					def.vx = -att.side*4;
					att.playAnim("grab");
					def.playAnim("grabbed");
					coef = 0;
					cs = 0.15;

					//def.z = -DECAL;

				}

			case 1: // WAIT
				if(coef>=1){
					step = 2;
					cx = (att.x+def.x)*0.5;
					cy = (att.y+def.y)*0.5;
					flip = 0;
					coef = 0;
					cs = 0.07;
					att.vx = 0;
					att.vy = 0;

				}

			case 2: // SKY
				cx += 1;
				spin();


				var height = 400;

				var c = Math.sin(coef*1.57);
				att.z = -c*HEIGHT;
				def.z = -c*HEIGHT;

				if(coef>=1){
					coef = 0;
					cs = 0.2;
					step = 3;
					//Filt.blur(att.box,0,20);
					//Filt.blur(def.box,0,20);
					//def.root._yscale *= -1;

				}
			case 3: // DOWN
				spin();
				var c = Math.sin(1.57+coef*1.57);
				att.z = -c*HEIGHT;
				def.z = -c*HEIGHT;
				if(coef>=1){
					att.box.filters = [];
					def.box.filters = [];
					att.setSens(1);
					def.setSens(1);
					jumpBack();
					def.hurt(damage);
					def.vx *= 0.5;

				}
			case 4 :
				att.x = sx + dx*coef;
				att.y = sy + dy*coef;
				att.z = - Math.sin(coef*3.14)*80;

				if(coef>=1){

					flBack = true;
					goto();
					step  = 5;
				}
			case 5 :
				att.x = sx +dx*coef;
				att.y = sy +dy*coef;
				if(coef>=1){
					att.backToNormal();
					def.backToNormal();
					att.setSens(1);
					end();
					kill();
				}



		}



	}

	function spin(){
		flip = (flip+0.51)%6.28;
		var pos = Math.cos(flip)*RAY;
		att.x = cx + pos;
		def.x = cx - pos;
		att.setSens( att.x>cx?att.side:-att.side );
		def.setSens( def.x>cx?-att.side:att.side );
	}


	function jumpBack(){
		coef = 0;
		step = 4;

		var tx = att.x+att.side*120;
		var ty = att.y;

		sx = att.x;
		sy = att.y;
		dx = tx - sx;
		dy = ty - sy;

		cs = 0.1;
		att.playAnim("jump");
	}



	function goto(){
		coef = 0;
		step = 0;

		var tx = def.x - 10*def.side;
		var ty = def.y-1;

		if(flBack){

			tx = Cs.mcw*0.5+att.side*50;
			ty = att.y;
			att.setSens(-1);

		}

		sx = att.x;
		sy = att.y;
		dx = tx - sx;
		dy = ty - sy;

		var dist = Math.sqrt(dx*dx+dy*dy);
		cs = 20/dist;
		att.playAnim("run");
	}









//{
}