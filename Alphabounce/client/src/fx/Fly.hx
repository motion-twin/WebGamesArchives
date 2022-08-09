package fx;
import mt.bumdum.Lib;
import mt.bumdum.Phys;

class Fly extends Phys{//}

	var step:Int;
	var dx:Float;
	var dy:Float;
	var ox:Float;
	var life:Float;
	var angle:Float;
	var speed:Float;



	public function new(mc){
		mc = Game.me.dm.attach("mcInsect",Game.DP_BALL);
		super(mc);
		angle = Math.random()*6.28;
		//speed = 3+Math.random()*0.7;
		frict = 0.95;
		speed = 7 +Math.random()*7;

		x = Math.random()*Cs.mcw;
		y = Cs.mch + 10;
		life = Std.random(1000);

		step = 0;
		root.stop();

		updatePos();
	}

	override public function update(){


		var pad = Game.me.pad;

		switch(step){
			case 0:
				if(dx==null){

					dx = (Math.random()*2-1)*(pad.ray+30);
					dy = - Math.random()*50 +20;
				}

				var ddx = pad.x+dx - x;
				var ddy = pad.y+dy - y;

				var ta = Math.atan2(ddy,ddx);
				var dist = Math.sqrt(ddx*ddx+ddy*ddy);
				var speed = Math.min( speed, dist*0.1 );

				var da = Num.hMod(ta-angle,3.14);
				angle = Num.hMod(angle+da*0.2,3.14);

				x += Math.cos(angle)*speed;
				y += Math.sin(angle)*speed;


				var flGo = Math.random()/mt.Timer.tmod <0.05;

				if( dist < 20 || flGo )dx = null;


				if( Math.abs(pad.x-x)<pad.ray && Math.abs(pad.y+6-y) < 6   ){
					life += 20*mt.Timer.tmod;

					if(life>1000){
						step = 1;
						dx = x - pad.x;
						dy = y - pad.y;
						life = 1000;
						ox = Cs.MX;
						vx = 0;
						vy = 0;
						pad.insect++;
						root.play();
					}

				}


			case 1: // PAD
				x = pad.x + dx;
				y = pad.y + dy;

				life -= Math.abs(ox-Cs.MX)*0.4;
				ox = Cs.MX;

				if( life <=0 ){
					vx = (Math.random()*2-1)*30;
					vy = - (5+Math.random()*20);
					step = 0;
					dx = null;
					pad.insect--;
					root.gotoAndStop(1);
				}

		}
		super.update();

		root.smc.gotoAndStop(2);
		Game.me.plasmaDraw(root);
		root.smc.gotoAndStop(1);

		if( pad == null )kill();

	}



//{
}
