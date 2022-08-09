import KKApi;
import mt.bumdum.Lib;
import Protocol;


enum Step {
	Play;
	Bomb;
	Transfert;
	TestScroll;
}
typedef Victim = {p:Phys,ray:Float};
typedef Line = {>flash.MovieClip,c:Float};

typedef Fayot = {_k:Array<Int>,_m:Array<Int>}

// TWIN SPIRIT
class Game {//}

	public static var FL_TEST =		false;
	public static var FL_TEST_SCROLL =	false;

	public static var DP_FRONT_FX = 	20;
	public static var DP_FRONT = 		18;

	public static var DP_INTER = 		17;

	public static var DP_FX = 		14;
	public static var DP_SHOTS = 		12;
	public static var DP_BADS = 		11;
	public static var DP_SCORE = 		10;
	public static var DP_HERO = 		9;
	public static var DP_UNDER_FX = 	6;

	public static var DP_BG = 		0;

	public var flTwinMode:Bool;


	var sstep:Int;
	var coef:Float;

	var frame:Float;
	var build:Int;

	public var robertId:Int;
	public var shotId:Int;

	var posMax:Float;
	var xmax:Int;
	var ymax:Int;
	var perf:Int;
	var sid:Int;

	public var bonus:mt.flash.Volatile<Int>;
	public var step:Step;

	public var generator:Stykades;
	public var scroller:Scroller;
	public var fayot:Fayot;

	public var bads:mt.flash.PArray<Bad>;
	public var shots:mt.flash.PArray<Phys>;
	public var parts:Array<Part>;
	public var heros:mt.flash.PArray<Hero>;
	public var sprites:Array<Sprite>;
	public var bgrid:Array<Array<Array<Bad>>>;
	public var sgrid:Array<Array<Array<BadShot>>>;

	public static var me:Game;
	public var dm:mt.DepthManager;
	public var sdm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var mcInter:{>flash.MovieClip,star:flash.MovieClip, fieldLvl:flash.TextField};

	// REVERSE
	//public var flTransfert:Bool;
	public var bomb:Bomb;
	public var mcStase:{>flash.MovieClip,bmp:flash.display.BitmapData,mask:flash.MovieClip,light:flash.MovieClip,ray:Float};
	public var swap:{ mc:flash.MovieClip, sx:Float, sy:Float, tx:Float, ty:Float };
	public var htrg:Hero;
	public var speedLines:Array<Line>;
	public var victims:Array<Victim>;

	//
	var bmpGrid:flash.display.BitmapData;

	public function new( mc : flash.MovieClip ){
		haxe.Log.setColor(0xFFFFFF);
		Cs.init();
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);
		bg = dm.attach("mcBg",DP_BG);

		flTwinMode = false;

		heros = new mt.flash.PArray();
		sprites = [];
		shots = new mt.flash.PArray();
		bads = new mt.flash.PArray();
		parts = [];
		initGrid();
		initInter();

		//
		fayot = { _k:[0,0,0,0,0,0,0,0,0,0,0,0,0], _m:[] };
		//
		perf = 0;
		frame = 0;
		flTwinMode = false;

		// SID
		sid = Std.random(100000);
		if(Stykades.FL_TEST_WAVE)sid = 1244;

		// SMOKE LAYER
		var mc = dm.empty(DP_UNDER_FX);
		sdm = new mt.DepthManager(mc);
		Filt.blur(mc,4,4);
		mc.blendMode= "layer";

		// SCROLLER
		//scroller = new Scroller();



		initBuild();
		//
		if(FL_TEST_SCROLL)initTestScroll();
		else initPlay();
	}
	function initGrid(){
		bgrid = [];
		for( x in  0...Cs.XMAX ){
			bgrid[x] = [];
			for( y in  0...Cs.YMAX ){
				bgrid[x][y] = [];
			}
		}
		sgrid = [];
		for( x in  0...Cs.XMAX ){
			sgrid[x] = [];
			for( y in  0...Cs.YMAX ){
				sgrid[x][y] = [];
			}
		}
	}

	//
	public function update(){
		if(build!=null){
			updateBuild();
			//return;
		}

		frame += mt.Timer.tmod;
		while(frame>0)playAll();
		checkPerf();
		//
		var list = mt.bumdum.Sprite.spriteList.copy();
		for(sp in list)sp.update();

		viewGrid(cast sgrid);
	}
	public function playAll(){
		frame--;
		scroller.update();
		switch(step){
			case Play : 		updatePlay();
			case Bomb :		updateBomb();
			case TestScroll :	updateTestScroll();
			default:
			//case Transfert :	updateTransfert();
		}

	}

	// PLAY
	public function initPlay(){
		step = Play;
		setBonus(0);
		generator = new Stykades(sid);


		var hid = 0;//Std.random(2);
		if(heros.length>0)hid = 1-heros[0].id;
		var h = new Hero(hid);


		for( h in heros )h.birth();


	}
	public function updatePlay(){
		scroller.inc(1);
		generator.incDanger(1);
		var list = sprites.copy();
		for( s in list ){
			if(step!=Play)return;
			s.update();
		}
	}

	public function checkPerf(){
		//haxe.Log.clear();
		//trace("!! "+perf);
		if( mt.Timer.tmod > 1.5 && scroller.destroyCount==null ){
			perf++;


			if(perf>50){
				perf = 0;
				scroller.destroyCount = 10;
			}
		}else{
			if(perf>0)perf--;
		}
	}

	// BOMB
	public function initBomb(hero,bomb){
		this.bomb = bomb;
		htrg = hero;
		step = Bomb;
		posMax = scroller.pos;
		coef = 0;
		sstep = 0;
		generator.danger = 0;

		for(p in parts)p.root._visible = false;
		var x = hero.x;
		var y = hero.y;

		mcStase = cast dm.empty(DP_FRONT);
		mcStase.bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0xFF0000);
		var m = new flash.geom.Matrix();


		for( b in bads )b.root._visible = false;
		for( b in shots )b.root._visible = false;
		mcStase.bmp.draw(root);
		for( b in bads )b.root._visible = true;
		for( b in shots )b.root._visible = true;

		mcStase.attachBitmap(mcStase.bmp,0);
		mcStase.mask = dm.attach("mcRound",DP_FRONT);
		mcStase.mask._x = x;
		mcStase.mask._y = y;
		mcStase.mask._xscale = mcStase.mask._yscale = 0;
		mcStase.setMask(mcStase.mask);
		var dx = Math.max(  Math.abs(x), Math.abs(Cs.mcw-x) );
		var dy = Math.max(  Math.abs(y), Math.abs(Cs.mch-y) );
		mcStase.ray = Math.sqrt(dx*dx+dy*dy);

		mcStase.light = dm.attach("mcReverseLight",DP_FRONT);
		mcStase.light._x = x;
		mcStase.light._y = y;
		mcStase.light._xscale = mcStase.light._yscale = 0;
		mcStase.light.blendMode = "add";
		Filt.blur(mcStase.light,12,12);

		fige(mcStase);

		// DESTROY
		victims = [];
		for( b in bads )b.addToVictims();
		for( s in shots )s.addToVictims();
		var f = function(a:Victim,b:Victim){
			if(a.ray<b.ray)return -1;
			return 1;
		}
		victims.sort(f);




	}
	public function updateBomb(){

		switch(sstep){

			case 0: // FADE OUT
				coef = Math.min(coef+0.05,1);
				var sc = coef*(mcStase.ray*2);
				mcStase.mask._xscale = mcStase.mask._yscale = sc;
				mcStase.light._xscale = mcStase.light._yscale = sc;

				while( victims[0].ray < sc ){
					victims.shift().p.warp();

				}


				if(coef==1){
					mcStase.light.removeMovieClip();
					mcStase.mask.removeMovieClip();
					mcStase.bmp.dispose();
					mcStase.removeMovieClip();
					scroller.attachMask();
					fige(root);
					coef = 0;
					while(bads.length>0)bads[0].warp();
					while(shots.length>0)shots[0].warp();
					while(parts.length>0)parts[0].kill();
					while(mt.bumdum.Sprite.spriteList.length>0)mt.bumdum.Sprite.spriteList[0].kill();

					switch(bomb){
						case Transfert :
							var other = htrg.getTwin();
							var mc = Game.me.dm.attach( "mcSwap", Game.DP_FX );
							mc._x = htrg.x;
							mc._y = htrg.y;
							swap = { mc:mc, sx:htrg.x, sy:htrg.y, tx:other.x, ty:other.y };
							sstep = 11;
							coef = 0;

						case Reverse :
							speedLines = [];
							for( i in 0...50 ){
								var mc:Line = cast Game.me.dm.attach("mcLine",Game.DP_FX);
								mc._x = Math.random()*Cs.mcw;
								mc._y = Math.random()*Cs.mch;
								mc.c = 0.1+Math.random()*0.5;
								mc._yscale = 0;
								mc._alpha = 40+mc.c*100;
								speedLines.push(mc);
							}
							sstep = 1;

						case Standard :
							sstep = 3;
					}
				}
			case 1:
				coef = Math.min(coef+0.05,1);
				if(coef==1)sstep++;

			case 2: // REVERSE
				var parc = posMax-scroller.startPos;

				var sc = Num.mm( 0.002, 10/parc, 0.01 );



				coef = Math.max(coef-sc,0);
				var c = (1-Math.cos(coef*3.14 ))*0.5;

				scroller.setPos( scroller.startPos + c*parc );
				var vy = scroller.speed*Scroller.HIGHSPEED;


				//trace(vy);

				for( mc in speedLines ){
					mc._y += vy*mc.c;
					mc._yscale = -vy*mc.c;
					if( mc._y+mc._yscale < 0 ){
						mc._x = Math.random()*Cs.mcw;
						mc._y = Cs.mch;

					}
				}



				if( coef==0 ){
					while( speedLines.length>0 )speedLines.pop().removeMovieClip();
					scroller.setPos( scroller.startPos );
					sstep = 3;
				}

			case 3: // FADE IN
				coef = Math.min(coef+0.1,1);
				root.filters = [];
				fige(root,1-coef);
				if( coef==1 ){
					root.filters = [];

					scroller.removeMask();

					switch(bomb){
						case Transfert :	step = Play;
						case Standard :		step = Play;
						case Reverse :
							initPlay();
							flTwinMode = true;

					}


				}

			case 11: // TRANSFERT
				coef = Math.min(coef+0.05,1);
				var cc = (1-Math.cos(coef*3.14))*0.5;
				var ox =  swap.mc._x;
				var oy =  swap.mc._y;
				swap.mc._x = swap.sx*(1-cc) + swap.tx*cc;
				swap.mc._y = swap.sy*(1-cc) + swap.ty*cc - 80*Math.sin(coef*3.14);

				var dx = swap.mc._x - ox;
				var dy = swap.mc._y - oy;
				var mc = dm.attach("mcQueue",Game.DP_FX);
				mc._x = ox;
				mc._y = oy;
				mc._xscale = Math.sqrt(dx*dx+dy*dy);
				mc._rotation = Math.atan2(dy,dx)/0.0174;
				if( coef==1 ){
					swap.mc.removeMovieClip();
					coef = 0;
					sstep = 3;
					var mc = dm.attach("mcWarp",Game.DP_FX);
					mc._x = swap.tx;
					mc._y = swap.ty;
					mc._xscale = mc._yscale = 300;

				}








		}


	}


	// GAMEOVER
	public function initGameOver(){
		if( bads.cheat || heros.cheat || shots.cheat ) KKApi.flagCheater();
		KKApi.gameOver({});
	}

	// INTERFACES
	public function initInter(){
		mcInter = cast dm.attach("mcInter",DP_INTER);
		mcInter._y = Cs.mch;
		if( !FL_TEST ) mcInter.fieldLvl._visible = false;
		setLevel(0);
	}
	public function setBonus(n){
		bonus = n;
		var field:flash.TextField = cast (mcInter.star.smc).field;
		field.text = Std.string(n);
		if(n>0)mcInter.star.gotoAndPlay(2);

	}
	public function incBonus(n){
		setBonus(bonus+n);
	}
	public function setLevel(n:Int){
		mcInter.fieldLvl.text = "lvl "+n;
	}

	// BUILD
	public function initBuild(){
		build = 0;
		scroller = new Scroller();
		//scroller.root._visible = false;initPlay();

	}
	public function updateBuild(){
		var max = 5;
		var flFinish = scroller.addParallax(build,5);
		if(flFinish)build++;
		if( build == 5 )build = null;
	}

	// FX
	public function genScore(x,y,n,col){

		var p = new Part(Game.me.dm.attach("partScore",DP_FX));
		p.x = x;
		p.y = y;
		p.vy = -3;
		p.timer = 15;
		p.weight = 0.5;
		p.fadeLimit = 5;
		var field:flash.TextField = (cast p.root.smc).field;
		field.text = Std.string(n);
		Filt.glow(cast field,2,4,col);
		p.setScale(70+Math.pow(n,0.5));
		p.updatePos();
	}
	public function fige(mc:flash.MovieClip,?c:Float){

		//*
		Filt.grey(mc,c,30);

		/*/
		if(c==null)	c = 1;
		var m0 = [
			1,	0,	0,	0,	0,
			0,	1,	0,	0,	0,
			0,	0,	1,	0,	0,
			0,	0,	0,	1,	0
		];

		var r = 0.6;
		var g = 0.2;
		var b = 0.2;
		var m1 = [
			0,	1,	1,	0,	0,
			1,	0,	0,	0,	0,
			1,	0,	0,	0,	0,
			0,	0,	0,	1,	0,

		];

		var m = [];
		for( i in 0...m0.length ){
			m[i] = m0[i]*(1-c) + m1[i]*c;
		}

		var fl = new flash.filters.ColorMatrixFilter();
		fl.matrix = m;

		var a = mc.filters;
		a.push(fl);
		mc.filters = a;
		//*/

	}

	// TOOLS
	public function getMainHero():{x:Float,y:Float}{
		var h = cast Game.me.heros[0];
		if(h==null) h = {x:Cs.mcw*0.5,y:Cs.mch-5.0};
		return h;
	}
	public function isPlaying(){
		return step==Play;
	}
	// DEBUG
	function viewGrid(grid){
		if( !flash.Key.isDown(71) ){
			bmpGrid.dispose();
			bmpGrid = null;
			return;
		}

		if(bmpGrid==null){
			bmpGrid = new flash.display.BitmapData( Cs.XMAX, Cs.YMAX, false, 0 );
			var mc = dm.empty(DP_BG);
			mc.attachBitmap(bmpGrid,0);
			mc.blendMode = "add";

			mc._xscale = (Cs.mcw/Cs.XMAX)*100;
			mc._yscale = (Cs.mch/Cs.YMAX)*100;
		}

		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){

				var n = grid[x][y].length * 20;
				if( n >255 ) n = 255;
				var col = Col.objToCol({r:n,g:n,b:n});


				bmpGrid.setPixel(x,y,col);
			}
		}


	}

	function initTestScroll(){
		step = TestScroll;
		//scroller.root._xscale = scroller.root._yscale = 10;
	}
	function updateTestScroll(){
		haxe.Log.clear();
		var c = scroller.pos / Scroller.BGH;
		trace( Std.int(c*100)+"%" );

		scroller.inc( Std.int(-(root._ymouse-Cs.mch*0.5)*0.1) );
	}

//{
}







