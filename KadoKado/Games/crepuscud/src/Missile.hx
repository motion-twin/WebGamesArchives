
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;


class Missile extends Projectile {//}

	public static var BOOST = 0;
	public static var COLOR = [0xAAFF66,0x88AAFF,0xFF66CC];

	public var special:Int;

	public function new( ?mc : flash.MovieClip ){

		if(mc==null)mc = Game.me.dm.attach("mcMissile",Game.DP_MISSILE);
		super(mc);


		var speed = 0.75+Math.random()*Game.me.dif*0.5;

		x = Math.random()*Cs.mcw;
		y = -speed*4;

		var ma = 45;
		var tx = ma+Math.random()*(Cs.mcw-(ma+5));
		var ty = Cs.mch;

		var dx = tx-x;
		var dy = ty-y;


		// SPECIAL
		if( Std.random(10) == 0 )	special = 0;
		if( Std.random(60) == 0 )	special = 1;
		if( Std.random(300) == 0 )	special = 2;
		if(special!=null)qcol = COLOR[special];


		//
		setAngle( Math.atan2(dy,dx) );

		if(special!=null)speed = [3,5,9][special];
		setSpeed( speed + BOOST );

		//
		Game.me.missiles.push(this);
		Game.me.totalSpeed += speed;






	}


	override function update(){

		super.update();

		//
		if( y > Game.GY ){
			var gy = Game.me.getGroundHeight(Std.int(x));
			if( y > gy ){
				y = gy;
				groundExplode();
			}
			return;
		}





		//var m = new flash.geom.Matrix();


	}

	//
	public function explode(pool){

		var onde = new Onde(x,y,Cs.RAY_MISSILE);
		onde.pool = pool;
		//

		var score = KKApi.cmult( Cs.SCORE_MISSILE[pool.n], KKApi.const(pool.multi) );
		if(special!=null)score = Cs.SCORE_BONUS[special];
		Game.me.addScore(x,y,score,special);


		//
		var max = 24;
		var cr = 8;
		for( i in 0...max ){
			var a = (i+Math.random())/max *6.28;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var speed = 1.5+Math.random()*3;
			var p = new Phys(Game.me.dm.attach("partSquareLight",Game.DP_PARTS));
			p.x = x+ca*speed*cr;
			p.y = y+sa*speed*cr;
			p.vx = ca*speed;
			p.vy = sa*speed;
			p.timer = 10+Math.random()*20;
			p.fadeType = 0;
			p.root.gotoAndPlay(Std.random(2)+1);
			p.weight = 0.05+Math.random()*0.1;
			p.frict = 0.9;

		}


		Game.me.expl++;
		kill();
	}
	public function groundExplode(){

		// HOLE
		Game.me.makeHole(x,y,0.15+Math.random()*0.05);
		//Game.me.makeHole(x,y,0);

		// FX
		var mc = Game.me.dm.attach("fxDemiOnde",Game.DP_MISSILE);
		mc._x = x;
		mc._y = y;

		//
		var max = 18;
		var cr = 5;
		for( i in 0...max ){
			var a = - (i+Math.random())/max *3.14;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var speed = 0.2+Math.random()*3;
			var p = new Phys(Game.me.dm.attach("partDirt",Game.DP_PARTS));
			p.x = x+ca*speed*cr;
			p.y = y+sa*speed*cr;
			p.vx = ca*speed;
			p.vy = sa*speed;
			p.timer = 10+Math.random()*20;
			p.fadeType = 0;
			p.weight = 0.15+Math.random()*0.15;
			p.setScale(50+Math.random()*50);
		}


		kill();
	}

	//
	override function kill(){
		Game.me.missiles.remove(this);
		Game.me.totalSpeed -= speed;
		super.kill();
	}




//{
}



























