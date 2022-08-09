package st;
import Data;

class Net extends State{//}


	var att:Fighter;
	var def:Fighter;

	var dx:Float;
	var dy:Float;
	var sx:Float;
	var sy:Float;

	var net:Phys;


	public function new(aid,tid) {
		super();
		step = 0;
		att = Game.me.getFighter(aid);
		def = Game.me.getFighter(tid);
		setMain();

		cs = 0.35;
		att.playAnim("launch");

	}


	override function update() {
		super.update();

		switch(step){
			case 0: // NET
				if(coef>=1){
					net = new Phys(Game.me.dm.attach("mcNet",Game.DP_FIGHTERS));
					net.ray = 10;
					net.dropShadow();
					net.x = att.x;
					net.y = att.y+1;
					net.z = -50;
					net.updatePos();

					coef = 0;
					cs = 0.05;
					step = 1;

					sx = net.x;
					sy = net.y;
					dx = (def.x-def.side*17)-sx ;
					dy = def.y-sy ;

				}


			case 1:
				net.x = sx+dx*coef;
				net.y = sy+dy*coef;
				net.z = -Math.sin(0.14+coef*2.8)*150;

				if(coef>=1){
					att.backToNormal();
					def.playAnim("net");
					net.kill();
					kill();
					end();

				}

		}



	}











//{
}