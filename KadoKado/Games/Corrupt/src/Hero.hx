import mt.bumdum.Lib;

enum MoveMode {
	FOLLOW;
	STRAFE;
}

class Hero extends Sprite {//}

	var flPress:Bool;

	var mode:MoveMode;
	var mcTrg:{>flash.MovieClip,dx:Float,dy:Float};
	var angle:Float;
	var cooldown:Float;


	public function new(){
		super(Game.me.dm.attach("mcHero",Game.DP_HERO));
		x = 150;
		y = 150;
		flash.Mouse.hide();

		mcTrg = cast Game.me.dm.attach("mcTarget",Game.DP_HERO);
		mcTrg.dx = 0;
		mcTrg.dy = 0;

		mcTrg._xscale = mcTrg._yscale = 200;
		mcTrg.stop();

		mode = FOLLOW;

		var o = {};
		var me = this;
		Reflect.setField(o,"onMouseDown",function(){me.flPress=true;});
		Reflect.setField(o,"onMouseUp",function(){me.flPress=false;});
		flash.Mouse.addListener(cast o );


	}

	override function update(){

		move();
		moveTrg();
		shoot();

		super.update();

	}

	function move(){
		var dx = Game.me.root._xmouse - x;
		var dy = Game.me.root._ymouse - y;
		var lim = 60;
		var c = 0.2;
		var vx = Num.mm(-lim,dx*c,lim);
		var vy = Num.mm(-lim,dy*c,lim);
		x += vx;
		y += vy;
	}

	function moveTrg(){

		mode = flPress?STRAFE:FOLLOW;

		switch(mode){
			case FOLLOW :
				var dx = mcTrg._x - x;
				var dy = mcTrg._y - y;
				var a = Math.atan2(dy,dx);
				var lim = 35;
				if( Math.sqrt(dx*dx+dy*dy) > lim ){
					mcTrg._x = x + Math.cos(a)*lim;
					mcTrg._y = y + Math.sin(a)*lim;
				}
				angle = a;
				mcTrg.dx = dx;
				mcTrg.dy = dy;

				var c = Num.sMod(a,6.28)/6.28;



				root.gotoAndStop(1+Std.int(c*40));

				mcTrg.gotoAndStop(1+Num.sMod( Math.round(angle/6.28*8),8));


			case STRAFE :
				mcTrg._x = x + mcTrg.dx;
				mcTrg._y = y + mcTrg.dy;
		}





	}

	function shoot(){

		if(cooldown>0){
			cooldown--;
			return;
		}
		mcTrg.smc.play();

		var speed=  15;
		var sp = new Sprite( Game.me.dm.attach("mcShoot",Game.DP_SHOTS));
		var cx = Math.cos(angle);
		var cy = Math.sin(angle);
		sp.x = mcTrg._x + cx*10;
		sp.y = mcTrg._y + cy*10;
		new sbh.Phys(sp,cx*speed,cy*speed);
		//new sbh.Timer(sp,10,10,1);
		new sbh.Bounds(sp,Game.me.zone,sp.kill,20);

		sp.root._rotation = angle/0.0174;



		sp.updatePos();
		cooldown = 4;



	}



//{
}