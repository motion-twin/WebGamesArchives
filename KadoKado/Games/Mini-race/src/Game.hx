import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;
import mt.bumdum.Bmp;
import mt.bumdum.Bmp;

enum Step {
	Play;
	GameOver;
}

typedef CheckPoint = {a:Float,x:Float,y:Float}

class Game {//}

	public static var FL_DEBUG = false;

	public static var DP_BG = 	0;
	public static var DP_MAP = 	1;
	public static var DP_INTER = 	3;

	public static var DP_GROUND = 		1;
	public static var DP_CAR = 		2;
	public static var DP_PARTS = 		3;
	public static var DP_SKY_PARTS 	= 	4;
	public static var DP_SCORE = 		5;


	public static var SC = 2;

	public static var me:Game;

	public var flPerfect:Bool;
	public var blink:Float;

	public var timer: 	mt.flash.Volatile<Float>;
	public var chronoTimer: mt.flash.Volatile<Float>;

	public var flPress:Bool;
	public var lap: mt.flash.Volatile<Int>;
	public var fastLimit: mt.flash.Volatile<Int>;
	public var furiousLimit: mt.flash.Volatile<Int>;
	public var step:Step;
	public var checkpoints:	Array<CheckPoint>;
	public var sbList:	Array<String>;
	public var cars:	Array<Car>;


	public var map:{>flash.MovieClip,race:flash.MovieClip,bg:flash.MovieClip,paint:flash.MovieClip,bmp:Bmp};
	public var mcInter:{>flash.MovieClip,
		bar:flash.MovieClip,
		ga:flash.MovieClip,
		chrono:{>flash.MovieClip,field0:flash.TextField,field1:flash.TextField,dm:mt.DepthManager}

		};
	public var flagList:Array<flash.MovieClip>;
	var mcShowBonus:{>flash.MovieClip, msg:{>flash.MovieClip,field:flash.TextField}};

	public var dm:mt.DepthManager;
	public var mdm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var stats:{_ot:Array<Array<Int>>};

	public function new( mc : flash.MovieClip ){
		//haxe.Log.setColor(0xFFFFFF);
		me = this;
		root = mc;
		Cs.init();

		lap = 0;
		stats = {_ot:[]};

		dm = new mt.DepthManager(root);

		bg = dm.attach("mcBg",DP_BG);
		initKeyListener();
		initMouseListener();
		initInterface();

		initMap();
		fastLimit = 400;
		furiousLimit = 360;

		initCars();
		initPlay();

		/*
		var mc = dm.empty(4);
		mc.lineStyle(1,0xFF0000,50);
		for( cp in checkpoints ){
			var dx = Math.cos(cp.a)*16;
			var dy = Math.sin(cp.a)*16;
			mc.moveTo(cp.x-dx,cp.y-dy);
			mc.lineTo(cp.x+dx,cp.y+dy);
		}
		*/

	}

	// CARS
	public function initCars(){
		cars = [];
		for( i in 0...4 ){
		var car = new Car(mdm.attach("mcCar",DP_CAR));
			car.setPlayer(i);
			//car.x = Cs.mcw*0.5;
			//car.y = Cs.mch*0.5;

		}

		/*
		for( i in 0...20 ){
			var p = new Luciole(mdm.attach("mcLuciole",DP_CAR));
			p.goto(0);
		}
		*/

	}

	// UPDATE
	public function update(){
		//haxe.Log.clear();

		switch(step){
			case Play:	updatePlay();
			case GameOver:	updateGameOver();
		}


		updateInterface();
		updateSprites();
		checkCols();
		updateScroll();
	}
	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}

	// MAP
	public function initMap(?id){
		if(id==null)id=0;
		map = cast dm.attach("mcMap",DP_MAP);
		map._xscale = SC*100;
		map._yscale = SC*100;
		map.gotoAndStop(id+1);
		map.race.gotoAndStop(id+1);
		mdm = new mt.DepthManager(map);

		var mc = mdm.empty(DP_GROUND);
		mc._alpha = 50;
		//Filt.glow(mc,6,1,0x0066FF);
		map.bmp = new Bmp(mc,Cs.mcw,Cs.mch,true,0x00000000,2);

		var mc = dm.attach("mcPaint",0);
		mc.gotoAndStop(id+1);
		//map.paint._xscale = map.paint._yscale = 200;
		//map.paint._visible = false;
		map.bmp.draw(mc);

	}
	function updateScroll(){
		var car = cars[0];
		if(car.pid!=0)return;

		map._x = Num.mm(-(Cs.mcw*SC-Cs.mcw),Cs.mcw*0.5-car.x*SC,0);
		map._y = Num.mm(-(Cs.mch*SC-Cs.mch),Cs.mch*0.5-car.y*SC,0);
	}

	// PLAY
	function initPlay(){
		timer =  0;
		step = Play;
	}
	function updatePlay(){
		chronoTimer += mt.Timer.tmod;
		updateChrono();

	}
	public function incLap(){
		//showBonus("NOUVEAU TOUR!");

		Col.setPercentColor(root,0,0xFF0000);

		if(lap>0)addTime(chronoTimer);
		lap++;
		flPerfect = true;
		chronoTimer = 0;

		flagList.pop().removeMovieClip();
		for( c in cars ){
			if(c.pid>0){
				c.acc*=Cs.LAP_MALUS;
				c.turnLimit*=Cs.LAP_MALUS;
			}
		}

		if(lap>Cs.TURN_MAX){
			initGameOver(0);
		}
	}
	function checkCols(){
		for( i in 0...cars.length ){
			var c = cars[i];
			for( n in i+1...cars.length ){
				var c2 = cars[n];
				c.checkColPhys(c2);
			}
		}
	}

	// GAME OVER
	public function initGameOver(n){


		step = GameOver;
		timer = n;
	}
	public function updateGameOver(){
		if(timer!=null){
			timer -= mt.Timer.tmod;
			if(timer<0){
				KKApi.gameOver(stats);
				timer = null;
			}
		}
	}

	// INTERFACE
	function initInterface(){
		mcInter = cast dm.attach("mcInter",DP_INTER);
		mcInter._x = Cs.mcw;
		mcInter._y = Cs.mch;

		// CHRONO
		mcInter.chrono.dm = new mt.DepthManager(mcInter.chrono);

		// FLAGS
		flagList = [];
		var dm = new mt.DepthManager(mcInter);
		for( n in 0...Cs.TURN_MAX ){
			var mc = dm.attach("mcFlag",0);
			mc._x = -(54 + n*14);
			mc._y = -10;
			flagList.push(mc);
		}

	}
	public function updateLife(n:Float){
		mcInter.bar._yscale =n/Cs.LIFE_MAX *100;
	}
	public function updateInterface(){

		// GACHETTE
		if(flPress){
			mcInter.ga._y += (-42-mcInter.ga._y)*0.1;
		}else{
			mcInter.ga._y = Math.max( mcInter.ga._y-5, -60 );
		}

		if(sbList.length>0 && mcShowBonus._visible!=true){
			mcShowBonus = cast dm.attach("mcShowBonus",DP_INTER);
			mcShowBonus.msg.field.text = sbList.shift();
			mcShowBonus.blendMode = "add";
		}

	}
	public function showBonus(str){
		if(sbList==null)sbList = [];
		sbList.push(str);
	}

	// CHRONO
	public function updateChrono(){
		var ch = getChrono(chronoTimer);
		mcInter.chrono.field1.text = getDigit(ch.mil,3);
		mcInter.chrono.field0.text = getDigit(ch.sec,2);

		var lim = 25;
		if( ch.sec > lim-1 ){
			Col.setPercentColor(root,0,0xFF0000);
			initGameOver(0);
		}else if( ch.sec > lim-3 ){
			if(blink==null)blink = 0;
			blink = ( blink + 73*mt.Timer.tmod )%628;
			Col.setPercentColor(root,Math.cos(blink*0.01)*10,0xFF0000);
		}

	}
	public function getChrono(n:Float){
		var t = Std.int(n*25);
		var mil = t%1000;
		var sec = Std.int(t/1000);
		return {mil:mil,sec:sec};
	}
	public function getDigit(n,max){
		var str = Std.string(n);
		while(str.length<max)str  ="0"+str;
		return str;
	}
	function addTime(n:Float){

		var ch = getChrono(n);
		var a = [ch.sec,ch.mil];

		if(n<furiousLimit){
			showBonus("TOUR DE FURIEUX!");
			KKApi.addScore(Cs.SCORE_FURIOUS);
			a.push(1);
		}else if(n<fastLimit){
			showBonus("TOUR RAPIDE!");
			KKApi.addScore(Cs.SCORE_FAST);
			a.push(2);
		};

		stats._ot.push( a );




		var mc:{>flash.MovieClip, field:flash.TextField} = cast mcInter.chrono.dm.attach("mcTime",0);
		mc._x = 83;
		mc._y = lap*11 - 13;
		mc.field.text = getDigit(ch.sec,2)+"'"+getDigit(ch.mil,3);

		if(flPerfect){
			showBonus("TOUR PARFAIT!");
			KKApi.addScore(Cs.SCORE_PERFECT);

			var mcs = mcInter.chrono.dm.attach("mcStar",0);
			mcs._x = 38;
			mcs._y = mc._y + 9.5;
		}

	}

	// TOOLS
	public function getX(x:Float){
		return x*SC + map._x;
	}
	public function getY(y:Float){
		return y*SC + map._y;
	}

	// LISTENERS
	function initMouseListener(){
		var ml = Reflect.empty();
		Reflect.setField(ml,"onMouseDown",mouseDown);
		Reflect.setField(ml,"onMouseUp",mouseUp);
		flash.Mouse.addListener(cast ml);
	}
	function mouseDown(){
		flPress = true;
	}
	function mouseUp(){
		flPress = false;
	}

	function initKeyListener(){
		var kl = Reflect.empty();
		Reflect.setField(kl,"onKeyDown",pressKey);
		Reflect.setField(kl,"onKeyUp",releaseKey);
		flash.Key.addListener(cast kl);
	}
	function pressKey(){
		var n = flash.Key.getCode();
		if( n==flash.Key.SPACE )mouseDown();

		if(FL_DEBUG){

		}

	}
	function releaseKey(){
		var n = flash.Key.getCode();
		if( flPress )mouseUp();
	}


//{
}

// COL
// REVOIR LES LUCIOLES






