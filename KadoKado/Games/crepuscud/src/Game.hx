import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Part;
import mt.bumdum.Lib;
import mt.bumdum.Plasma;

enum Step {
	Play;
	GameOver;
}

typedef GROUP = {id:Int};
typedef McField = {>flash.MovieClip,field:flash.TextField};


class Game {//}


	//public static var FL_DEBUG = true;

	public static var GH = 	20;
	public static var RGH = 14;
	public static var GY = 	0;
	public static var RGY =	0;
	public static var DX = 	22;

	public static var DP_BG = 	0;
	public static var DP_PLASMA = 	1;
	public static var DP_ONDE = 	2;
	public static var DP_MISSILE = 	3;
	public static var DP_PARTS = 	6;
	public static var DP_GROUND = 	7;
	public static var DP_INTER = 	8;
	public static var DP_SCORE = 	9;

	public var flGameOver:Bool;

	public var expl:Int;
	public var fade:Float;

	public var dif:mt.flash.Volatile<Float>;
	public var angle:Float;
	public var totalSpeed:mt.flash.Volatile<Float>;
	public var replenish:mt.flash.Volatile<Float>;

	public var cmun:mt.flash.Volatile<Int>;
	public var munitions:Array<flash.MovieClip>;
	public var muniCount : mt.flash.Volatile<Float>;
	public var brushQueueMissile:flash.MovieClip;

	public var hero:{>flash.MovieClip,gun:flash.MovieClip};
	//public var mcTarget:flash.MovieClip;
	public var missiles:Array<Missile>;
	public var patriots:Array<Patriot>;
	public var holes:Array<Float>;

	public var mcExplode:flash.MovieClip;

	public var bmpGround:flash.display.BitmapData;

	public var step:Step;
	public var plasma:Plasma;
	public var dm:mt.DepthManager;
	public var edm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	static public var me:Game;


	public function new( mc : flash.MovieClip ){

		haxe.Log.setColor(0xFFFFFF);

		root = mc;
		me = this;
		dm = new mt.DepthManager(root);

		initBg();

		GY = Cs.mch-GH;
		RGY = Cs.mch-RGH;

		flGameOver = false;
		dif = 1;
		totalSpeed = 0;
		replenish = 0;
		expl = 0;

		missiles = [];
		patriots = [];
		munitions = [];
		muniCount = 0;
		cmun = 0;
		incMunition(12);

		initPlasma();
		initDecor();

		initPlay();

	}

	function initBg(){
		bg = dm.empty(DP_BG);
		var bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0);
		bg.attachBitmap(bmp,0);

		// FOND
		var mc = dm.attach("mcBg",0);
		bmp.draw(mc);
		mc.removeMovieClip();


		// STARS
		var mc = dm.attach("mcStar",0);
		for( i in 0...100 ){
			var m = new flash.geom.Matrix();
			var py = Math.pow(Math.random(),3)*100 - 5;
			var sc = 0.2+Math.random()*0.8;
			m.scale( sc,sc );
			m.translate( Math.random()*Cs.mcw , py );

			bmp.draw(mc,m,null,"add");

		}







		bg.onPress = launchMissile;
		bg.useHandCursor = false;
		KKApi.registerButton(bg);
		//bg.cacheAsBitmap = true;
	}
	function initDecor(){

		// BRUSHES
		brushQueueMissile = dm.attach("queueMissile",DP_GROUND);
		brushQueueMissile._visible = false;

		// GROUND
		bmpGround = new flash.display.BitmapData(Cs.mcw,GH,true,0x00000000);
		var mc = dm.empty(DP_GROUND);
		var gdm  =new mt.DepthManager(mc);
		mc._y = GY;
		mc.attachBitmap(bmpGround,0);
		Filt.glow(mc,4,2,0xCC6600,true);
		Filt.glow(mc,2,2,0xCC6600);


		bmpGround.fillRect(new flash.geom.Rectangle(0,GH-RGH,Cs.mcw,RGH),0xFF000000 );

			// ELEMENTS
			var mc = dm.attach("mcGroundElement",0);
			var ma = 40;
			for( i in 0...24 ){
				var sc = 0.5+Math.random()*0.5;
				var m = new flash.geom.Matrix();
				m.scale(sc,sc);
				m.translate(ma+Std.random(Cs.mcw-ma), GH-RGH);
				mc.gotoAndStop(Std.random(mc._totalframes)+1);
				bmpGround.draw( mc, m );
			}
			mc.removeMovieClip();






		// HERO
		/*
		hero = cast dm.attach("mcCanon",DP_GROUND);
		hero._y = RGY;
		hero._x = DX;
		*/
		hero = cast gdm.attach("mcCanon",10);
		hero._y = GH-RGH;
		hero._x = DX;


		// EXPLODE
		mcExplode = dm.empty(DP_ONDE);
		edm = new mt.DepthManager(mcExplode);
		mcExplode._alpha = 25;

		// TARGET

	}
	/*
	function initTarget(){
		mcTarget = dm.attach("mcTarget",DP_PLASMA);
		mcTarget._x = root._xmouse;
		mcTarget._y = root._ymouse;
		mcTarget.stop();
	}
	*/

	// UPDATE
	public function update(){

		mt.Timer.tmod /= 2; // GAME WAS BUILT WITH 2 CALLS TO mt.Timer.update


		//for( i in 0...100000 ){var a = 5/8;}


		switch(step){
			case Play : updatePlay();
			case GameOver : updateGameOver();
			default:
		}


		plasma.drawMc(mcExplode);
		fade += mt.Timer.tmod;
		if(fade>1){
			var n = Math.floor(fade);
			plasma.ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,-n*2);
			fade-=n;
		}

		plasma.update();




		updateSprites();

		if( cmun!=munitions.length )KKApi.flagCheater();



	}
	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}

	// PLAY
	function initPlay(){
		step = Play;
	}
	function updatePlay(){
		moveHero();

		dif += 0.005*mt.Timer.tmod;

		replenish += mt.Timer.tmod;
		if( replenish > Cs.REPLENISH_CYCLE ){
			replenish -= Cs.REPLENISH_CYCLE;
			incMunition(1);
		}

		//
		if( !flGameOver && totalSpeed < dif*1.5 +Missile.BOOST*8 ){
			new Missile();
		}

		// GAMEOVER
		if( flGameOver ){

			var p = new Fly(dm.attach("mcFly",DP_GROUND));
			p.x = holes[Std.random(holes.length)] + (Math.random()*2-1)*2;
			p.y = Cs.mch+5;

		}



	}
	function moveHero(){
		var dx = root._xmouse - DX;
		var dy = root._ymouse - RGY;
		angle = Num.mm( -1.57, Math.atan2(dy,dx), -0.05 );
		hero.gun._rotation = angle/0.0174;
	}

	// GAMEOVER
	function initGameOver(){
		if(flGameOver)return;

		holes = [];
		while( patriots.length>0 )patriots[0].kill();
		flGameOver = true;
		KKApi.gameOver({});


	}
	function updateGameOver(){

	}
	//
	function launchMissile(){
		if( flGameOver )return;
		if( muniCount == 0 ){
			return;
		}

		incMunition(-1);
		var p = new Patriot();

		/*
		if(mcTarget!=null){
			p.mcTarget = mcTarget;
			mcTarget._alpha = 50;
			mcTarget.play();
			mcTarget = null;
		}
		*/

		//if( expl++ < 3 )initTarget();

	}


	// PLASMA
	function initPlasma(){
		plasma = new Plasma(dm.empty(DP_PLASMA),Cs.mcw,Cs.mch,0.5);
		//var fl = new flash.filters.BlurFilter();
		//fl.blurX = 2;
		//fl.blurY = 2;
		//plasma.filters.push(fl);
		plasma.ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,-2);
		plasma.root.blendMode = "add";
		fade = 0;

	}

	// TOOLS
	public function addScore(x,y,sc,cid){

		KKApi.addScore(sc);

		var score = KKApi.val(sc);

		var p = new Phys(dm.attach("mcScore",DP_SCORE));
		p.x = x;
		p.y = y;
		//p.vy = (score/100)*0.5;
		//p.weight = -0.15;
		//p.timer = 20+(score/100)*2;
		//p.root._alpha = p.alpha = 50;
		p.timer = 12;
		p.fadeLimit = 5;

		p.fadeType = 4;



		var mc:McField = cast p.root;
		mc.field.text = Std.string(score);
		if(cid!=null){
			var co = Col.colToObj(Missile.COLOR[cid]);
			var inc = -100;
			co.r = Std.int(Math.max(0,co.r+inc));
			co.g = Std.int(Math.max(0,co.g+inc));
			co.b = Std.int(Math.max(0,co.b+inc));

			mc.field.textColor = Col.objToCol(co);
		}

	}
	public function incMunition(inc){
		cmun = Std.int(Num.mm( 0, cmun+inc, Cs.MISSILE_MAX ));
		var goal = Num.mm( 0, munitions.length+inc, Cs.MISSILE_MAX );
		muniCount = goal;
		while( goal < munitions.length )munitions.pop().removeMovieClip();
		while( goal > munitions.length ){
			var mc = Game.me.dm.attach("mcMunition",DP_INTER);
			mc._x = 4;
			mc._y = 283-munitions.length*5;
			munitions.push(mc);
		}

	}
	public function makeHole(x:Float,y:Float,sc:Float){
		var mc = dm.attach("mcOnde",0);
		var m = new flash.geom.Matrix();
		m.scale(sc,sc);
		m.translate(Std.int(x),Std.int(y-GY));
		bmpGround.draw(mc,m,null,"erase");
		mc.removeMovieClip();
		if( y+sc*50 > Cs.mch+1 ){
			initGameOver();
			holes.push(x);
		}
	}

	public function getGroundHeight(x){
		for( y in 0...GH ){
			var n = bmpGround.getPixel32(x,y);
			if( n!=0 )return GY+y;
		}
		return Cs.mch;
	}



//{
}



























