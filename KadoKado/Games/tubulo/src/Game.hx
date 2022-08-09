import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;

enum Step {
	Play;
	Move(sens:Int);
	Anim(sens:Int);
	GameOver;
}

typedef Tube = {>flash.MovieClip,but:flash.MovieClip,id:Int,x:Int,y:Int,obj:Game,coef:Float}


class Game {//}

	public static var FL_DEBUG = false;

	public static var DP_BG = 	0;
	public static var DP_TUBES = 	3;


	var lastMove:Float;
	var moveCoef:Float;
	var chrono:mt.flash.Volatile<Float>;
	var inMove:Int;
	var lvl:Int;

	var lvlc:mt.flash.Volatile<Int>;
	var score:KKConst;

	var par:mt.flash.Volatile<Int>;
	var moveNum:Int;

	var report:{ _t:Array<Array<Int>>, _e:Array<Int>, _r:Array<Int> };

	public var grid:Array<Array<Tube>>;
	public var tubes:Array<Tube>;
	public var moves:Array<Tube>;

	var step:Step;
	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:{>flash.MovieClip,chrono:flash.MovieClip,but:flash.MovieClip,field:flash.TextField};
	public var me:Game;

	public function new( mc : flash.MovieClip ){

		//mc._rotation = 50;
		//
		Cs.init();
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);

		bg = cast dm.attach("mcBg",DP_BG);


		report = {
			_t:[[]],
			_e:[],
			_r:[],
		}

		//
		lvl = 0;
		lvlc = 156;
		KKApi.addScore(Cs.SCORE_START);
		//

		initGrid();
		genLevel();
		//initPlay();
		initAnim(-1);

		//
		//lastMove = Date.now().getTime();

		//
		initKeyListener();

		//
		initChrono();



	}
	function initGrid(){
		grid = [];
		tubes = [];
		for( x in 0...Cs.SIDE ){
			grid[x] = [];
			for( y in 0...Cs.SIDE ){
				var mc:Tube = cast dm.attach("mcTube",DP_TUBES);
				mc._x = Cs.getX(x,y);
				mc._y = Cs.getY(x,y);
				mc.smc.gotoAndStop(1);
				mc.but._visible = false;
				mc.but.onPress = callback(clickTube,x,y);
				mc.but.onRollOver = callback(rOverTube,x,y);
				mc.but.onRollOut = callback(rOutTube,x,y);
				mc.but.onDragOut = mc.but.onRollOut;
				KKApi.registerButton(mc.but);

				mc.id = 0;
				mc.obj = this;
				grid[x][y] = mc;
				mc.x = x;
				mc.y = y;
				mc.gotoAndStop("down");
				mc.smc.smc._visible = false;
				tubes.push(mc);


			}
		}

		hideInterface();
	}

	// UPDATE
	public function update(){

		//traceReport();

		//mt.flash.Volatile();

		mt.Timer.tmod *= 0.5;

		switch(step){
			case Play :
				updateChrono();
			case Move(sens) :
				moveCoef = Math.min(moveCoef+Cs.TUBE_SPEED*mt.Timer.tmod,1);
				var frame = 10*moveCoef;
				if(sens==-1)frame = 10*(1-moveCoef);


				var flSwap = false;

				if(moveCoef==1){
					if(sens==1){
						step = Move(-1);
						flSwap = true;
						moveCoef = 0;
					}else{
						checkEnd();
					}
				}

				for( mc in moves ){
					mc.gotoAndStop(Std.int(frame+1));
					if(flSwap)mc.smc.gotoAndStop(mc.id+1);
				}

				updateChrono();
			case Anim(sens) :
				moveCoef = Math.min(moveCoef+Cs.TUBE_SPEED*mt.Timer.tmod,1);

				for( mc in tubes ){

					mc.coef = Math.min(mc.coef+Cs.TUBE_SPEED*mt.Timer.tmod,1);
					if( mc.coef>0 ){
						var frame = 10*mc.coef;
						if(sens==-1)frame = 10*(1-mc.coef);
						mc.gotoAndStop(Std.int(frame+1));
						if(mc.coef==1){
							mc.smc.gotoAndStop(mc.id+1);
							inMove--;
							mc.coef = null;
						}
					}
				}
				if(inMove==0){
					if(sens==1){
						genLevel();
						initAnim(-1);
					}else{
						moveNum = 0;
						initPlay();
					}
				}


				updateChrono();
			case GameOver :

		}


		updateSprites();
	}
	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}

	//
	function initChrono(){
		chrono = 0;
		//bg.chrono.blendMode = "add";

		//Filt.glow(bg.chrono.smc,10,1,0xFFFFFF);
		//Filt.glow(bg.chrono,4,1,0);

		var fl = new flash.filters.DropShadowFilter();
		fl.distance = 2;
		fl.color = 0x25892B;
		fl.angle = 90;
		fl.blurX = 0;
		fl.blurY = 4;
		fl.strength = 10;
		bg.chrono.filters = [fl];

		//
		mt.bumdum.Trick.makeButton(bg.but);
		var f = bg.but.onPress;
		var me = this;
		bg.but.onPress = function(){me.resetLevel();f();};
		KKApi.registerButton(bg.but);

	}
	function updateChrono(){

		chrono += mt.Timer.tmod;
		var frame = Std.int((1-chrono/Cs.CHRONO_MAX)*160)+1;
		bg.chrono.smc.gotoAndStop(frame);


		if( chrono>=Cs.CHRONO_MAX ){
			hideInterface();
			step = GameOver;
			if( lvlc/Math.pow(2,lvl) != 156 )KKApi.flagCheater();
			KKApi.gameOver(report);
		}

	}

	//
	function clickTube(x,y){

		moveNum++;

		var now = Date.now().getTime();
		var dif = Std.int(now-lastMove);
		report._t[report._t.length-1].push(dif);
		lastMove = now;


		moves = [];
		var list = Cs.DIR.copy();
		list.push([0,0]);
		for( d in list ){
			var mc = grid[x+d[0]][y+d[1]];
			if(mc!=null){
				mc.id = (mc.id+1)%Cs.COL_MAX;
				var score =Cs.SCORE_TUBE[mc.id];
				KKApi.addScore( score ) ;
				//gain = KKApi.cadd(score,gain);

			}
			moves.push(mc);
			rOutTube(x,y);

		}
		hideInterface();
		step = Move(1);
		moveCoef = 0;

	}
	function checkEnd(){

		var bid = null;
		for( mc in tubes ){
			if(bid==null)bid = mc.id;
			if(mc.id!=bid){
				initPlay();
				return;
			}
		}


		report._e.push(moveNum-par);
		report._t.push([]);
		lvl++;
		lvlc *= 2;
		KKApi.addScore(Cs.SCORE_LEVEL);
		initAnim(1);
		chrono = Math.max(chrono-Cs.CHRONO_BONUS,0);

	}
	function initPlay(){
		step = Play;
		lastMove = Date.now().getTime();
		showInterface();
	}

	//
	function rOverTube(x,y){
		var list = Cs.DIR.copy();
		list.push([0,0]);
		for( d in list ){
			var mc = grid[x+d[0]][y+d[1]];
			//Col.setPercentColor(mc,20,0xFFFFFF);
			//mc.blendMode = "add";
			//Filt.glow(mc,4,4,0);
			//Filt.glow(mc,20,1,0xFFFFFF,true);

			/*
			var fl = new flash.filters.DropShadowFilter();
			fl.blurX = 0;
			fl.blurY = 3;
			fl.strength = 10;
			fl.distance = 1;
			fl.angle = -90;
			fl.color = 0xFFFFFF;
			mc.filters = [fl];
			*/
			mc.smc.smc._visible = true;

		}


	}
	function rOutTube(x,y){

		var list = Cs.DIR.copy();
		list.push([0,0]);
		for( d in list ){
			var mc = grid[x+d[0]][y+d[1]];
			//Col.setPercentColor(mc,0,0xFFFFFF);
			//mc.blendMode = "normal";
			//mc.filters = [];
			mc.smc.smc._visible = false;
		}

	}

	//
	function initAnim(sens){
		var aid = Std.random(5);
		var sx = Std.random(2)==0;
		var sy = Std.random(2)==0;
		for( mc in tubes )setAnim(mc,aid,sx,sy);
		step = Anim(sens);
		inMove = tubes.length;
		hideInterface();
	}
	function setAnim(mc,aid,sx:Bool,sy:Bool){



		var x = mc.x;
		var y = mc.y;
		if(sx)x = Cs.SIDE-x;
		if(sy)y = Cs.SIDE-y;


		var dx = x - Cs.SIDE*0.5;
		var dy = y - Cs.SIDE*0.5;
		var dist = Math.sqrt(dx*dx+dy*dy);
		var a = Num.sMod(Math.atan2(dy,dx),6.28);



		switch(aid){
			case 0:
				mc.coef = -(x+y)*0.3;
			case 1:
				mc.coef = -(x+y*0.3)*0.5;
			case 2:
				mc.coef = -dist*0.4;
			case 3:
				mc.coef = -a*0.5;
			case 4:
				mc.coef = -(a*0.2+dist*0.2);
		}
		//if(mc.coef==0)trace("!");


	}

	//
	function genLevel(){

		// DISPLAY
		bg.field.text = "niveau "+(lvl+1);

		// GAIN
		score = KKApi.getScore();

		// CLEAN
		var baseColor = Std.random(Cs.COL_MAX);
		baseColor = 0;
		for( mc in tubes )mc.id = baseColor;

		//
		var max = Std.int(1+Math.pow(lvl,1.5));
		var mir = [[false,false]];

		var proba = lvl+2;
		if(Std.random(proba)==0)mir.push([true,false]);
		else if(Std.random(proba)==0)mir.push([false,true]);
		else if(Std.random(proba)==0)mir.push([true,true]);

		par = 0;
		while(max>0){
			var x = Std.random(Cs.SIDE);
			var y = Std.random(Cs.SIDE);
			for( dm in mir ){
				var list = Cs.DIR.copy();
				list.push([0,0]);
				for( d in list ){
					var nx = x+d[0];
					var ny = y+d[1];

					if( dm[0] ) nx = Cs.SIDE-(nx+1);
					if( dm[1] ) ny = Cs.SIDE-(ny+1);

					var mc = grid[nx][ny];
					mc.id = (mc.id+Cs.COL_MAX-1)%Cs.COL_MAX;
				}
				max--;
				par++;
			}
		}


		for( mc in tubes )mc.smc.gotoAndStop(mc.id+1);

	}
	function resetLevel(){
		if(step!=Play)return;
		report._r.push(lvl);
		KKApi.setScore( score );
		chrono = Math.min(chrono+50,Cs.CHRONO_MAX);
		initAnim(1);
	}

	// INTERFACE
	function showInterface(){
		for( mc in tubes ){
			mc.but._visible = true;
			mc.but.enabled= true;
			KKApi.registerButton(mc.but);
		}

	}
	function hideInterface(){
		for( mc in tubes ){
			mc.but._visible = false;
			mc.but.enabled = false;
			KKApi.registerButton(mc.but);
		}
	}

	// DEBUG
	function initKeyListener(){
		var kl = {};
		Reflect.setField(kl,"onKeyDown",pressKey);
		Reflect.setField(kl,"onKeyUp",releaseKey);
		flash.Key.addListener(cast kl);
	}
	function pressKey(){
		var n = {};
		if(FL_DEBUG){
			var al = 65;
			if( n == flash.Key.ENTER ){

			}
		}

	}
	function releaseKey(){
		var n = flash.Key.getCode();

	}

	function traceReport(){
		haxe.Log.clear();
		var str = "\n_e : ";
		for( n in report._e)str+=n+",";
		str +="\n_r :";
		for( n in report._r)str+=n+",";

		str +="\n_t :";
		for( a in report._t ){
			for(n in a)str+=n+",";
			str+="\n";
		}



		trace(str);
	}


//{
}




