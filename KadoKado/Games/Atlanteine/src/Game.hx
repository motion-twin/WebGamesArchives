import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;


private enum Step {
	Spawn;
	Play;
	Move;
	MoveBlock;
	Next;
	Wait;
	WaitTimer;
	GameOver;
}

typedef Map = {>flash.MovieClip, mcGround:{>flash.MovieClip,bmp:flash.display.BitmapData}, mcPlasma:{>flash.MovieClip,bmp:flash.display.BitmapData} }
typedef McBmp = {>flash.MovieClip,bmp:flash.display.BitmapData}
typedef Ppath = {>flash.MovieClip,n:Int,c:Float,speed:Float,cs:Float,dx:Float,dy:Float}

typedef DPoint = {x:Int,y:Int,d:Int};

class Game {//}

	public static var FL_DEBUG = 		false;
	public static var FL_BONUS = 		false;
	public static var FL_SIZER = 		false;
	public static var FL_GHOST = 		true;
	public static var FL_PUSH = 		true;
	public static var FL_BONUS_BLOCK = 	true;
	public static var FL_TELEPORT = 	true;

	public static var DIR = [[1,0],[0,1],[-1,0],[0,-1]];

	public static var DP_BG = 	0;
	public static var DP_LEVEL = 	1;
	public static var DP_INTER = 	2;
	public static var DP_FRONT = 	3;

	public static var DP_GROUND = 	1;
	public static var DP_ROCK = 	2;
	public static var DP_GHOST = 	3;
	public static var DP_PARTS = 	4;

	static var SCORE_TIME = 	KKApi.const(5);
	static var SCORE_BLOCK = 	KKApi.const(200);

	static var SCORE_GREEN = 	KKApi.const(200);
	static var SCORE_BLUE = 	KKApi.const(1000);
	static var SCORE_PINK = 	KKApi.const(12000);

	public static var EMPTY = 	0;
	public static var PATH = 	1;
	public static var ROCK = 	2;
	public static var MROCK = 	22;
	public static var BLOCK = 	3;
	public static var TELEPORT = 	4;
	public static var OUT = 	5;
	public static var SEA = 	6;

	public static var mcw = 300;
	public static var mch = 300;
	public static var SIZE = 20;

	static var SPEED = 0.7;//0.4;
	static var ZOOM_SPEED = 0.1;//0.05;
	static var HOLE_FADE = 30;
	static var TIME = 800;
	static var TIME_LEVEL_MALUS = 12;
	static var PROBA_PUSH = 5;
	static var SHOW_PATH_LEVEL_LIMIT = 3;


	public static var me:Game;

	var flFill:Bool;
	var flPush:Bool;
	var flControl:Bool;

	public var xmax:Int;
	public var ymax:Int;
	public var level:Int;
	public var clevel:mt.flash.Volatile<Int>;
	public var skin:Int;
	var levelTimer:mt.flash.Volatile<Float>;
	var levelTimerMax:mt.flash.Volatile<Float>;
	public var dif:mt.flash.Volatile<Float>;

	public var step:Step;

	//BALL
	var ball:Sprite;
	var mcBall:{>flash.MovieClip,shadow:flash.MovieClip,ball:flash.MovieClip};
	var x:Int;
	var y:Int;
	var lastDir:Int;
	var move:{ d:Int, coef:Float };
	var bvy:Float;
	var disDec:Float;

	var tc:Float;
	var prc:Float;
	var ballFlash:Float;


	var pushInfo:{ base:Array<Int>, free:Array<Int>, flDone:Bool };

	public var grid:Array<Array<Int>>;
	public var cache:Array<Array<Int>>;
	public var elements:Array<Array<flash.MovieClip>>;
	public var bonus:Array<Array<flash.MovieClip>>;
	public var nList:Array<DPoint>;
	public var ppList:Array<Ppath>;
	public var ghostList:Array<Ghost>;
	public var tel:Array<Array<Int>>;
	public var stones:Array<Array<Int>>;

	public var mcPushIcon:flash.MovieClip;

	public var mdm:mt.DepthManager;
	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var mcOut:flash.MovieClip;
	public var map:Map;
	public var mcDisplay:McBmp;
	public var prec:Map;
	public var mcTimer:{>flash.MovieClip,field:flash.TextField};
	public var stats:{_f:Int,_b:Array<Int>,_s:Int};



	public function new( mc : flash.MovieClip ){
		root = mc;
		me = this;
		mdm = new mt.DepthManager(root);
		bg = cast mdm.attach("mcBg",DP_BG);

		xmax = Std.int(mcw/SIZE);
		ymax = Std.int(mch/SIZE);
		//
		dif = 0;
		level = 1;

		// HACK TEST
		//level = 40;
		//dif = 100;

		clevel = 1;
		skin = 0;
		flControl = true;

		//
		initTimer();
		initMap();
		spawnBall();

		//
		displayPushIcon();


	}
	function initMap(){
		map = cast mdm.empty(DP_LEVEL);
		dm = new mt.DepthManager(map);

		ppList = null;
		var minimum = Math.min( level*0.6, 14);

		cache = null;
		while(true){
			genLevel();
			cache = [];
			for( x in 0...xmax )cache.push([]);
			var short = getShortPath(x,y,true,cache);
			if( short > minimum-- && short<999 )break;
		}
		drawLevel();
	}

	public function update(){

		/*
		haxe.Log.clear();


		for( i in 0...200000 ){
			var a = 5417/0.58;
		}
		*/

		mt.Timer.tmod *= 0.5; // HACK FOR KK2 (~double appel a mt.Timer.update)



		// SPRITE
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();

		control();

		// STEP
		switch(step){
			case Spawn:	updateSpawn();
			case Play:	updateAnims();
			case Move:	updateMove();
			case Next:	updateNextLevel();
			case WaitTimer:	updateTimer();
			case GameOver:
			case Wait:
			case MoveBlock:
		}

		if(prc!=null){
			prc--;
			prc*=0.5;
			if(prc<1)prc = 0;
			Col.setPercentColor(map,prc,0);
			if(prc<=0)prc=null;
		}
		if(ballFlash!=null){
			ballFlash *= 0.6;
			if(ballFlash<2)ballFlash = 0;
			Col.setColor(ball.root,0,Std.int(ballFlash));
			if(ballFlash<=0)ballFlash=null;
		}

		updateDisplay();



	}

	// ANIMS
	function updateAnims(){

		// PATH ANIM
		if(ppList!=null){
			if(Std.random(5)==0){
				var mc:Ppath = cast dm.attach("mcPoint",DP_GROUND);
				mc.n = nList.length-1;
				mc.c = 0;
				mc.speed = 0.1+Math.random()*0.2;
				mc.dx = (Math.random()*2-1)*SIZE*0.5;
				mc.dy = (Math.random()*2-1)*SIZE*0.5;
				mc._xscale = mc._yscale = 50+Math.random()*50;
				mc.blendMode = "add";
				ppList.push(mc);
			}

			var i = 0;
			while( i >ppList.length ){
				var mc = ppList[i];
				var p0 = nList[mc.n];
				var p1 = nList[mc.n-1];

				if(mc.cs==null)mc.cs = 1/Geom.getDist(cast p0, cast p1);
				mc.c += mc.speed*mc.cs*mt.Timer.tmod;

				while(mc.c>1){
					mc.c--;
					mc.n--;
					mc.cs = null;
					p0 = nList[mc.n];
					p1 = nList[mc.n-1];

				}

				var px = p0.x*(1-mc.c) + p1.x*mc.c;
				var py = p0.y*(1-mc.c) + p1.y*mc.c;
				mc._x = (px+0.5)*SIZE + mc.dx;
				mc._y = (py+0.5)*SIZE + mc.dy;

				mc._rotation += mc.speed*30;

				if(mc.n==0){
					mc.removeMovieClip();
					ppList.splice(i--,1);
				}
				i++;

			}


		}


		// TELEPORTS
		var m = 4;
		for( p in tel ){
			/*
			var sp = new Phys(dm.attach("partLight",DP_PARTS));
			sp.x = p[0]*SIZE + m + Math.random()*(SIZE-2*m);
			sp.y = p[1]*SIZE + m + Math.random()*(SIZE-2*m);
			sp.weight = -(0.1+Math.random()*0.2);
			sp.setScale(20+Math.random()*50);
			sp.timer = 10+Math.random()*10;
			sp.fadeType = 0;
			sp.root.blendMode = "add";
			*/
		}


	}

	// CONTROL
	function control(){


		var d =  null;
		if( flash.Key.isDown(flash.Key.RIGHT) ) d=0;
		if( flash.Key.isDown(flash.Key.DOWN) ) 	d=1;
		if( flash.Key.isDown(flash.Key.LEFT) ) 	d=2;
		if( flash.Key.isDown(flash.Key.UP) ) 	d=3;
		if( FL_DEBUG ){
			if( flash.Key.isDown(109) ) 			levelTimer=1;
			if( flash.Key.isDown(107) ) 			levelTimer=levelTimerMax-1;
			if( flash.Key.isDown(flash.Key.ENTER) ) 	displayCache(cache);
			if( flash.Key.isDown(flash.Key.CONTROL) ) 	displayNList();
			if( flash.Key.isDown(flash.Key.BACKSPACE) ) 	displayPath();
			if( flash.Key.isDown(80) ) 			ppList = [];		// P
		}

		if(!flControl && d==null)flControl = true;

		if(step!=Play)return;

		if( d!=null && (flControl || lastDir!=d) ){
			flControl = false;
			lastDir = d;
			var dir = DIR[d];
			var next = grid[x+dir[0]][y+dir[1]];
			if( !isBlock(x+dir[0],y+dir[1]) ){
				step = Move;
				move = {d:d,coef:0.0}
			}else{

				if( FL_PUSH && next==BLOCK &&pushInfo==null && isFree( x+dir[0]*2, y+dir[1]*2) ){

					pushInfo = {
						base:[x+dir[0],y+dir[1]],
						free:[x+dir[0]*2,y+dir[1]*2],
						flDone:false
					}
					grid[x+dir[0]*2][y+dir[1]*2] = BLOCK;
					grid[x+dir[0]][y+dir[1]] = EMPTY;

					step = Move;
					move = {d:d,coef:0.0};

					hidePushIcon();

				}
			}
		}

		updateTimer();
		checkGhostCol();
	}

	// BALL
	function initBall(){
		ball = new Sprite(dm.attach("mcBall",DP_ROCK));
		var last = nList[nList.length-1];
		x = last.x;
		y = last.y;

		Filt.glow( ball.root, 2, 2, 0xFFFFFF );
		Filt.glow( ball.root, 20, 1, 0xFFFF00 );

		ball.x = (x+0.5)*SIZE;
		ball.y = (y+0.5)*SIZE;
		ball.setScale( SIZE/30 *100);
		ball.root.stop();
		updateBallDepths();
	}
	function updateBallDepths(){
		dm.over(ball.root);
		for( py in y+1...ymax ){
			for( px in 0...xmax ){
				var mc = elements[px][py];
				if(mc!=null){
					dm.over(mc);
				}
			}

		}

	}
	function updateMove(){

		//var mc:{>flash.MovieClip,ball:flash.MovieClip} = cast ball.root;

		//mc.ball.gotoAndPlay(((mc.ball._currentframe+3)%mc.ball._totalframes)+1);

		var d = DIR[move.d];
		move.coef = move.coef+SPEED*mt.Timer.tmod;
		while(move.coef>=1){
			x+= d[0];
			y+= d[1];

			if(d[1]!=0)updateBallDepths();

			// CHECK ACTUAL
			var actual= grid[x][y];
			switch( actual ){
				case SEA:
					ball.root.gotoAndPlay(10);
					move.coef = 0;
					if( isFree(x,y+1) ){
						move.coef += 0.2;
						ball.y-=17;
						ball.root._y-=17;

					}
					ball.root.filters = [];
					killBall();
					break;
				case OUT:
					finishLevel();
					break;
				case TELEPORT:
					move.coef = 0;
					var p = getTeleportPos(x,y);
					x = p[0];
					y = p[1];
					var max = 16;
					var rc = 3;
					var press = 3;
					for( i in 0...max ){
						var a = i/max * 6.28;
						var ca = Math.cos(a);
						var sa = Math.sin(a);
						var speed = 1+Math.random()*4;
						var sp = new Phys(dm.attach("partTiret",DP_PARTS));
						sp.x = p[0]*SIZE + ca*speed*rc;
						sp.y = p[1]*SIZE + sa*speed*rc;
						sp.vx = ca*speed +d[0]*press;
						sp.vy = sa*speed +d[1]*press;
						sp.vr = (Math.random()*2-1)*20;
						sp.root._rotation = Math.random()*360;
						//sp.weight = -(0.1+Math.random()*0.2);
						sp.setScale(50+Math.random()*100);
						sp.timer = 10+Math.random()*10;
						sp.fadeType = 0;
						sp.root.blendMode = "add";
						sp.frict = 0.95;
					}
					ballFlash = 5000;
					Col.setColor(ball.root,0,Std.int(ballFlash));

					break;
			}
			var mc = bonus[x][y];
			if( mc!=null ){
				pickBonus(mc);
				mc.removeMovieClip();
				bonus[x][y] = null;
			}

			// CHECK NEXT
			if( isBlock(x+d[0],y+d[1]) ){
				move.coef = 0;
				step = Play;
				break;
			}else{
				move.coef -= 1;
			}




		}
		ball.x = (x+0.5+move.coef*d[0])*SIZE;
		ball.y = (y+0.5+move.coef*d[1])*SIZE;

		//
		if( pushInfo.flDone==false ){
			var c = move.coef;
			if( c==0 )c=1;

			pushBlocks(c);
			if(c==1){
				pushInfo.flDone = true;
				updateBallDepths();
			}

		}


		//
		updateTimer();
		checkGhostCol();
		updateAnims();

	}

	// ACTION
	function checkGhostCol(){
		for( g in ghostList ){
			var dist = ball.getDist(g);
			if( dist < 10 ){
				g.explode();
				killBall();
				ball.kill();
				levelTimer=Math.max(levelTimer-100,0);
				break;
			}
		}
	}
	function getTeleportPos(px,py){
		for( p in tel ){
			if( p[0]!=px || p[1]!=py ){
				return p;
			}
		}
		trace("getTeleport ERROR");
		return null;
	}
	function killBall(){
		step = WaitTimer;
		haxe.Timer.delay(spawnBall,500);
	}

	// ROCK
	function pushBlocks(c:Float){
		var mc = elements[pushInfo.base[0]][pushInfo.base[1]];
		var x = pushInfo.base[0]*(1-c) + pushInfo.free[0]*c;
		var y = pushInfo.base[1]*(1-c) + pushInfo.free[1]*c;
		mc._x = x*SIZE;
		mc._y = y*SIZE;
	}
	function displayPushIcon(){
		if(!FL_PUSH)return;
		/*
		mcPushIcon = mdm.attach("mcPush",DP_INTER);
		mcPushIcon._y = mch;
		*/
		//Filt.glow(mcPushIcon,2,6,0);
		for( a in elements )for( mc in a ){
			if( mc._currentframe == BLOCK+11 ){
				mc.smc.gotoAndStop(1);
			}
		}

	}
	function hidePushIcon(){
		if(!FL_PUSH)return;
		//mcPushIcon.removeMovieClip();
		for( a in elements )for( mc in a ){
			if( mc._currentframe == BLOCK+11 ){
				mc.smc.gotoAndStop(2);
			}
		}
	}

	// SPAWN
	function spawnBall(){
		initBall();
		step = Spawn;
		bvy = 0;
		mcBall = cast ball.root;
		mcBall.ball.smc._y = -80;
		tc = 0;

		flFill = levelTimer==null;

		if(flFill){
			levelTimerMax = TIME-level*TIME_LEVEL_MALUS;
			levelTimer = 1;
			flFill = true;
		}

	}
	function updateSpawn(){

		var flNext = false;

		// BALL FALL
		bvy += 2*mt.Timer.tmod;
		mcBall.ball.smc._y += bvy*mt.Timer.tmod;
		var lim = 0;
		if( mcBall.ball.smc._y > lim ){
			mcBall.ball.smc._y = lim;
			if(bvy>4*mt.Timer.tmod){
				bvy *= -0.4;
			}else{
				if(pushInfo==null){
					flNext = true;
				}
			}
		}
		mcBall.shadow._alpha = 100+mcBall.ball.smc._y*2;

		// SPAWN COEF
		tc = Math.min(tc+0.1*mt.Timer.tmod,1);
		if( pushInfo!=null ){
			pushBlocks(1-tc);
			if(tc==1){
				grid[pushInfo.base[0]][pushInfo.base[1]] = BLOCK;
				grid[pushInfo.free[0]][pushInfo.free[1]] = EMPTY;
				pushInfo = null;
				displayPushIcon();
			}
		}

		//
		if(flFill && levelTimer<levelTimerMax ){
			var timerMod = mt.Timer.tmod; // old method
			var timerMod = (mt.Timer.wantedFPS * mt.Timer.deltaT); // use real time
			levelTimer = Math.min(levelTimer+40*timerMod, levelTimerMax);
			updateTimerGfx();
			if( levelTimer==levelTimerMax ){

				var max = 12;
				for( i in 0...max ){
					var p = new Phys(mdm.attach("partCloud",DP_INTER));
					var a = i/max*6.28;
					var ray = 18;
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var sp = 0.5+Math.random()*1.5;
					p.x = mcw-20 + ca*ray;
					p.y = mch-20 + sa*ray;
					//p.weight = -(0.1+Math.random()*0.3);
					p.vx = ca*sp;
					p.vy = sa*sp;
					p.timer = 10+Math.random()*10;
					p.fadeType = 0;
					p.frict = 0.9;
					p.root.blendMode = "add";
					p.setScale(200);
					p.updatePos();
					p.vr = (Math.random()*2-1)*30;
					p.root._rotation = Math.random()*360;
				}
				flFill = false;
			}
		}

		if( !flFill && flNext )step = Play;

	}

	// NEXTLEVEL
	function finishLevel(){
		while(ppList.length>0){
			var mc:flash.MovieClip = ppList.pop();
			var p = new Phys(mc);
			p.timer = 10+Math.random()*5;
			p.updatePos();

		}

		ball.root.gotoAndPlay("go");
		move.coef = 0;
		step = Wait;
		haxe.Timer.delay(nextLevel,700);
		mcOut.smc.gotoAndPlay(2);

		// BONUS CAISSE
		if( FL_BONUS_BLOCK && pushInfo==null ){
			for( a in elements )for(mc in a){
				if( mc._currentframe == 11+BLOCK ){

					var max = 6;

					//SCORE
					KKApi.addScore(SCORE_BLOCK);
					var p = new Phys(dm.attach("mcScore",DP_PARTS));
					p.x = mc._x+SIZE*0.5;
					p.y = mc._y+SIZE*0.5;
					p.vy = -5;
					p.frict = 0.7;
					p.timer = 20;
					//p.root.gotoAndStop(Std.random(p.root._totalframes)+1);
					var mcf:{>flash.MovieClip, field:flash.TextField} = cast p.root;
					mcf.field.text  = Std.string(KKApi.val(SCORE_BLOCK));
					Filt.glow(p.root,2,2,0);
					var mcScore = p.root;

					// PARTS
					for( i in 0...max ){
						var p = new Phys(dm.attach("partBlock",DP_PARTS));
						p.x = mc._x+SIZE*0.5;
						p.y = mc._y+SIZE*0.5;
						p.vx = (Math.random()*2-1)*2;
						p.vy = -(1+Math.random()*2);
						p.weight = 0.1+Math.random()*0.1;
						p.fadeType = 0;
						p.timer = 10+Math.random()*10;
						p.vr = (Math.random()*2-1)*20;
						p.root._rotation = Math.random()*360;
						Filt.glow(p.root,3,2,0);
						if(i==max*0.5)dm.over(mcScore);
					}

					//
					mc.removeMovieClip();

				}
			}
		}


	}
	function nextLevel(){

		//
		level++;
		clevel++;
		dif = Math.min(100,dif+10);


		if(FL_SIZER && level>16 ){
			SIZE = Std.int(Math.max(SIZE-1,12));
			xmax = Std.int(mcw/SIZE);
			ymax = Std.int(mch/SIZE);
		}


		//
		for( a in elements )for( mc in a ){
			var m = new flash.geom.Matrix();
			m.scale(mc._xscale/100,mc._yscale/100);
			m.translate(mc._x,mc._y);
			map.mcGround.bmp.draw(mc,m);
			//
			mc.removeMovieClip();
		}

		prec = map;
		tc = 0;

		//*	// ZOOM
		map.mcGround._x = -ball.x;
		map.mcGround._y = -ball.y;
		map._x = ball.x;//mcw*0.5;
		map._y = ball.y;//mch*0.5;





		/*/	// PASSE
		prec.cacheAsBitmap = true;
		//*/



		while( ghostList.length>0 )ghostList.pop().kill();


		initMap();
		Col.setPercentColor(map,HOLE_FADE,0);
		mdm.over(prec);
		//map._y = mch;
		step = Next;




	}
	function updateNextLevel(){


		tc = Math.min(tc+ZOOM_SPEED*mt.Timer.tmod,1);


		//*	// ZOOM
		prec._xscale = 100+Math.pow(tc,3)*3500;
		prec._yscale = prec._xscale;

		var zc  = Math.pow(tc,0.5);
		map._xscale = zc*100;
		map._yscale = zc*100;
		map._x = (mcw*(1-zc))*0.5;
		map._y = (mcw*(1-zc))*0.5;


		/*
		var dx = mcw*0.5 - prec._x;
		var dy = mch*0.5 - prec._y;
		prec._x += dx*0.1;
		prec._y += dy*0.1;
		*/

		//map._x = Math.max(0, prec._x );
		//map._y = Math.min(0, prec._y );


		/*/	// PASSE
		prec._y += (prec._y-2);
		if(prec._y<-mch){
			prec.removeMovieClip();
			prec = null;
		}

		if(prec._y<-mch*0.5 || prec == null ){
			map._y *= 0.8;
		}
		//*/

		// TIMER
		if(levelTimer!=null){
			var timerMod = mt.Timer.tmod; // old method
			var timerMod = (mt.Timer.wantedFPS * mt.Timer.deltaT);
			var n = Math.min(levelTimer,34*timerMod);
			levelTimer-=n;
			KKApi.addScore(KKApi.cmult( KKApi.const(Std.int(n)),SCORE_TIME));
			updateTimerGfx();

			// PARTS
			var p = new Phys(mdm.attach("partCloud",DP_INTER));
			var c = levelTimer/levelTimerMax;
			var a = c*6.28-1.57;
			var ray = 16;
			p.x = mcw-20 + Math.cos(a)*ray;
			p.y = mch-20 + Math.sin(a)*ray;
			p.weight = -(0.1+Math.random()*0.3);
			p.vx = (Math.random()*2-1)*0.5;
			p.timer = 10+Math.random()*10;
			p.fadeType = 0;
			p.root.blendMode = "add";
			p.setScale(150);
			p.updatePos();

			//
			if(levelTimer <= 0){
				levelTimer = null;
				mcTimer.field.text = Std.string(level);
			}

		}

		//
		if( tc == 1 ){
			if(prec._visible){
				prc = HOLE_FADE;
				prec.mcGround.bmp.dispose();
				prec.mcPlasma.bmp.dispose();
				prec.removeMovieClip();

				if(pushInfo!=null){
					pushInfo = null;
					displayPushIcon();
				}
			}
			if(levelTimer == null){
				spawnBall();
			}

		}


	}

	// GEN LEVEL
	function genLevel(){

		// GRILLE
		grid = new Array();
		stones = new Array();
		for( x in 0...xmax ){
			grid[x] = new Array();
			for( y in 0...ymax ){
				grid[x][y] = if(x==0 || x==xmax-1 || y==0 || y==ymax-1)SEA; else EMPTY;
			}
		}

		// TELEPORT

		if(FL_TELEPORT && level>=10){
			tel = [];
			for( i in 0...2 ){
				var p = null;
				do{
					p = getRandomPos([EMPTY],3);
				}while( i==1 && ( p.x == tel[0][0] || p.y == tel[0][1]) );

				grid[p.x][p.y] = TELEPORT;
				tel.push([p.x,p.y]);
				for( d in DIR ){
					grid[p.x+d[0]][p.y+d[1]] = PATH;
				}
			}
		}



		{	// SORTIE + GENERATION
			var p = getRandomPos([EMPTY,PATH],4);
			grid[p.x][p.y] = OUT;

			nList = [{x:p.x,y:p.y,d:Std.random(4)}];
			flPush = FL_PUSH && level>2;
			getRange();

			var last = nList[nList.length-1];
			x = last.x;
			y = last.y;
		}
		// CREATE THE BLOCK
		//createTheBlock();

		for( x in 0...xmax ){
			for( y in 0...ymax ){
				if(grid[x][y]==MROCK)grid[x][y]=ROCK;
			}
		}



		// PARASITES


		var bList = new Array();
			var max = null;
			// FALSE PATH

			for( i in 0...6 ){
				var m = 4;
				var x = m+Std.random(xmax-2*m);
				var y = m+Std.random(ymax-2*m);
				var d = DIR[Std.random(4)];
				while(true){
					x += d[0];
					y += d[1];
					var sq = grid[x][y];
					if(sq == EMPTY ){
						grid[x][y] = PATH;
					}
					if(sq == SEA )break;
				}
			}

			// LINE
			var max = Std.int(Math.min( dif*0.2, 8 ));
			for( i in 0...max ){
				var m = 4;
				var x = m+Std.random(xmax-2*m);
				var y = m+Std.random(ymax-2*m);
				var d = DIR[Std.random(4)];
				while(true){
					x += d[0];
					y += d[1];
					var sq = grid[x][y];
					if(sq == EMPTY ){
						grid[x][y] = ROCK;
						bList.push({x:x,y:y});
					}
					if(sq == SEA )break;
				}
			}

			// HOLE
			bList = shuffle2(bList);
			for(i in 0...max ){
				var p = bList.pop();
				grid[p.x][p.y] = EMPTY;
			}

			// ALONE
			var max = Math.floor(dif*0.1);
			for( i in 0...max ){
				var m = 1;
				var x = m+Std.random(xmax-2*m);
				var y = m+Std.random(ymax-2*m);
				if(grid[x][y]==EMPTY)grid[x][y] = ROCK;
			}

			// WATER
			var px = 1;
			var py = 1;
			var flSwitch = true;
			for( d in DIR ){

				for( x in 0...xmax-3 ){
					if(Std.random(6)==0)flSwitch = !flSwitch;
					if(flSwitch){
						if(grid[px][py]==EMPTY){
							grid[px][py] = SEA;
						}else{
							flSwitch  = false;
						}
					}
					px += d[0];
					py += d[1];
				}
			}

			// TRANSMUTE ROCK -> BLOCK
			var falseBlockCoef = Math.min((level/20),0.9);
			for( x in 0...xmax ){
				for( y in 0...xmax ){
					if(grid[x][y]==ROCK && Math.random()<falseBlockCoef ){

						if( (isFree(x-1,y) && isFree(x+1,y)) || (isFree(x,y-1) && isFree(x,y+1)) ){
							grid[x][y]= BLOCK;
						}



					}
				}
			}

			// HOLE ROCKERS
			var sx = nList[0].x;
			var sy = nList[0].y;

			for( d in DIR ){
				var dist = 0;
				while(true){
					dist++;
					var nx = sx+d[0]*dist;
					var ny = sy+d[1]*dist;
					var c = grid[nx][ny];
					if( c == EMPTY && Std.random(3)==0){
						grid[nx][ny] = ROCK;
						break;
					}
					if( c == SEA )break;
				}
			}


			/*
			var max = Math.floor(dif*0.1);
			for( i in 0...max ){
				var m = 1;
				var x = m+Std.random(xmax-2*m);
				var y = m+Std.random(ymax-2*m);
				if(grid[x][y]==EMPTY)grid[x][y] = SEA;
			}
			*/


	}
	function getRange():Bool{
		var limit = 4+Std.int(dif*0.12);
		if( nList.length >= limit ){
			return true;
		}
		var last = nList[nList.length-1];
		var d = DIR[last.d];

		// Fait la liste des distances accessibles
		var dList = new Array();

		var n = 0;
		var nx = last.x;
		var ny = last.y;

		while(true){
			n++;
			nx += d[0];
			ny += d[1];
			var sq = grid[nx][ny];
			if(sq==TELEPORT){
				var p = getTeleportPos(nx,ny);
				//trace("tel "+nx+";"+ny+" to "+p+" at"+n);
				nx = p[0];
				ny = p[1];
			}

			if( sq == EMPTY ){
				dList.push(n);
			}else{
				if( sq != PATH && sq != TELEPORT )break;
			}
		}

		// Melange de la liste des distances accessibles
		dList = shuffle(dList);


		// Parcours les distances accessibles
		while(dList.length>0){

			// Récupère une distance
			var dist = dList.pop();
			//trace("dist :"+dist);

			// Calcule le x et le y de la case d'arrivée
			//var nx = last.x + dist*d[0];
			//var ny = last.y + dist*d[1];
			var nx = null;
			var ny = null;

			// Peint le chemin
			var px = last.x;
			var py = last.y;
			var cleanList = [];
			for( i in 0...dist ){
				px += d[0];
				py += d[1];

				if( grid[px][py] == TELEPORT ){
					var p = getTeleportPos(px,py);
					px = p[0];
					py = p[1];
				}else{
					if(grid[px][py]==EMPTY)cleanList.push([px,py]);
					grid[px][py] = PATH;
				}

				nx = px;
				ny = py;

			}

			// Choisis une direction au hasard parmis les deux disponibles
			var dir = new Array();
			dir.push( (last.d+1)%4 );
			dir.push( (last.d+3)%4 );
			dir = shuffle(dir);
			var cacheStones = stones.copy();

			while(dir.length>0){
				// index de la direction a verifier;
				var nd = dir.pop();
				// essaie de placer un block dans la direction opposé
				var od = (nd+2)%4;
				var bx = nx+DIR[od][0];
				var by = ny+DIR[od][1];
				var sq = grid[bx][by];
				if( sq == EMPTY || sq == ROCK || sq == MROCK ){ // CORRECTION 1

					// Pose le block
					if( grid[bx][by] == MROCK ){
						grid[bx][by] = ROCK;
					}else{
						grid[bx][by] = MROCK;
					}

					//addStone(bx,by,nx,ny);

					// Ajoute a la liste
					var o = {x:nx,y:ny,d:nd}
					nList.push(o);

					// verifie le prochain path
					if(getRange()){

						// créé un block si l'action est dispo

						if(flPush && grid[bx][by] == MROCK ){
							var flAdd  = true;
							for( i in 0...3 ){
								if( nList[nList.length-(1+i)] == o ){
									flAdd = false;
									break;
								}
							}

							if( flAdd && Std.random(PROBA_PUSH)==0  ){
								flPush = false;
								var d = DIR[nd];
								grid[bx+d[0]][by+d[1]]=BLOCK;
								grid[bx][by]=PATH;
							}
						}


						return true;
					}

					// nettoie la liste
					nList.pop();

					// Enleve le block
					grid[bx][by] = sq;

				}


			}

			// ECHEC !!
			stones = cacheStones;


			// Nettoie le chemin
			/*
			var px = last.x;
			var py = last.y;
			for( i in 0...dist ){
				px += d[0];
				py += d[1];

				if( grid[px][py] == TELEPORT ){
					var p = getTeleportPos(px,py);
					px = p[0];
					py = p[1];
				}else{
					grid[px][py] = EMPTY;
				}


			}
			*/
			for( p in cleanList )grid[p[0]][p[1]] = EMPTY;

		}

		// ECHEC
		return false;

	}
	function drawLevel(){

		// ELEMENTS
		elements = [];
		for( i in 0...xmax )elements[i] = [];

		// GROUND
		map.mcGround = cast dm.empty(DP_GROUND);
		map.mcGround.bmp = new flash.display.BitmapData(mcw,mcw,true,0x00000000);
		map.mcGround.attachBitmap(map.mcGround.bmp,1);
		var mcg = dm.attach("mcSquare",DP_GROUND);

		Col.setPercentColor(map.mcGround,Std.random(20),0xff9900);

		for( y in 0...ymax ){
			for( x in 0...xmax ){
				var type = grid[x][y];

				switch(type){
					case ROCK:
						var mc = dm.attach("mcSquare",DP_ROCK);
						mc._x = x*SIZE;
					 	mc._y = y*SIZE;
						mc.gotoAndStop(type+skin*20+11);
						mc._xscale = mc._yscale = SIZE/30 * 100;
						mc.smc.gotoAndStop(1);
						mc.smc.smc.gotoAndStop(Std.random(mc.smc.smc._totalframes)+1);
						Col.setPercentColor(mc,Std.random(20),0xff9900);
						elements[x][y] = mc;
					case BLOCK:
						var mc = dm.attach("mcSquare",DP_ROCK);
						mc._x = x*SIZE;
					 	mc._y = y*SIZE;
						mc.gotoAndStop(type+skin*20+11);
						mc._xscale = mc._yscale = SIZE/30 * 100;
						mc.smc.gotoAndStop(1);
						Col.setPercentColor(mc,Std.random(20),0xff9900);
						//mc.smc.smc.gotoAndStop(Std.random(mc.smc.smc._totalframes)+1);
						elements[x][y] = mc;
					case TELEPORT:
						var mc = dm.attach("mcSquare",DP_ROCK);
						mc._x = x*SIZE;
					 	mc._y = y*SIZE;
						mc.gotoAndStop(type+skin*20+11);
						mc._xscale = mc._yscale = SIZE/30 * 100;
						//mc.smc.gotoAndStop(1);
						//mc.smc.smc.gotoAndStop(Std.random(mc.smc.smc._totalframes)+1);
						elements[x][y] = mc;
					case OUT:
						//var mc = new mt.DepthManager(map.mcGround).attach("mcSquare",DP_GROUND);
						var mc = map.mcGround.attachMovie("mcSquare","mcOut",0);
						mc._x = x*SIZE;
						mc._y = y*SIZE;
						mc.gotoAndStop(type+skin*20+11);
						mc._xscale = mc._yscale = SIZE/30 * 100;
						map.mcGround.bmp.fillRect(new flash.geom.Rectangle(x*SIZE,y*SIZE-2,SIZE,SIZE+2),0x00000000);
						mc.smc.stop();
						mcOut = mc;
						dm.over(map.mcGround);

				}

				var groundFrame = 1;
				for( i in 0...DIR.length ){
					var d = DIR[i];
					if( grid[x+d[0]][y+d[1]] != SEA ) groundFrame += Std.int(Math.pow(2,i));
				}

				mcg.gotoAndStop(type+1+skin*20);
				mcg.smc.gotoAndStop(groundFrame);
				mcg.smc.smc.gotoAndStop(Std.random(mcg.smc.smc._totalframes)+1);
				mcg.smc.smc.smc.gotoAndStop(Std.random(mcg.smc.smc.smc._totalframes)+1);

	 			var m = new flash.geom.Matrix();
				m.scale(SIZE/30,SIZE/30);
				m.translate(x*SIZE,y*SIZE);
				map.mcGround.bmp.draw(mcg,m);

			}
		}

		mcg.removeMovieClip();

		// BONUS
		if( FL_BONUS ){

		var max = Std.int(Math.min(3+level*0.5,16));
		bonus = [];
		for( x in 0...xmax )bonus.push([]);
		for( i in 0...max ){
			var x = null;
			var y = null;
			var m = 1;
			do{
				x = m+Std.random(xmax-m*2);
				y = m+Std.random(ymax-m*2);
			}while( !isFree(x,y) || bonus[x][y]!=null );

			var mc = dm.attach("mcBonus",DP_ROCK);
			mc._x = x*SIZE;
			mc._y = y*SIZE;
			mc._xscale = mc._yscale = SIZE/30 * 100;
			mc.gotoAndStop(getBonusId());
			bonus[x][y] = mc;



		}

		}

		// GHOST
		if(FL_GHOST){
			var max = Std.int(Math.min( Math.pow((level-10),0.5), 5 ));
			ghostList = [];
			for( i in 0...max ){
				var g = new Ghost(dm.attach("mcGhost",DP_GHOST));
			}
		}

		// START DALLE
		var p = nList[nList.length-1];
		var mc = dm.attach("mcStartDalle",DP_GROUND);
		mc._x = p.x*SIZE;
		mc._y = p.y*SIZE;
		mc._xscale = mc._yscale = SIZE/30 * 100;
		elements[p.x][p.y] = mc;

	}

	function getShortPath(x,y,flPush,?cache,?ng){
		if(cache==null){
			cache = [];
			for( x in 0...xmax )cache.push([]);
		}
		var ch = cache[x][y];
		if(  ch != null )return ch;

		// TRAITEMENT DE LA CASE EN COURT;
		cache[x][y] = 999;

		var result = 999;
		for( d in DIR ){
			var nx = x;
			var ny = y;
			while(true){
				nx+= d[0];
				ny+= d[1];
				var next = grid[nx][ny];
				if(next==TELEPORT){
					var p = getTeleportPos(nx,ny);
					nx = p[0];
					ny = p[1];
				}

				if(ng[nx][ny]!=null) next = ng[nx][ny];

				switch(next){
					case OUT:
						result = 1;
						break;
					case ROCK:
						result = Std.int(Math.min( 1+getShortPath( nx-d[0], ny-d[1], flPush, cache ), result ));
						break;
					case BLOCK:
						result = Std.int(Math.min( 1+getShortPath( nx-d[0], ny-d[1], flPush, cache ), result ));
						if(flPush ){
							var beyond = grid[nx+d[0]][ny+d[1]];
							if( beyond == EMPTY || beyond == PATH ){
								var ng = [];
								for( x in 0...xmax )ng.push([]);
								ng[nx][ny] = EMPTY;
								ng[nx+d[0]][ny+d[1]] = BLOCK;


								result = Std.int(Math.min( 1+getShortPath( nx, ny, false, cache, ng ), result ));
							}
						}
					case SEA:
						result =  Std.int(Math.min( 999, result ));
						break;
				}
			}
		}

		cache[x][y] = result;
		return result;
	}

	// BONUS
	function getBonusId(){
		var proba = [
			100,	// bonus vert
			10,	// bonus bleu
			1	// bonus rose
		];
		var sum = 0;
		for( n in proba )sum+=n;
		var rnd = Std.random(sum);
		sum = 0;
		for( i in 0...proba.length ){
			sum+=proba[i];
			if(sum>=rnd){
				return (i+1);
			}
		}
		return null;
	}
	function pickBonus(mc:flash.MovieClip){
		switch(mc._currentframe){
			case 1: KKApi.addScore(SCORE_GREEN);
			case 2: KKApi.addScore(SCORE_BLUE);
			case 3: KKApi.addScore(SCORE_PINK);
		}
		ballFlash = 255;
		Col.setColor(ball.root,0,Std.int(ballFlash));

		for( i in 0...3 ){
			var p = dm.attach("partWarp",DP_PARTS);
			p._x = mc._x+SIZE*0.5 + (Math.random()*2-1)*6;
			p._y = mc._y+SIZE*0.5 + (Math.random()*2-1)*6;
			p._xscale = p._yscale = 20;
			p._rotation = Math.random()*360;
			p.gotoAndPlay(Std.random(6)+1);
		}


	}

	// TIMER
	function initTimer(){
		mcTimer = cast mdm.attach("mcTimer",DP_INTER);
		mcTimer._x = mcw;
		mcTimer._y = mch;
		mcTimer.stop();
		mcTimer.field.text = Std.string(level);

		//Filt.glow(mcTimer,2,2,0);
		Filt.glow(mcTimer,10,1,0xFFFFFF);

	}
	function updateTimer(){
		if( mcTimer == null )return;
		if( mcTimer._x > mcw ){
			var dx = mcw-mcTimer._x;
			if(Math.abs(dx)<1)dx = 0;
			mcTimer._x += dx*0.5;
		}

		//ztrace(mcTimer._x);
		//trace(mcTimer._currentframe);

		// levelTimer -= mt.Timer.tmod; // old method
		levelTimer -= mt.Timer.deltaT * mt.Timer.wantedFPS;
		updateTimerGfx();

		if(levelTimer<=0){
			if(level>SHOW_PATH_LEVEL_LIMIT ){
				if(clevel!=level)KKApi.flagCheater();
				KKApi.gameOver(stats);
				step = GameOver;
			}else{
				if(ppList==null)ppList=[];
				/*
				var last = null;
				for( p in nList ){


					if(last!=null){
						var mc = dm.attach("mcLine",DP_GROUND);
						mc._xscale = Geom.getDist(p,last)*SIZE;
						mc._rotation = Geom.getAng(last,p)/0.0174;
						mc._x = (p.x+0.5)*SIZE;
						mc._y = (p.y+0.5)*SIZE;
					}
					var mc = dm.attach("mcPoint",DP_GROUND);
					mc._x = (p.x+0.5)*SIZE;
					mc._y = (p.y+0.5)*SIZE;

					last = p;
				}
 				*/

			}
		}

	}
	function updateTimerGfx(){
		mcTimer.smc.gotoAndStop( 1+Std.int((levelTimer/levelTimerMax)*160) );
	}

	// DISPLAY
	function updateDisplay(){
		return;
		if(disDec==null)disDec =0;
		disDec = (disDec+20)%628;
		var c =  Math.cos(disDec*0.01);

		if(mcDisplay==null){
			mcDisplay = cast mdm.empty(DP_FRONT);
			mcDisplay.bmp = new flash.display.BitmapData(mcw*2,mch,false,0xFF0000);
			mcDisplay.attachBitmap(mcDisplay.bmp,0);
			mcDisplay._x = 0;
		}

		//CLEAN
		mcDisplay.bmp.fillRect(mcDisplay.bmp.rectangle,0xFF0000);

		// COPY MAPv
		var m = new flash.geom.Matrix();
		m.translate(mcw,0);
		mcDisplay.bmp.draw(map,m);

		// DISPLACEMENT
		var mc  = mdm.attach("mcDisplacement",0);
		var dbmp = new flash.display.BitmapData(mcw,mch,false,0x000000);
		dbmp.draw(mc,new flash.geom.Matrix());
		mc.removeMovieClip();

		var fl = new flash.filters.DisplacementMapFilter();
		fl.componentX = 2;
		fl.componentY = 1;
		var sc = 160;
		fl.scaleX = mcw*2 + 4;
		fl.scaleY = sc+c*sc;
		fl.mapPoint = new flash.geom.Point(0.0,0.0);
		fl.mapBitmap = dbmp;
		fl.mode = "clamp";

		mcDisplay.bmp.applyFilter(mcDisplay.bmp,new flash.geom.Rectangle(0,0,mcw,mch),new flash.geom.Point(0,0),fl);



		//mcDisplay.bmp.draw(dbmp);

		/*
		var fl = new flash.filters.BlurFilter();
		fl.blurX = 8;
		fl.blurY = 8;
		mcDisplay.bmp.applyFilter(mcDisplay.bmp,mcDisplay.bmp.rectangle,new flash.geom.Point(0,0),fl);
		*/
	}

	//
	static public function isFree(x,y){
		var next = Game.me.grid[x][y];
		return next == PATH || next == EMPTY;
	}
	static public function isBlock(x,y){
		var next = Game.me.grid[x][y];
		return next == BLOCK || next == ROCK;
	}
	public function getRandomPos(a:Array<Int>,?m){
		if(m==null)m=2;
		var to=0;
		while(true){
			var x = m+Std.random(xmax-2*m);
			var y = m+Std.random(ymax-2*m);
			for( type in a ){
				if( grid[x][y] == type )return {x:x,y:y};
			}
			if(to++>200){
				trace("PIOOOOOOOOOOU ! getRandomPos ERROR");
				return null;
			}
		}
		return null;
	}

	function shuffle(list:Array<Int>):Array<Int>{
		var pos = [];
		for( n in 0...list.length )pos.push(n);
		var a = [];
		while(pos.length>0){
			var index = Std.random(pos.length);
			var n = pos[index];
			pos.splice(index,1);
			a.push(list[n]);
		}
		return a;
	}
	function shuffle2(list:Array<{x:Int,y:Int}>):Array<{x:Int,y:Int}>{
		var pos = [];
		for( n in 0...list.length )pos.push(n);
		var a = [];
		while(pos.length>0){
			var index = Std.random(pos.length);
			var n = pos[index];
			pos.splice(index,1);
			a.push(list[n]);
		}
		return a;
	}

	// DEBUG

	function displayCache(cache){
		mdm.clear(DP_FRONT);
		for( x in 0...xmax ){
			for( y in 0...ymax ){
				var type = cache[x][y];
				if(type==999)type=0;
				if(type!=null){
					var mc:{>flash.MovieClip, field:flash.TextField } = cast mdm.attach("mcDebugField",DP_FRONT);
					mc._x = x*SIZE;
					mc._y = y*SIZE;
					mc.field.text = Std.string(type);
					mc._xscale = mc._yscale = SIZE/30 * 100;
				}
			}
		}
	}
	function displayNList(){
			mdm.clear(DP_FRONT);
		var n = 0;
		for(p in nList){
			n++;
			var x = p.x;
			var y = p.y;
			var mc:{>flash.MovieClip, field:flash.TextField } = cast mdm.attach("mcDebugField",DP_FRONT);
			mc._x = x*SIZE;
			mc._y = y*SIZE;
			mc.field.text = Std.string(n);
			mc._xscale = mc._yscale = SIZE/30 * 100;
		}
	}
	function displayPath(){
		mdm.clear(DP_FRONT);
		for( x in 0...xmax ){
			for( y in 0...ymax ){
				var type = grid[x][y];
				if(type==PATH){
					var mc:{>flash.MovieClip, field:flash.TextField } = cast mdm.attach("mcDebugField",DP_FRONT);
					mc._x = x*SIZE;
					mc._y = y*SIZE;
					mc.field.text = "0";
					mc._xscale = mc._yscale = SIZE/30 * 100;
				}
			}
		}

	}


	// FANTOME COINCE
	// PENCHE DISPLACE

	/*

	function addStone(x,y,nx,ny){
		for( st in stones ){
			if( st[0]==x && st[1]==y ){
				st[2]++;
				return;
			}
		}
		stones.push([x,y,0,nx,ny]);
	}

	function createTheBlock(){
		haxe.Log.clear();
		trace("stones.length : "+stones.length);
		stones.pop();
		var list = stones.copy();
		for( st in list )if(st[2]>0){
			stones.remove(st);
			trace("happen!!");
		}
		if(stones.length==0){
			trace("no more stones!");
			return;
		}
		var p = stones[Std.random(stones.length)];

		grid[p[0]][p[1]] = PATH;
		var d = DIR[p[3]];
		grid[p[3]][p[4]] = BLOCK;
		trace("create BLOCK at "+(p[3])+";"+(p[4]) );
		trace("create PATH at "+(p[0])+";"+(p[1]) );
	}
	*/

//{
}













