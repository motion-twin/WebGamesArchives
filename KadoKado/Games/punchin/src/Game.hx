import Common;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Part;
import mt.bumdum.Plasma;
import flash.Key;

enum Step{
	Intro;
	Play;
	GameOver;
}

class Game {//}
	var step:Step;
	public static var boxer:Boxer;
	public static var afro:Afro;
	var zC:Float;
	var isMoovin:Bool;
	var goSta:Bool;
	var flBonus:Bool;
	var flCol:Bool;


	var zFinishx:Float;
	var zStartx:Float;
	var staInc:mt.flash.Volatile<Float>;

	var time :Date;
	var sTime: mt.flash.Volatile<Float>;

	public static var DP_BG = 0;
	public static var DP_AFRO = 1;
	public static var DP_PLAYER = 2;
	public static var DP_GUI = 6;
	public static var DP_MSG = 10;

	static var BONUSVERT	= 200000;
	static var BONUSBLEU	= 360000;
	static var BONUSROUGE	= 470000;

	static var BONUSMAX		= 500000;
	static var BONUS		=  20000;
	var bonusCool : mt.flash.Volatile<Float>;
	var endBonus : mt.flash.Volatile<Float>;
	var fall : mt.flash.Volatile<Float>;

	public static var me:Game;
	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var st:{>flash.MovieClip, mask:flash.MovieClip, power:flash.MovieClip   };
	public var p:flash.MovieClip;

	public var stats:{_p:Array<Int>,_t:Array<Int>,_g:Array<Int>};

	var mcChrono : {>flash.MovieClip, label:flash.TextField};
	var message : {>flash.MovieClip, sub:{>flash.MovieClip, label:flash.TextField}};
	var msgTimer : Float;
	var flMsg : Bool;

	var currentCol : Int;


	public function new( mc : flash.MovieClip ){
		step = Intro;
		me = this;
		stats = {_p:[],_t:[],_g:[0,0,0]};
		root = mc;
		dm = new mt.DepthManager(root);
		msgTimer = 0;
		flMsg = false;
		goSta = false;
		bonusCool = 120;
		sTime = flash.Lib.getTimer();
		flBonus = false;
		flash.Lib._global.bonusCol = 1;
		//flash.Lib._global.trace = trace;
		//trace("oOo");
		initPlay();
	}

	public function initPlay(){
		initBg();
		initPlayer();
		initGui();
	}

	function initBg(){
		bg = dm.attach("mcBg",DP_BG);
		bg._x = Cs.w/2 +40;
		bg._y = Cs.h;
	}

	function initPlayer(){
		boxer = new Boxer(dm.attach("mcPlayer",DP_PLAYER));
		afro = new Afro(dm.attach("mcAfro",DP_AFRO));
	}

	function initGui(){
		staInc = 0.1;
		st = cast dm.attach("mcStamina",DP_GUI);
		st._x = Cs.w/2 + 88;
		st._y = Cs.h - 12;
		st.mask._xscale = 100;

		mcChrono = cast dm.attach("mcChrono",DP_GUI);
		mcChrono._x = 150;
		mcChrono._y =  19;
	}


	function initBonus(){
		var bonus = Math.random()*500000;
		//
		//
		//
		if ( bonus > BONUSROUGE){
			currentCol = 0xFF6600;
			flash.Lib._global.bonusCol = 4;
			//trace("bonus rouge "+flash.Lib._global.bonusCol);

		}else if ( bonus > BONUSBLEU){
			currentCol = 0x02CBFD;

			flash.Lib._global.bonusCol = 3;

			//trace("bonus bleu "+flash.Lib._global.bonusCol);

		}else if ( bonus > BONUSVERT){
			currentCol = 0xB3FD02;

			flash.Lib._global.bonusCol = 2;

			//trace("bonus vert "+flash.Lib._global.bonusCol);
		}
		flBonus = true;
		flCol = true;
		endBonus = 100;
		bonusCool = 200;

	}


	//_________________________________________________________________________ UPDATE
	public function update(){

		mt.Timer.tmod *= 0.5; // HACK FOR KK2 ~= double mt.Timer.update() call

		if (flBonus){
			if (endBonus>0){
				endBonus-= mt.Timer.tmod;
				if (flCol){
					Col.setPercentColor(boxer.root,70,currentCol);
					flCol = false;
				}else{
					Col.setPercentColor(boxer.root,40,currentCol);
					flCol = true;
				}


			}else{
				flash.Lib._global.bonusCol = 1;
				flBonus = false;
			}
		}


		if (flash.Lib._global.bonusCol == 1){
			Col.setPercentColor(boxer.root,00,0x02CBFD);
		}

		if ( bonusCool > 0){
			bonusCool -= mt.Timer.tmod;
		}else if ((BONUS/BONUSMAX) > Math.random()){
			initBonus();
		}

		updateSprites();

		switch (step){
			case Intro :
				step = Play;
			case Play :
				if (isMoovin) bgAnim();
				incStamina();
				if (flMsg){
					if (msgTimer > 0) {msgTimer -= mt.Timer.tmod;}
					else { endMsg(); }
				}
				updateTime();
			case GameOver:
				fall += 2;
				boxer.y += fall;

		}
	}

	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}

	function updateTime(){

		var newTime = flash.Lib.getTimer();

		var cTime = 120000 - (newTime-sTime);
		var dTime = getChronoTimer(cTime);

		if (cTime>0){
			mcChrono.label.text = dTime;
		}else{
			initGameOver();
		}
	}


	//_________________________________________________________________________  PLAY

	public function incStamina(){
		if (st.mask._xscale >= 100) {
			if (!flMsg) staMax();
		}else{st.mask._xscale += staInc;}
	}

	public function decStamina(val:Int){
		if (st.mask._xscale < 100) {
			if (st.power._currentframe!=1) {st.power.gotoAndStop(1);}
		}
		if (st.mask._xscale > 0) {
			st.mask._xscale -= val;
		}

		if (st.mask._xscale <= 0){
			//step = GameOver;
			goSta = true;
			initGameOver();
			//trace("finish him");
		}
	}

	public function staMax(){
		st.power.gotoAndStop(2);
	}

	public function newMsg(msg:String,time:Float){
		message = cast dm.attach("mcText",DP_MSG);
		message._x = Cs.w;
		message._y = 30;
		message.sub.label.text = msg;
		msgTimer = time;
		flMsg = true;
	}

	function endMsg(){
		message.gotoAndPlay("end");
		flMsg = false;
	}

	 function initBgAnim(goal:Float){
		isMoovin = true;
		zStartx=bg._x;
		zFinishx=goal;
	 }

	public function moveBg(direction:String){
		switch (direction){
			case "right":
				if (-bg._x+Cs.w+20  < bg._width/2 )	initBgAnim(bg._x-5);
			case "center":

			case "left":
				if (bg._x  < bg._width/2) initBgAnim(bg._x+5);
		}
	}

	function bgAnim(){
		if (bg._x == zFinishx){
			isMoovin = false;
		}else if (bg._x > zFinishx) {
			bg._x--;
		}else if (bg._x < zFinishx) {
			bg._x++;
		}
	}

     function getChronoTimer(t:Float){
          var ms = t;
          var s = Std.int(ms/1000);
          var min = Std.int(s/60);

          var smin = Std.string(min);
          while(smin.length<2)smin = "0"+smin;
          var ss = Std.string(s-min*60);
          while(ss.length<2)ss = "0"+ss;
          var sms = Std.string(ms%1000);
          while(sms.length<3)sms = "0"+sms;

          return smin+":"+ss;

     }

	public function isPlaying(){
		return Game.me.step != GameOver;
	}

	//_________________________________________________________________________  GAMEOVER
	public function initGameOver(){
		step = GameOver;
		KKApi.gameOver(stats);
		fall = 0;
	}

	function updateGameOver(){

	}
//{

}





