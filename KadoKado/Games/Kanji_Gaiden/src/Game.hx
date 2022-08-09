import mt.bumdum.Lib;

typedef Point = {x:Int,y:Int};

class Game {
	
	public static var DP_BONUS = 17;
	public static var DP_WARN = 16;
	public static var DP_SC = 15;
	
	public static var DP_HERO = 14;
	
	public static var DP_FG = 13;
	public static var DP_DEATH = 12;
	public static var DP_SHOOT = 11;
	public static var DP_PL1 = 10;
	public static var DP_BB1 = 9;
	public static var DP_PL2 = 8;
	public static var DP_BB2 = 7;
	public static var DP_PL3 = 6;
	public static var DP_BB3 = 5;
	public static var DP_PL4 = 4;
	public static var DP_BB4 = 3;
	public static var DP_BG = 1;
	
	public static var me	: Game;
	public var dm			: mt.DepthManager;
	public var root			: flash.MovieClip;
	public var bg			: flash.MovieClip;
	public var warn_l		: flash.MovieClip;
	public var warn_r		: flash.MovieClip;
	public var hero			: Kanji;

	var fg  : Plan;
	
	public var plans 	: Array<Plan>;	
	public var shoots	: Array<Shot>;
	public var monkeys	: Array<Monkey>;
	public var bonus	: Array<Bonus>;
	
	public var pos : Float;
	var monkeyMin : Int;
	var diffCool : Float;
	public var diff : Int;
	
	var dead : Bool;
	var warnl: Bool;
	var warnr : Bool;
	
	public var mcScore : {>flash.MovieClip, mct : {>flash.MovieClip, _field : flash.TextField}};
	
	public function new( mc : flash.MovieClip ){
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces();
		
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);

		diffCool = Cs.DIFFBASE;
		monkeyMin = 4;
		diff = 0;
		pos = 0.5;
		
		hero = new Kanji();
		
		shoots = [];
		monkeys = [];
		bonus = [];
		
		initPlan();
		warnr = false;
		warnl = false;
		dead = false;
		
		warn_l = dm.attach("warning",DP_WARN);
		warn_r = dm.attach("warning",DP_WARN);
		warn_l._x = warn_l._width*0.5 +5;
		warn_l._y = warn_l._height*0.5 +5;
		
		warn_r._xscale = -100;
		warn_r._x = Cs.mcw - warn_r._width*0.5 -5 ;
		warn_r._y = warn_r._height*0.5 +5;
		warn_l._visible = false;
		warn_r._visible = false;
	}
	
	public function getPos(dev:Float) : Point{
		var ret :Point;
		var width = Math.ceil((300+600*(1-dev)));
		var px = Math.floor(pos*(width-300));
		var py = Math.floor(Cs.pdf*dev);
		ret = { x: px, y:py };
		return ret;
	}
	
	public function getPosShot(dev:Float,hint:Float) : Point{
		var ret :Point;
		var width = Math.ceil((300+600*(1-dev)));
		var px = Math.floor( hint*(width-300) - pos*(width-300)  +Cs.mcw*0.5 )  ;
		var py = Math.floor(Cs.pdf*dev);
		ret = { x: px, y:py };
		return ret;
	}
	
	function checkWarn(){
		warnr = false;
		warnl = false;
		for(m in monkeys ){
			if ((m.pl == 0) ){
				if (m.mcMonkey._x < (plans[0].width * pos) -200 ) warnl = true;
				if (m.mcMonkey._x > (plans[0].width * pos) +200) warnr = true;
			}
		}
	}	
	
	function updateBg(){
		var pos = getPos(0);
		bg._x = -pos.x +bg._width*0.5;	
	}
	
	function addMonkeyDebug(){

		plans[2].addMonkey();
	}
	
	public function addAMonkey(pl:Int){
		if (pl >= 0) {
			plans[pl].addMonkey();
		}else{
			if (!dead){
			dead = true;
			KKApi.gameOver({});
			var monkeyDeath = dm.attach("monkey",DP_DEATH);
			monkeyDeath.smc.gotoAndPlay("_land");
			
			monkeyDeath._x  = 150;
			monkeyDeath._y  = 270;
			}
		}
	}
	
	public function addAMonkeySpecial(pl:Int ,mtype:Int ,life:Int ,diff:Int, btype:Int){
		if (pl >= 0) {
			plans[pl].addMonkeyTyped(mtype,life,diff,btype);
			
		}else{
			if (!dead){
			dead = true;
			KKApi.gameOver({});
			var monkeyDeath = dm.attach("monkey",DP_DEATH);
			monkeyDeath.gotoAndStop(diff);
			
			if (mtype !=4) monkeyDeath.smc.smc.gotoAndStop(mtype+1);
			else monkeyDeath.smc.smc.gotoAndStop(5+btype);
			
			monkeyDeath.smc.gotoAndPlay("_land");
			
			monkeyDeath._x  = 150;
			monkeyDeath._y  = 270;
			}
		}
	}
	

	function initPlan(){
		plans = [] ;
		//var mcPlan1 = dm.empty(DP_PL1);
		//var Plan1 = new Plan(mcPlan1,0,0.75,1);
		//plans.push(Plan1);
		
		var mcfg = dm.attach("fg",DP_FG);
		fg = new Plan(mcfg,0,0.75,1);
		
		
		var mcBamboo1 = dm.empty(DP_BB1);
		var Bamboo1 = new Plan(mcBamboo1,0,0.5,0);
		plans.push(Bamboo1);
		
		var mcBamboo2 = dm.empty(DP_BB2);
		var Bamboo2 = new Plan(mcBamboo2,1,0.25,0);
		plans.push(Bamboo2);
		Col.setPercentColor(mcBamboo2,25,0xD4FBA2);
		
		var mcBamboo3 = dm.empty(DP_BB3);
		var Bamboo3 = new Plan(mcBamboo3,2,0.125,0);
		plans.push(Bamboo3);
		Col.setPercentColor(mcBamboo3,50,0xD4FBA2);
		
		bg = dm.attach("mcBg",DP_BG);
		var bgPlan = new Plan(bg,3,0,1);
		
		plans.push(bgPlan);

		addMonkeyDebug();
		
		//plans[0].addMonkey();
	}
	
	
	public function  update(){ 
		hero.update();
		if (!dead){
			if( flash.Key.isDown(flash.Key.RIGHT) )	move(0);
			else if( flash.Key.isDown(flash.Key.LEFT) )	move(1);
			
			//if( flash.Key.isDown(flash.Key.UP) ) trace("[ FPS ] : "+mt.Timer.fps()) ;
			
			if( flash.Key.isDown(flash.Key.SPACE) ) hero.shoot();	
		}
		for(pl in plans ) pl.update();
		for( s in shoots ) s.update();
		for( m in monkeys ) m.update();
		for( b in bonus ) b.update();
		fg.update();
		if (monkeys.length < monkeyMin ) addMonkeyDebug();

		incDifficulty();
		checkWarn();
		
		if (warnr) warn_r._visible = true;
		else warn_r._visible = false;
		if (warnl) warn_l._visible = true;
		else warn_l._visible = false;
		}
	
		
	public function move(dir:Int){
		hero.move(dir);
	}
	
	public function scoreIt(sc){
		mcScore = cast dm.attach("score",DP_SC);
		mcScore.mct._field.text = ""+KKApi.val(sc);
		mcScore._x = 300;
		mcScore._y = 300;
		KKApi.addScore(sc) ;
	}
	
	function incDifficulty(){
		if 	( diffCool < 0 ) {
			diff++;
			monkeyMin++;
			//trace(" Diff "+diff+"  monkey min:"+monkeyMin);
			diffCool =  Cs.DIFFBASE + Std.random(Cs.DIFFBASE);
				
		} else { diffCool -= mt.Timer.tmod; }
	}
	
	
	public function bonusMe(bt:Int) {

		if ( bonus.length == 0){
			var b = new Bonus(bt);
			bonus.push(b);
		}else {
			bonus[0].destroy();
			var b = new Bonus(bt);
			bonus.push(b);
		}

		

		
	}
	
}







