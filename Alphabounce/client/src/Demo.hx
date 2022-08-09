import mt.bumdum.Lib;
import mt.bumdum.Phys;


class Demo{//}

	static var DP_INTER = 1;
	static var DP_GAME = 0;

	var root:flash.MovieClip;
	var dm:mt.DepthManager;
	var game:Game;
	static public var me:Demo;


	public var timer:Float;

	public function new(mc){
		Cs.DEMO = true;

		root = mc;
		dm = new mt.DepthManager(root);
		me = this;
		initPlayerInfo();
		initGame();


		var mc = dm.attach("mcModeDemo",DP_INTER);
		mc._y = Cs.mch;
		//

	}


	public function update(){
		game.update();
		game.updateAuto();
		var b = game.getLowestBall();
		if( b!=null ){

			game.pad.moveFactor = b.y/Cs.mch;
		}


		timer -= mt.Timer.tmod;
		if(timer<10 && game.mcFlash==null){
			game.setFlash(0,0.1);
		}
		if( timer <= 0 ){
			game.kill();
			initGame();
		}

	}


	function initPlayerInfo(){
		Cs.pi = new PlayerInfo();
		Cs.pi.setToDefault();
		Cs.pi.items[MissionInfo.BALL_DRILL] = 2;


	}
	function initGame(){


		// PLAYERINFO
		Cs.pi.missile = Cs.pi.missile = Std.random(10);
		 Cs.pi.items[MissionInfo.MISSILE_BLUE] = if( Std.random(2) == 0 ) null; else 2;

		//
		Game.PLAY_AUTO = true;
		game = new Game(dm.empty(DP_GAME), 0x220053);

		//

		var zid = null;
		var ray = 1+Math.random()*30;
		var a = Math.random()*6.28;
		var x = Std.int(Math.cos(a)*ray);
		var y = Std.int(Math.sin(a)*ray);

		if(Std.random(2)==0){
			zid = [1,2,4,5,6][Std.random(5)];
			var list = ZoneInfo.getSquares(zid);
			var p = list[Std.random(list.length)];
			x = p[0];
			y = p[1];
		}



		game.initLevel( x,y, zid, true );
		game.initPlay();


		// BALL PLACER
		for( b in game.balls )b.kill();
		var max = 1;
		if(Std.random(2)==0)max += Std.random(6);

		var speed = 4+Math.random()*6;
		for( i in 0...max ){
			var b = Game.me.newBall();
			var x = 30+Math.random()*(Cs.mcw-60);
			var y = Cs.getY(game.level.ymax+0.5+Std.random(Cs.YMAX-game.level.ymax));
			b.moveTo(x,y);
			b.setSpeed(speed);
			b.setAngle(Math.random()*6.28);
			b.update();
		}

		// PAD POSITION
		game.pad.y = game.pad.ty;
		game.pad.x = Math.random()*Cs.mcw;

		// START BONUS
		var sb = [2,4,5,6,9,10,11,12,13,14,16,17,18,19,21,22];
		var max = Std.random(3);
		for( i in 0...max ){
			game.getOption(sb[Std.random(sb.length)]);
		}


		// TIMER
		timer = 120+Math.random()*200;
		game.setFlash(1,-0.05);


	}







//{
}















































