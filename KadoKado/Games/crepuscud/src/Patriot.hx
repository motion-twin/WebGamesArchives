
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;


class Patriot extends Projectile {//}


	static var HERO_RAY = 20;

	var distanceMax:Float;
	var parc:Float;
	public var mcTarget:flash.MovieClip;

	public function new( ?mc : flash.MovieClip ){

		if(mc==null)mc = Game.me.dm.attach("mcPatriot",Game.DP_MISSILE);
		super(mc);
		Game.me.patriots.push(this);


		parc = 0;

		var dx = Game.me.root._xmouse - Game.DX;
		var dy = Game.me.root._ymouse - Game.RGY;

		angle = Game.me.angle;
		distanceMax = Math.sqrt(dx*dx+dy*dy) - HERO_RAY;
		x = Game.DX + Math.cos(angle)*HERO_RAY;
		y = Game.RGY + Math.sin(angle)*HERO_RAY;

		setAngle(angle);
		setSpeed(10);

		if(Game.me.expl<5){
			mcTarget = Game.me.dm.attach("mcTarget",Game.DP_PLASMA);
			mcTarget._x = Game.me.root._xmouse;
			mcTarget._y = Game.me.root._ymouse;
			mcTarget._alpha = 50;
		}

	}


	override function update(){
		super.update();
		parc += speed*mt.Timer.tmod;

		if( parc >= distanceMax ){
			explode();
		}

	}

	//
	public function explode(){

		var onde = new Onde(x,y,Cs.RAY_PATRIOT);
		var multi = 1;

		if( Cs.FL_PERFECT ){
			for( mis in Game.me.missiles ){
				var dx = x-mis.x;
				var dy = y-mis.y;
				if( Math.sqrt(dx*dx+dy*dy) < Cs.PERFECT_RAY )multi = 2;
			}
		}

		onde.pool = { n:0, multi:multi };
		kill();

		//
		mcTarget.removeMovieClip();


	}

	//
	override function kill(){
		Game.me.patriots.remove(this);
		super.kill();
	}




//{
}



























