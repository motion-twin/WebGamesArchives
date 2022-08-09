import KKApi;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import Protocol;

typedef Spawn = { x:Float, y:Float, sc:KKConst, color:Int };
typedef McText = { >flash.MovieClip, field:flash.TextField };


class Game {//}


	public static var FL_TEST =		true;

	public static var DP_FX = 		8;

	public static var DP_DECOR = 		7;
	public static var DP_PIOU = 		6;
	public static var DP_BALLS = 		5;

	public static var DP_STOMACH_1 =	4;
	public static var DP_STOMACH_0 =	3;
	public static var DP_INTER = 		2;
	public static var DP_MAP = 		1;
	public static var DP_BG = 		0;

	public var coef:mt.flash.Volatile<Float>;
	public var upc:mt.flash.Volatile<Float>;
	public var heightMax:mt.flash.Volatile<Int>;
	public var lvl:mt.flash.Volatile<Int>;
	public var lineCount:mt.flash.Volatile<Int>;
	public var bonusStomach:mt.flash.Volatile<Int>;

	var flhColor:Int;
	var flh:Float;


	public var grid : Array<Array<Ball>>;
	public var balls : mt.flash.PArray<Ball>;
	public var work : mt.flash.PArray<Ball>;
	public var fallList : Array<Ball>;

	public var scoreSpawn : Array<Spawn>;

	public var hero:Piou;

	public var action:Void->Void;
	public static var me:Game;
	public var mdm:mt.DepthManager;
	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var map:flash.MovieClip;
	public var mcShow:flash.MovieClip;
	public var mcInter:flash.MovieClip;
	public var mcTimer:flash.MovieClip;
	public var mcLevel:McText;



	public function new( mc : flash.MovieClip ){

		Cs.init();
		root = mc;
		me = this;
		mdm = new mt.DepthManager(root);
		bg = mdm.attach("mcBg",DP_BG);


		fallList = [];
		balls = new mt.flash.PArray();
		work = new mt.flash.PArray();

		initMap();
		initGrid();
		initPlay();

		upc = 0;
		heightMax = 0;

		hero = new Piou(4,Cs.YMAX-1);
		initInter();



		lvl = 0;
		//Cs.COLOR_MAX+=2;
		levelUp();




	}

	public function initGrid(){
		var lim = 7;

		grid = [];
		for( x in 0...Cs.XMAX )grid[x] = [];




		dm.over(hero.root);
	}
	public function initMap(){



		map = mdm.empty(DP_MAP);
		map._y = 14;
		//map._y = 6;
		dm = new mt.DepthManager(map);

		// GROUND
		var brush = mdm.attach("mcTile",0);

		var c = 32;
		var bmp = new flash.display.BitmapData(Cs.mcw,200);
		var xmax = Math.ceil(bmp.width/c);
		var ymax = Math.ceil(bmp.height/c);
		for( x in 0...xmax ){
			for( y in 0...ymax ){
				var m = new flash.geom.Matrix();
				//m.scale(0.75,0.75);
				m.translate(x*c,y*c);
				brush.gotoAndStop(y==0?2:1);

				brush.smc.gotoAndStop(Std.random(brush.smc._totalframes)+1);
				bmp.draw(brush,m);
			}
		}
		brush.removeMovieClip();
		var mc = dm.empty(DP_DECOR);
		mc.attachBitmap(bmp,0);
		mc._y = Cs.YMAX*Cs.CS;



	}

	//
	public function levelUp(){


		bonusStomach = 0;
		upc = 0;
		lvl++;
		lineCount = lvl+1;
		if(lineCount>5)lineCount = 5;
		Cs.COMBO_LIMIT = lvl+1;

		mcLevel.field.text = "x"+Cs.COMBO_LIMIT;
		newLine();



	}

	//
	public function update(){



		#if prod
		mcShow._visible = false;
		#end

		action();

		var a = Sprite.spriteList.copy();
		for( sp in a )sp.update();

		if(flh!=null)updateFlash();


		if(hero.stomach.cheat || balls.cheat || work.cheat ) KKApi.flagCheater();

	}

	// SCROLL
	public function updateScroll(){
		var ty = Cs.mch*0.5-hero.root._y;
		var dy = ty-map._y;
		var lim = 12;
		map._y += Num.mm(-lim,dy*0.1,lim);


		var lim = Cs.mch-( Cs.YMAX*Cs.CS + 60 ) ;
		if( map._y < lim )map._y = lim;
	}

	// PLAY
	public function initPlay(){

		action = updatePlay;
		//checkLine();

	}
	function updatePlay(){

		upc = Math.min( upc + 0.0001*Math.min(lvl+1,6) , 1 );
		updateTimer(0.3);
		if(upc==1)initGameOver();

		hero.update();



	}

	// COMBOS
	public function checkCombo(){

		scoreSpawn = [];
		work = new mt.flash.PArray();
		var list = getGroups(grid);

		for( a in list ){
			var n = a.length;
			if( n>= Cs.COMBO_LIMIT ){
				var mx = 0;
				var my = 0;
				var col = 0;
				for(bl in a ){
					mx += bl.px;
					my += bl.py;
					work.push(bl);
					col = bl.color;
				}
				var x = Cs.getX(mx/n);
				var y = Cs.getX(my/n);
				var sc = Cs.getScore(n);
				scoreSpawn.push({x:x,y:y,sc:sc,color:col});
			}
		}
		if(work.length>0){
			initExplode();
		}else{
			if(!checkEnd(false))initPlay();
		}
	}
	function getGroups(gr:Array<Array<Ball>>){
		var gList = [];
		for( bl in balls )bl.gid = null;
		for( b in balls ){
			if( !b.flIce ){
				if( b.gid == null ){
					b.gid = gList.length;
					gList.push([b]);
				}

				for( d in Cs.CDIR ){
					var nx = b.px + d[0];
					var ny = b.py + d[1];
					var b2 = gr[nx][ny];

					if( b.color == b2.color && b.color!=null && !b2.flIce && b.color!=10 ){
						if(b2.gid==null){
							b2.gid = b.gid;
							gList[b.gid].push(b2);
						}else if(b2.gid==b.gid){

						}else{
							var kgid = b2.gid;
							var list = gList[kgid];

							for( b3 in list ){
								b3.gid = b.gid;
								gList[b.gid].push(b3);
							}
							gList[kgid] = null;

						}
					}
				}
			}
		}

		var i = 0;
		while( i<gList.length ){
			if( gList[i] == null )gList.splice(i,1);
			else i++;
		}

		return gList;

	}

	// EXPLOSION
	public function initExplode(){
		//trace("explode!"+work.length);
		action = updateExplode;
		coef = 0;
	}
	public function updateExplode(){
		coef = Math.min(coef+0.1,1);
		//trace("updateExplode("+coef+")");
		var a = [];

		for( b in work ){
			Col.setPercentColor(b.root,coef*100,0xFFFFFF);
			b.root.filters = [];
			Filt.glow(b.root,coef*8,coef*2,0xFFFFFF);
			if(coef==1){
				a.push([b.px,b.py]);
				b.explode();
			}
		}
		if(coef==1){
			while(scoreSpawn.length>0){
				var o = scoreSpawn.pop();
				KKApi.addScore(o.sc);
				var p = newScore(o.x,o.y,KKApi.val(o.sc),Cs.FRUIT_COLOR[o.color]);

			};
			action = null;
			initFall();
			if(action==null){
				if(!checkEnd(false))initPlay();
			}

		}
	}
	public function explodeAll(color){
		work = new mt.flash.PArray();
		for( b in balls ){
			if(b.color==color)work.push(b);
		}
		initExplode();
	}

	// FALL
	public function initFall(){

		fallList =[];
		coef = 0;
		heightMax = 0;
		for( x in 0...Cs.XMAX ){
			var a = grid[x];
			var hole = 0;
			for( y in 0...Cs.YMAX ){
				var ball = grid[x][Cs.YMAX-(1+y)];
				if(ball==null)hole++;
				else {
					if(y-hole>=heightMax && ball !=Game.me.hero ) heightMax = y-hole;
					if(hole>0){
						ball.fallAmount = hole;
						fallList.push(ball);
					}
				}
			}
		}



		if(fallList.length>0)action = updateFall;
		//else if(!checkEnd(false))initPlay();
		//else checkCombo();


		//trace("fallList : "+fallList.length);


	}
	public function updateFall(){
		//trace("updateFall("+coef+")");
		hero.update();

		coef += 0.25;
		var a = fallList.copy();
		for( ball in a ){
			ball.display(ball.px,ball.py+coef);
			if(coef>=1){
				ball.fallAmount--;
				ball.move(0,1);
				if(ball.fallAmount==0)fallList.remove(ball);
			}
		}

		if(coef>=1){
			if(fallList.length>0){
				coef -= 1;
			}else{
				checkCombo();
			}
		}

	}


	public function newUpLine(){

		for( x in 0...Cs.XMAX ){
			var b = new Ball(x,0);
		}

	}
	public function newLine(){
		lineCount--;

		heightMax++;
		action = updateLine;
		for( x in 0...Cs.XMAX ){
			var top = grid[x][0];
			if(top!=null)top.explode();
			for( y in 1...Cs.YMAX ){
				var b = grid[x][y];
				b.move(0,-1);
			}

		}

		var flTimeout = false;

		for( x in 0...Cs.XMAX ){
			var ball = new Ball(x,Cs.YMAX-1);
			var to = 0;
			while(true){
				var flBreak = true;
				var list = getGroups(grid);
				for( a in list ){
					if(a.length>=Cs.COMBO_LIMIT){
						flBreak= false;
						break;
					}
				}
				if(flBreak)break;
				ball.setColor(null);

				if(to++>100){

					flTimeout = true;
					break;
				}
			}
			ball.display(ball.px,ball.py+1);
			if(flTimeout)break;
		}



		coef = 0;
	}
	public function updateLine(){
		coef = Math.min(coef+0.15,1);
		for( b in balls )b.display(b.px,b.py+1-coef);
		if(coef==1){
			if(lineCount>0)newLine()
			else {

				initPlay();
				hero.init();
			}
		}

	}

	//
	public function checkEnd(?flControl){
		if(flControl==null)flControl = true;

		if(hero.stomachSize<=0){
			Game.me.initGameOver();
			return true;
		}

		if(balls.length>1){
			if(flControl)hero.setAction(hero.control);
			return false;
		}else{
			initBonus();
			return true;
		}
	}

	//
	/*
	public function checkEmpty(px,py){

		var ball = grid[px][py-1];
		if (ball != null ){
			ball.initFall();
		}

	}
	*/

	// TIME SCORE
	public function initBonus(){

		if(hero.stomach.length==0 ){
			var sc = Cs.SCORE_PERFECT;
			KKApi.addScore(sc);

			var lim = 30;
			var x = Num.mm(lim,hero.root._x,Cs.mcw-lim);

			var p  = newScore( x, hero.root._y, KKApi.val(sc) );
			p.setScale(150);
			p.vy = -4;
		}

		action = updateBonus;
	}
	public function updateBonus(){
		upc = Math.min(upc+0.02,1);
		KKApi.addScore(KKApi.const(15));
		if( upc == 1)levelUp();
		updateTimer(1);

	}

	public function initPerfect(){

	}


	// GAMEVOER
	public function initGameOver(){
		action = gameOver;
		upc = null;
		hero.explode();
		KKApi.gameOver({});
	}
	function gameOver(){
		updateTimer(0.5);

	}

	// INTER
	static var JMARGIN = 13;
	static var JSIZE = 12;
	public function initInter(){

		// TIMER
		mcTimer = mdm.attach("mcTimer",DP_INTER);
		mcTimer._x = Cs.mcw-(7+32);
		mcTimer._y = Cs.mch-16;
		mcTimer._xscale *= -1;

		//
		mcLevel = cast mdm.attach("mcLevel",DP_INTER);
		mcLevel._x = Cs.mcw;
		mcLevel._y = Cs.mch;


		// JAUGE
		displayJauge();
	}
	public function displayJauge(){
		mdm.clear(DP_STOMACH_0);
		var mmc = mdm.empty(DP_STOMACH_0);
		var ddm = new mt.DepthManager(mmc);
		Filt.glow(mmc,2,4,0xC17746);
		for( n in 0...hero.stomachSize ){
			var mc = ddm.attach("mcJauge",DP_STOMACH_0);
			mc._x = JMARGIN +n*JSIZE;
			mc._y = Cs.mch-JMARGIN;
			mc._xscale = mc._yscale = 36;

		}
	}
	public function displayStomach(){
		mdm.clear(DP_STOMACH_1);
		var dif = hero.stomach.length-hero.stomachSize;

		if(dif>0){
			mdm.clear(DP_STOMACH_0);
			return;
		}
		for( n in 0...hero.stomach.length ){
			var id = hero.stomach[hero.stomach.length-(1+n)];
			var mc = mdm.attach("mcBall",DP_STOMACH_1);
			mc._x = JMARGIN +n*JSIZE;
			mc._y = Cs.mch-JMARGIN;
			mc._xscale  = mc._yscale = 36;
			mc.gotoAndStop(id+1);
		}
		if(dif==0){
			var mc = mdm.attach("mcWarning",DP_STOMACH_1);
			mc._x = JMARGIN + hero.stomachSize*JSIZE + 2;
			mc._y = Cs.mch-JMARGIN;
			Filt.glow(mc,2,4,0);
		}





	}
	public function updateTimer(c:Float){
		var ds = Math.max(0,98-upc*100) - mcTimer.smc.smc._xscale;
		mcTimer.smc.smc._xscale += ds*c;
	}

	// FX
	public function newScore(x,y,n:Int,?col:Int){
		if(n==0)return null;
		var p = new mt.bumdum.Phys(dm.attach("partScore",DP_FX));
		p.x = x;
		p.y = y;
		p.timer = 30;
		//p.weight = -0.1;
		p.frict = 0.95;
		p.vy = -1;
		p.fadeType = 0;
		Reflect.setField( p.root, "_score", Std.string(n) );
		Filt.glow( p.root, 4, 10, 0xFFFFFF );
		if(col!=null)Col.setPercentColor( p.root.smc.smc, 70, col );
		return p;

	}
	public function updateFlash(){
		var prc = flh;
		flh *= 0.6;
		if( flh<0.1 ){
			flh = null;
			prc = 0;
		}
		Col.setPercentColor(root,prc,flhColor);
	}
	public function fxFlash(col){
		flhColor = col;
		flh = 100;
	}

	// DEBUG
	#if prod
	public function show(x,y){
		if(mcShow==null)mcShow = dm.attach("mcShow",DP_FX);
		mcShow._visible = true;
		mcShow._x = Cs.getX(x);
		mcShow._y = Cs.getY(y);
	}
	#end


//{
}























