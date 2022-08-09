package navi.menu;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;

import navi.menu.asteroid.Ship;
import navi.menu.asteroid.Rock;
import navi.menu.asteroid.Shot;
import navi.menu.asteroid.Option;


enum GStep {
	Intro;
	Play;
	End;
}


class Asteroid extends navi.Menu{//}

	static var DP_SHIP = 0;

	var timer:Float;
	var gstep:GStep;

	var bg:flash.MovieClip;
	var bmpBg:flash.display.BitmapData;

	public var rocks:Array<Rock>;
	public var shots:Array<Shot>;
	public var options:Array<Option>;

	var game:flash.MovieClip;
	public var gdm:mt.DepthManager;
	public var ship:Ship;

	static public var me:Asteroid;

	override function init(){
		super.init();
		me = this;

		bg = dm.empty(0);
		bmpBg = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0x004400 );
		bg.attachBitmap(bmpBg,0);

		var col = 0x005500;
		var sq = 8;
		var xmax = Std.int(Cs.mcw/sq);
		var ymax = Std.int(Cs.mch/sq);
		for( x in 0...xmax ) bmpBg.fillRect( new flash.geom.Rectangle( x*sq, 0, 1, Cs.mch ), col );
		for( y in 0...ymax ) bmpBg.fillRect( new flash.geom.Rectangle( 0, y*sq, Cs.mcw, 1 ), col );


		game = dm.empty(0);
		gdm = new mt.DepthManager(game);
		Filt.glow(game,10,1,0xFFFFFF);

		game.blendMode = "add";

		shots = [];
		rocks = [];
		options = [];

		ship = new Ship(gdm.attach("astShip",DP_SHIP));
		//

		gstep = Intro;
		timer = 0;



	}

	function initLevel(){
		for( i in 0...3 ){
			var rock = newRock();
			rock.setRay(50);
			rock.setSpeed(3);
			rock.initPos();

		}
	}
	public function newRock(){
		return new Rock( gdm.attach("astRock",DP_SHIP) );
	}
	public function newOpt(x,y){
		var opt = new Option(gdm.attach("astOpt",1));
		opt.x = x;
		opt.y = y;
	}


	// UPDATE
	override public function update(){
		super.update();

		if(timer!=null)timer += mt.Timer.tmod;

		switch(gstep){
			case Intro:
				var lim = 30;
				var c = Math.pow(timer/lim,0.5);
				ship.x = c*(Cs.mcw*0.5+ship.ray) - ship.ray;
				ship.fxThrust();
				if(timer>lim){
					gstep = Play;
					initLevel();
				}
			case Play:	ship.control();
			case End:
				if( timer > 50 ){
					gstep = null;
					quit();
				}

		}


		var list = Sprite.spriteList.copy();
		for( sp in list )sp.update();


	}

	public function initGameOver(){
		timer = 0;
		gstep = End;
	}

	//
	override function kill(){
		bmpBg.dispose();
		super.kill();
	}



//{
}








