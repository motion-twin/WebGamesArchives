import Game;
import mt.bumdum.Phys;
import mt.bumdum.Lib;


class Tracker extends Phys{//}

	public static var REACH = 20;

	var flControl:Bool;

	public var cpi:Int;
	public var wp:CheckPoint;

	public var angle:Float;
	public var decalMax:Float;
	public var speed:Float;
	public var da:Float;
	public var groundFrict:Float;
	public var map:{>flash.MovieClip,race:flash.MovieClip,bg:flash.MovieClip};

	public var turnCoef:Float;
	public var turnLimit:Float;

	function new(mc){
		super(mc);
		angle = 0;
		speed = 0;
		da =  0;
		decalMax = 14;
		groundFrict = 0.95;

		cpi = 0;

		turnCoef = 0.1;
		turnLimit = 0.8;

	}

	function move(){

		speed *= Math.pow(groundFrict,mt.Timer.tmod);


		var wpx = wp.x;
		var wpy = wp.y;

		if(flControl && Game.me.chronoTimer>14 ){
			var dist = 12;

			var cx = Num.mm(0,Game.me.root._xmouse/Cs.mcw,1);
			var cy = Num.mm(0,Game.me.root._ymouse/Cs.mch,1);

			wpx += (cx*2-1)*dist;
			wpy += (cy*2-1)*dist;
		}

		var dx = wpx - x;
		var dy = wpy - y;
		var ta = Math.atan2(dy,dx);
		da = Num.hMod(ta-angle,3.14);

		var lim = turnLimit;
		angle += Num.mm(-lim,da*turnCoef,lim)*mt.Timer.tmod;
		vx = Math.cos(angle)*speed;
		vy = Math.sin(angle)*speed;

		root._rotation = angle/0.0174;

		angle = Num.hMod(angle,3.14);

		super.update();


		/*
		if( pid==0 ){
			haxe.Log.clear();
			var da = Num.hMod(wp.a-ta,3.14);
			trace(Std.int(da*100)/100);
		}
		*/

		if( Math.sqrt(dx*dx+dy*dy) < REACH ){
			var da = Num.hMod(wp.a-ta,3.14);
			//haxe.Log.clear();
			//trace(da);
			nextWayPoint();
		}

	}

	// WAYPOINT
	function nextWayPoint(){
		setWayPoint((cpi+1)%Game.me.checkpoints.length);
	}

	public function setWayPoint(n){
		cpi = n;
		var c = Game.me.checkpoints[cpi];
		var ray = (Math.random()*2-1)*decalMax ;
		//if(flPlayer)ray = 0;


		wp = {
			x:c.x+Math.cos(c.a)*ray,
			y:c.y+Math.sin(c.a)*ray,
			a:c.a
		}

	}
	public function goto(n){
		setWayPoint(n);
		x = wp.x;
		y = wp.y;
		angle =wp.a-1.57;
	}


//{
}















