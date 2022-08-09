import mt.bumdum.Phys;
import mt.bumdum.Lib;
import Game;



class Ball extends Phys {//}

	public static var COLORS = [0xFF0000,0xFF9900,0xBBFF00,0x22BBFF,0xBB44FF,0xFF44EE,0x6677CC];

	public var flMove:Bool;
	public var flIce:Bool;
	public var flStar:Bool;

	public var col:mt.flash.Volatile<Int>;
	public var group:Int;

	public var tx:Float;
	public var ty:Float;
	public var csp:Float;

	public var mcShadow:flash.MovieClip;
	public var mcStar:flash.MovieClip;


	public function new( ?mc : flash.MovieClip ){
		if(mc==null)mc = Game.me.dm.attach("mcBall",Game.DP_BALLS);
		super(mc);

		csp = 0.25;
		frict = 0.4;
		group = 4;

		mcShadow = Game.me.sdm.attach("mcBallShadow",Game.DP_SHADE);
		root.cacheAsBitmap = true;

		/*
		if(Std.random(8)==0){
			flStar = true;
			mcStar = new mt.DepthManager(root).attach("mcStar",0);
			mcStar.blendMode = "add";
			mcStar._alpha = 40;
		}
		*/


	}

	public function setSkin(id){
		col = id;
		root.smc.gotoAndStop(id+1);
	}



	// UPDATE
	override public function update(){
		super.update();

		var dx = tx-x;
		var dy = ty-y;

		//var c = Math.pow(csp,1/mt.Timer.tmod);

		//frict = Math.pow(0.4,1/mt.Timer.tmod);

		vx += dx*csp;
		vy += dy*csp;

		x += dx*0.2*mt.Timer.tmod;
		y += dy*0.2*mt.Timer.tmod;

		//trace(mt.Timer.tmod);

		if(flMove){

			var dist = Math.sqrt(dx*dx+dy*dy);
			var speed = Math.sqrt(vx*vx+vy*vy);
			if( dist<10 && speed<2 ){
				flMove = false;
				if(Game.me.step == Move)Game.me.checkCombo();
			}

			if( speed > 3 ){
				Game.me.plasma.drawMc(root);
				//Game.me.plasma.drawMc(root);
			}

		}

		//root.blendMode = "add";

		/*
		x = tx;
		y = ty;
		*/


		mcShadow._x = root._x-5;
		mcShadow._y = root._y+4;

	}
	public function activate(){
		root.onPress = callback(Game.me.select,this);
		root.onRollOver = callback(Game.me.ballOver,this);
		root.onRollOut = callback(Game.me.ballOut);
		root.onDragOut = callback(Game.me.ballOut);
		root.useHandCursor = true;
		KKApi.registerButton(root);
	}
	public function deactivate(){
		root.onPress = null;
		root.onRollOver = null;
		root.onRollOut = null;
		root.onDragOut = null;
		root.useHandCursor = false;
		KKApi.registerButton(root);
	}



	// EXPLODE
	public function explode(){

		var max = 5;
		var cr = 3;
		for( n in 0...max ){
			var p = new Phys(Game.me.dm.attach("partJunk",Game.DP_PARTS));
			var a = (n+Math.random())/max * 6.28;
			var sp = Math.random()*8;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			p.frict = 0.9;
			p.x = x+ca*sp*cr;
			p.y = y+sa*sp*cr;
			p.vx = ca*sp;
			p.vy = sa*sp;
			p.timer = 10;
			//p.weight = 0.1+Math.random()*0.15;
			p.fadeType = 0;
			p.setScale(50+Math.random()*100);
			p.vr = (Math.random()*2-1)*50;
			p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
			p.root.smc.gotoAndStop(Std.random(p.root.smc._totalframes)+1);
			Col.setColor(p.root.smc,COLORS[col],-200);
		}


		// PART LIGHT
		var max = 8;
		var cr = 6;
		for( n in 0...max ){
			var p = new Phys(Game.me.dm.attach("partLight",Game.DP_PARTS));
			var a = (n+Math.random())/max * 6.28;
			var sp = 0.5+Math.random()*3;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			p.x = x+ca*sp*cr;
			p.y = y+sa*sp*cr;
			p.vx = ca*sp;
			p.vy = sa*sp;
			p.timer = 10+Math.random()*20;
			p.setScale(50+Math.random()*100);
			p.vr = (Math.random()*2-1)*20;
			p.fr = 0.98;

			var da = Math.random()*6.28;
			var dec = Math.random()*20;

			p.x -= Math.cos(da)*dec;
			p.y -= Math.sin(da)*dec;

			p.root._rotation = da/0.0174;
			p.root.smc._x = dec;
			p.fadeType = 0;
		}





		mcShadow.removeMovieClip();
		kill();
	}



//{
}



























