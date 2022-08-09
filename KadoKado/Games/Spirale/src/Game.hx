import KKApi;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;

enum Step {
	Play;
	GameOver;
}

class Game {//}
	#if prod
		public static var FL_TEST = 	false;
	#else
	    public static var FL_TEST = 	true;
	#end
	public static var DP_FX = 		3;
	public static var DP_LAUNCHER = 	2;
	public static var DP_BALL = 		1;
	public static var DP_BG = 		0;
	public static var ANGLE_DECAL =		-130; // DECALLAGE DU GFX CANON

	public var flStart:Bool;
	public var step:Step;
	public var colorMax:mt.flash.Volatile<Int>;
	public var speed:mt.flash.Volatile<Float>;
	public var lastPos:mt.flash.Volatile<Float>;
	public var animCoef:Float;
	public var black:Int;
	public var chains : mt.flash.PArray<Chain>;
	public var balls : mt.flash.PArray<Ball>;
	public var shots : mt.flash.PArray<Ball>;
	public var bgrid : Array<Array<Array<Ball>>>;
	public var gfxTable : Array<Array<flash.display.BitmapData>>;
	public var launcher : { >flash.MovieClip, ball:Ball, timer:Float, shade:flash.MovieClip, turret:{>flash.MovieClip,gfx:flash.MovieClip} };
	public var mcMagnet:flash.MovieClip;
	//public var mcShade:flash.MovieClip;
	public static var me:Game;
	public var dm:mt.DepthManager;
	public var bdm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	// DEBUG
	public var markers:Array<flash.MovieClip>;

	public function new( mc : flash.MovieClip ){
		haxe.Log.setColor(0xFFFFFF);
		Cs.init();
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);
		initBg();
		initGfxTable();
		speed = Cs.SPEED_START;
		colorMax = 4;
		black = 10000000;
		//black = 10;
		step = Play;
		//
		var mcBalls = dm.empty(DP_BALL);
		bdm = new mt.DepthManager(mcBalls);
		var fl = new flash.filters.DropShadowFilter();
		fl.blurX = 4;
		fl.blurY = 4;
		fl.alpha = 0.5;
		fl.color = 0;
		fl.distance = 4;
		fl.angle = 135;
		mcBalls.filters = [fl];
		// LIST
		markers = [];
		balls = new mt.flash.PArray();
		chains = new mt.flash.PArray();
		shots = new mt.flash.PArray();
		bgrid = [];
		for( x in 0...Cs.GXMAX ){
			bgrid[x] = [];
			for( y in 0...Cs.GYMAX )bgrid[x][y] = [];
		}
		//
		mcMagnet = dm.empty(DP_FX);
		Filt.glow(mcMagnet,2,1,0xFFFFFF);
		Filt.glow(mcMagnet,20,1,0xFFFF00);
		mcMagnet.blendMode = "add";
		initLauncher();
		var c = new Chain();
		c.pos = 1.1;
		for( i in 0...Cs.START_CHAIN_LENGTH )c.addBall();
		//var c = new Chain();
		//c.pos = 0.05;
		//c.addBall();
		//
		flStart = true;
		// PARTS
		for( i in 0...120 ){
			var p = new Runner();
			p.pos = 1.3;
			p.speed = -(0.5+Math.random()*3.2)*0.005;
			p.frict = 0.99;
			p.timer = 20+Math.random()*80;
			p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
			p.setScale(40+Math.random()*60);
			Filt.glow(p.root,10,2,0xFFFFFF);
			p.fadeType = 0;
			//if(i%2==0)p.root.blendMode = "overlay";
		}
		/*
		var max = 54;
		for( i in 0...max ){
			var b = new Ball(i/max);
		}
		*/
	}

	function initGfxTable(){
		gfxTable = [];
		var mc = dm.attach("mcBallTexture",0);
		var eraser = dm.attach("mcMarble",0);
		var frames = 48;
		var length = 48;
		var m = new flash.geom.Matrix();
		m.translate(Cs.bray,Cs.bray);
		var pd = 0;
		for( i in 0...5 ){
			gfxTable[i] = [];
			mc.smc.gotoAndStop(i+1);
			for( fr in 0...frames ){
				var bmp = new flash.display.BitmapData(Cs.bray*2,Cs.bray*2,true,0);
				mc.smc._x = (fr/frames)*length - 60;
				bmp.draw(mc,m);
				gfxTable[i][fr] = bmp;
				//bmp.draw(eraser,m,null,"erase");
				/*
				var paint  = dm.empty(20);
				paint.attachBitmap(bmp,pd++);
				paint._x = (pd%12)*(Cs.bray*2);
				paint._y = Std.int(pd/12)*(Cs.bray*2);
				//*/
			}
		}
		mc.removeMovieClip();
		eraser.removeMovieClip();
	}

	public function update(){
		//haxe.Log.clear();
		//for( i in 0... 99999){	var a = 120*456;}
		animCoef = Math.min(Ball.ANIM_COEF*mt.Timer.tmod,1);
		mcMagnet.clear();
		#if prod
		#else
		cleanMarkers();
		viewGrid(bgrid);
		#end
		switch(step){
			case Play : 		updatePlay();
			case GameOver : 	updateGameOver();
		}
		updateSprites();
		if( chains.cheat || balls.cheat || shots.cheat  )KKApi.flagCheater();
	}

	// BG
	function initBg(){
		bg = dm.attach("mcBg",DP_BG);
		/*
		bg = dm.empty(DP_BG);
		//bg = dm.attach("mcBg",DP_BG);
		var bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0x336699);
		bg.attachBitmap(bmp,0);

		var mc = dm.attach("mcRigole",0);

		var run = Cs.COEF_END;
		var speed = 0.01;
		var p = Cs.getPos(run);

		while( run<1.2 ){
			run += speed;
			var np = Cs.getPos(run);
			var dx = np.x-p.x;
			var dy = np.y-p.y;
			var a = Math.atan2(dy,dx);
			var dst = Math.sqrt(dx*dx+dy*dy);

			var m = new flash.geom.Matrix();
			m.scale(dst/100,1);
			m.rotate(a);
			m.translate(p.x,p.y);

			bmp.draw(mc,m);
			p = np;
		}

		mc.removeMovieClip();

		// HOLE
		var mc = dm.attach("mcHole",0);
		var p = Cs.getPos(Cs.COEF_END);
		mc._x = p.x;
		mc._y = p.y;

		*/
		for( i in 0...10 ){
			if(i%2==1){
				var mc = dm.attach("mcLoupiotes",DP_BG);
				mc._x = i*9.5 - 1;
				mc._y = 253;
				mc.gotoAndPlay( 16- (i*2)%15);
				Reflect.setField(mc,"_fr",i==9?2:1);
				mc.blendMode = "overlay";
				//Filt.glow(mc,10,1,0xFFFFFFF);
			}
		}
	}

	// PLAY
	function updatePlay(){
		speed += Cs.SPEED_INC*mt.Timer.tmod;
		var v = speed*10000;
		if(v>4)black = 8;
		if(v>8)black = 6;
		if(v>16)black = 5;
		if(v>30)black = 4;
		//haxe.Log.clear();
		//trace(Std.int(speed*100000)*0.1 );
		updateChains();
		updateShots();
		updateLauncher();
	}
	
	function updateSprites(){
		var list = Sprite.spriteList.copy();
		for( sp in list )sp.update();
	}

	// LAUNCHER
	function initLauncher(){
		var shade =  dm.attach("launcherShade",DP_BALL-1);
		shade._x = Cs.SPX - 8;
		shade._y = Cs.SPY + 8;
		shade._alpha = 40;
		shade.blendMode = "layer";
		Filt.blur(shade,4,4);
		launcher = cast dm.attach("mcLauncher",DP_BALL-1);
		launcher._x = Cs.SPX;
		launcher._y = Cs.SPY;
		launcher.timer = 0;
		launcher.stop();
		launcher.turret = cast dm.attach("mcLauncher",DP_LAUNCHER);
		launcher.turret.gotoAndStop(2);
		launcher.turret._x = Cs.SPX;
		launcher.turret._y = Cs.SPY;
		launcher.shade = shade;
	}
	
	function updateLauncher(){
		// ROTATIONvvv
		var dx = bg._xmouse-Cs.SPX;
		var dy = bg._ymouse-Cs.SPY;
		var a = Math.atan2(dy,dx);
		launcher._rotation = a/0.0174 + ANGLE_DECAL;
		launcher.turret._rotation = launcher._rotation;
		launcher.turret.smc._alpha = 80-Math.abs(Num.hMod(a+0.77,3.14))*30;
		var dist = 8;
		launcher.ball.x = Cs.SPX+Math.cos(a)*dist;
		launcher.ball.y = Cs.SPY+Math.sin(a)*dist;
		launcher.ball.updatePos();
		launcher.ball.root.smc._rotation = launcher._rotation;
		launcher.shade._rotation = launcher._rotation;
		launcher.shade._alpha = 0;
		// BALL
		if(launcher.ball==null){
			launcher.timer -= mt.Timer.tmod;
			if( launcher.timer < 0 ){
				launcher.timer = Cs.CADENCE;
				launcher.ball = new Ball();
				launcher.ball.x = Cs.SPX;
				launcher.ball.y = Cs.SPY;
				launcher.ball.updatePos();
				bg.onPress = shoot;
				bg.useHandCursor = true;
				KKApi.registerButton(bg);
			}
		}
	}

	function shoot(){
		var bs= Cs.LAUNCH_SPEED;
		var b = launcher.ball;
		launcher.ball = null;
		shots.push(b);
		var a = (launcher._rotation- ANGLE_DECAL) * 0.0174 ;
		b.vx = Math.cos(a)*bs;
		b.vy = Math.sin(a)*bs;
		bg.onPress = null;
		bg.useHandCursor = false;
		launcher.turret.gfx.gotoAndPlay(2);
		launcher.smc.gotoAndPlay(2);
	}

	function updateShots(){
		for( b in shots )b.update();
	}

	// CHAINS
	function updateChains(){
		var lch = chains[0];
		if (lch == null){
			lch = new Chain();
			lch.pos = 1.1;
			lch.vit = speed;
		}
		lastPos = lch.pos-lch.list.length*Cs.ec;
		/*
		var lim = 1;
		if(lastPos>lim)speedMult+=(lastPos-lim)*5;
		haxe.Log.clear();
		trace(speedMult);
		*/
		var a = chains.copy();
		for( ch in a )ch.update();
		for( ch in a )if(ch.cci!=null){
			ch.checkCombo(ch.cci);
			ch.cci = null;
		}
	}

	// DANGER
	public function danger(){
		bg.smc.play();
	}

	// GAMEOVER
	public function initGameOver(){
		step = GameOver;
	}
	
	function updateGameOver(){
		if( chains == null )return;
		var chain = chains[0];
		var ball = chain.list.shift();
		ball.collapse();
		if(chain.list.length==0)chain.kill();
		if( chains.length==0 ){
			chains = null;
			KKApi.gameOver({});
		}
	}

	// DEBUG
	#if prod
	#else
	var bmpGrid:flash.display.BitmapData;
	function viewGrid(grid:Array<Array<Array<Ball>>>){
		if( !flash.Key.isDown(71) ){
			bmpGrid.dispose();
			bmpGrid = null;
			return;
		}

		if(bmpGrid==null){
			bmpGrid = new flash.display.BitmapData( Cs.GXMAX, Cs.GYMAX, false, 0 );
			var mc = dm.empty(DP_BG);
			mc.attachBitmap(bmpGrid,10);
			mc.blendMode = "add";

			mc._xscale = (Cs.mcw/Cs.GXMAX)*100;
			mc._yscale = (Cs.mch/Cs.GYMAX)*100;

		}

		for( x in 0...Cs.GXMAX ){
			for( y in 0...Cs.GYMAX ){

				var n = grid[x][y].length * 20;
				if( n >255 ) n = 255;
				var col = Col.objToCol({r:n,g:n,b:n});


				bmpGrid.setPixel(x,y,col);
			}
		}
	}
	
	function cleanMarkers(){
		while(markers.length>0)markers.pop().removeMovieClip();
	}
	
	public function mark(x,y){
		var mc = dm.attach("mcMark",20);
		mc._x = x;
		mc._y = y;
		markers.push(mc);
	}
	#end


	// EXPLOSION
	// ? CASSAGE DES BILLES A RETARDEMENT
	// TABLEAU VIDE -> SPAWN
//{
}