import Physics;
import mt.bumdum.Phys;
import mt.bumdum.Lib;

typedef Point = {>flash.MovieClip, dx:Float, dy:Float, rx:Float, ry:Float };

class Ball implements PhysicObject<Ball> {//}

	public static var RAY = 12;

	var color:Int;


	var dcx : Float;
	var dcy : Float;
	var pList:Array<Point>;

	var dm:mt.DepthManager;

	// user/sim vars
	public var x : Float;
	public var y : Float;
	public var r : Float;
	public var dx : Float;
	public var dy : Float;
	public var mass : Float;

	// for computation
	public var col : Float;
	public var target : Ball;
	public var sx : Float;
	public var sy : Float;

	public var root : {>flash.MovieClip, skin:flash.MovieClip};
	var shade : flash.MovieClip;

	public function new() {
		root = cast Game.me.dm.attach("ball",Game.DP_BALL);
		shade = Game.me.sdm.attach("mcBallShadow",0);

		dm = new mt.DepthManager(root);

		x = 0;
		y = 0;
		dx = 0;
		dy = 0;
		r = RAY;
		mass = r;

		dcx = Std.random(628);
		dcy = Std.random(628);

		root.skin._visible = false;


		//initPoints();




	}

	public function update() {

		root._x = x;
		root._y = y;

		shade._x = x+4;
		shade._y = y+4;

		//updatePoints();

		/*
		var c = 3;
		dcx = Num.sMod( dcx-Math.sqrt(dx*dx+dy*dy)*c,628 );

		var cos = Math.cos(dcx*0.01);
		root.skin.smc._x = cos*RAY;
		root.skin.smc._xscale = 100-Math.abs(cos)*100;
		root.skin.smc._visible = dcx<314;

		var dr = Num.hMod( Math.atan2(dy,dx)/0.0174 - root.skin._rotation, 180 );
		root.skin._rotation += dr;
		root.skin.smc.smc._rotation -= dr;
		*/

		/*
		var c = 2;
		dcx = Num.sMod(dcx-dx*c,628);
		dcy = Num.sMod(dcy-dy*c,628);

		root.skin.smc._visible = dcx<314 && dcy<314;

		var cos = Math.cos(dcx*0.01);
		root.skin.smc._x = cos*RAY;
		root.skin.smc._xscale = 100-Math.abs(cos)*100;


		var sin = Math.sin(dcy*0.01);
		root.skin.smc.smc._y = sin*RAY;
		root.skin.smc.smc._yscale = 100-Math.abs(sin)*100;
		*/


		/*
		if( color==3 && Math.sqrt(dx*dx+dy*dy)>3){
			Game.me.plasma.drawMc(root);
		}
		*/


	}

	//
	/*
	public function initPoints(){
		pList = [];
		var max = 8;
		for( n in 0...max ){
			var mc:Point = cast dm.attach("mcPoint",0);
			mc.dx = Math.random()*628;
			mc.dy = Math.random()*628;
			mc.rx = Math.random()*10;
			mc.ry = Math.random()*10;
			pList.push(mc);

		}
	}
	public function updatePoints(){

		var c = 3;

		for( mc in pList ){
			mc.dx = (mc.dx+dx*c)%628;
			mc.dy = (mc.dy+dy*c)%628;
			mc._x = Math.sin(mc.dx*0.01)*mc.rx;
			mc._y = Math.sin(mc.dy*0.01)*mc.ry;

			//mc._alpha = (1-Math.max(mc.dx,mc.dy)/628)*100;

			mc._alpha = 50+Math.sin(mc.dx*0.01)*50;
			mc._alpha = Math.min(mc._alpha, 50+Math.sin(mc.dy*0.01)*50 );

		}
	}
	*/

	//
	public function onCollide( ?b : Ball ) : Void {
		if( b.color == 3 ){
			switch(color){
				case 0 : swapColor(Game.me.currentColor);
				case Game.me.currentColor : explode(b);
				case Game.me.passiveColor : swapColor(0);
			};
		}

	}
	function explode(ball){

		var mcScore = Game.me.incScore(color-1);

		if( !MMApi.isReconnecting() ){
			// PART SCORE
			var p = new ScoreBall(Game.me.dm.attach("partScoreBall",Game.DP_PARTS));
			p.x = x;
			p.y = y;
			p.vx = dx*0.5;
			p.vy = dy*0.5;
			p.angle = Geom.getAng(this,ball);
			p.trg = mcScore;
			p.color = Game.me.colors[color-1];

			// BIG PART
			var mc:{>flash.MovieClip, smc0:flash.MovieClip, smc1:flash.MovieClip } = cast Game.me.dm.attach("mcBallExplode",Game.DP_PARTS);
			mc._x = x;
			mc._y = y;
			Col.setColor(mc.smc0,Game.me.colors[color-1]);
			Col.setColor(mc.smc1,Game.me.colors[color-1]);

			// PARTS LIGHT
			var max = 10;
			var cr = 2;
			for( i in 0...max ){
				var a = (i+Math.random())/max *6.28;
				var ca = Math.cos(a);
				var sa = Math.sin(a);
				var sp = 0.5+Math.random()*10;
				var p = new Phys(Game.me.dm.attach("partLight",Game.DP_PARTS));
				p.x = x+ca*sp*cr;
				p.y = y+sa*sp*cr;
				p.vx = ca*sp + dx*0.4;
				p.vy = sa*sp + dy*0.4;
				p.frict = 0.9;
				p.timer = 10+Math.random()*15;
			}
		}
		//
		kill();
	}
	function swapColor(n){
		setColor(n);
		if( !MMApi.isReconnecting() ){
			var mc = dm.attach("mcBallBlink",1);
		}

	}
	public function setColor(n){
		color = n;
		root.gotoAndStop(n+1);

	}

	function kill(){
		Game.me.phys.objs.remove(this);
		shade.removeMovieClip();
		root.removeMovieClip();

	}


//{
}














