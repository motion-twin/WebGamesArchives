import KKApi;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;
import Protocol;




class Game {//}

	public static var FL_TEST =		true;

	public static var SELECT_MODE =		0;

	public static var DP_COL = 		7;
	public static var DP_SCORE = 		6;
	public static var DP_FX = 		5;
	public static var DP_FG = 		4;
	public static var DP_ARROW = 		3;
	public static var DP_BALLS = 		2;
	public static var DP_BG = 		0;

	var px:Int;
	var py:Int;

	//var flAbove:Bool;
	var miss:mt.flash.Volatile<Int>;
	var lvl:mt.flash.Volatile<Int>;
	var multi:mt.flash.Volatile<Int>;
	var willScore:mt.flash.Volatile<Int>;
	var coef:Float;
	var blink:Float;

	public var grid : Array<Array<Ball>>;
	public var balls : Array<Ball>;
	public var work : mt.flash.PArray<Ball>;

	public var missList : mt.flash.PArray<flash.MovieClip>;

	public var arrows : Array<mt.bumdum.Phys>;
	public var selectors : Array<flash.MovieClip>;

	public var step:Step;
	public var action:Void->Void;

	public static var me:Game;
	public var dm:mt.DepthManager;
	public var sdm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var fg:flash.MovieClip;
	public var cl:flash.MovieClip;



	public function new( mc : flash.MovieClip ){
		//haxe.Log.setColor(0xFFFFFF);
		Cs.init();
		root = mc;
		me = this;
		dm = new mt.DepthManager(root);
		bg = dm.attach("mcBg",DP_BG);
		//fg = dm.attach("mcFg",DP_FG);

		cl = dm.attach("cLayer",DP_COL);
		cl.blendMode = "overlay";
		cl._alpha = 70;
	

		var shade = dm.empty(DP_BG);
		sdm = new mt.DepthManager(shade);

		lvl=0;
		//for(i in 0...7)levelUp();

		setMiss(3);
		initInter();

		arrows = [];
		balls = [];
		initGrid();
		fillGrid();
		initPlay();
		/*
		root._xscale = 50;
		root._yscale = 50;
		root._x += 75;
		root._y += 75;
		*/

	}
	public function initGrid(){
		grid = [];
		for( x in 0...Cs.XMAX ){
			grid[x] = [];
			for( y in 0...Cs.YMAX ){
				//var ball = new Ball(x,y);
			}
		}
	}
	public function fillGrid(){
		var y = 0;
		for( y in 0...Cs.YMAX ){
			var a = [];
			for( x in 0...Cs.XMAX ){
				var b = new Ball(x,y);
				grid[x][y] = b;
				a.push(b);
			}
			while(true){
				for( b in a )b.setColor();
				var list = getGroups(grid);
				var flBreak = true;
				for( a in list ){
					if(a.length>=Cs.COMBO_LIMIT){
						flBreak = false;
						break;
					}
				}
				if(flBreak)break;
			}


		}


	}

	//
	public function update(){

		action();
		var a = Sprite.spriteList.copy();
		for( sp in a )sp.update();

	}

	// PLAY
	public function initPlay(){

		step = Play;
		action = updatePlay;
		work = new mt.flash.PArray();
		selectors = [];

		px = null;
		py = null;
		updatePlay();

		bg.onPress = validate;
		bg.useHandCursor = true;



	}
	function updatePlay(){




		updateSelection();


	}
	function updateSelection(){

		var npx = Cs.getPX( bg._xmouse );
		var npy = Cs.getPY( bg._ymouse );


		//var npx = Std.int(Num.mm(0,x,Cs.XMAX-2));
		//var npy = Std.int(Num.mm(0,y,Cs.YMAX-2));



		if(npx==px && npy==py )return;

		while(work.length>0)work.pop().unselect();
		while( arrows.length>0 ){
			var p = arrows.pop();
			p.fadeType = 0;
			p.fadeLimit = 5;
			p.timer = p.fadeLimit;
		}
		while( selectors.length>0 )selectors.pop().removeMovieClip();

		if( npx<0 || npx>Cs.XMAX-2 || npy<0 || npy>Cs.YMAX-2 ){
			px = null;
			py = null;
			return;
		}


		px = npx;
		py = npy;


		for( dx in 0...2 ){
			for( dy in 0...2 ){
				var rot = [-90,0,180,90][work.length];
				var b = grid[px+dx][py+dy];
				b.select();
				work.push(b);

				if(SELECT_MODE==1){
					var mc = dm.attach("mcSelectRound",DP_BALLS);
					mc._x = b.root._x;
					mc._y = b.root._y;
					selectors.push(mc);

				}


				if(SELECT_MODE==0){
					var a = rot*0.0174;
					var p = new mt.bumdum.Phys( dm.attach("mcArrow",DP_ARROW) );
					p.x = b.root._x + Math.cos(a)*Cs.CS*0.5;
					p.y = b.root._y + Math.sin(a)*Cs.CS*0.5;
					p.root._rotation = rot;
					arrows.push(p);
				}

			}
		}

		if(SELECT_MODE==1)for(b in work)dm.over(b.root);

	}
	function validate(){
		if( px==null )return;
		setMiss(miss-1);
		for( b in work )b.unselect();
		initMove();



		while( arrows.length>0 )arrows.pop().kill();
		while( selectors.length>0 )selectors.pop().removeMovieClip();

	}

	// MOVE
	function initMove(){
		step = Move;
		action = updateMove;
		bg.onPress = null;
		bg.useHandCursor = false;
		coef = 0;
		multi = 0;

		for(b in work )b.removeFromGrid();

	}
	function updateMove(){
		coef = Math.min(coef+0.2*mt.Timer.tmod,1);

		for( i in 0...4 ){
			var d = Cs.DIR[i];
			var b = work[i];
			b.display(b.px+d[0]*coef,b.py+d[1]*coef);
			if(coef==1){
				b.setPos(b.px+d[0],b.py+d[1]);
			}
		}

		if(coef==1)checkCombo(true);
	}

	// COMBOS
	function checkCombo(?flFirst){

		work = new mt.flash.PArray();
		var list = getGroups(grid);
		for( a in list ){
			if(a.length>=Cs.COMBO_LIMIT){
				for(bl in a )work.push(bl);
			}
		}
		if(work.length>0){
			initExplode();
		}else{

			if(flFirst){
				if(miss==0)initGameOver();
				else initPlay();
			}else{
				levelUp();
				initGrow();
			}
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

	// EXPLODE
	function initExplode(){
		step = Explode;
		action = updateExplode;
		coef = 0;
		blink = 0;
		for( b in work )dm.over(b.root);

		willScore = work.length;

	}
	function updateExplode(){
		coef = Math.min(coef+0.08*mt.Timer.tmod,1);

		blink = (blink+1)%2;
		var c = coef+blink*0.2;


		//var bsc = Cs.SCORE_STEP[multi];


		var totalScore = KKApi.const(0);
		for( b in work ){
			var prc =  Math.max(0,coef*200-100);
			Col.setPercentColor(b.root,prc,0xFFFFFF);
			b.root.filters = [];
			Filt.glow(b.root,c*12,c*4,0xFFFFFF);
			if( coef==1 ){
				var sc = Cs.SCORE_BALL[b.color];
				totalScore = KKApi.cadd( totalScore,sc);
				fxScore(b.root._x,b.root._y, KKApi.val(sc),Cs.COLOR_LIST[b.color]);
				b.explode();

			}

		}
		if( coef==1 ){
			//var sc = KKApi.cmult( KKApi.const(willScore), bsc );
			KKApi.addScore(totalScore);
			initFall();
		}

		if(work.cheat)KKApi.flagCheater();

	}

	// FALL
	function initFall(){

		step = Fall;
		action = updateFall;
		multi++;
		if(multi>2)multi=2;
		coef = 0;



		//
		buildFallList();


	}
	function updateFall(){
		coef += 0.3*mt.Timer.tmod;
		//var c = Math.min(coef,1);

		while(coef>1){
			coef--;
			var list = work.copy();
			for( b in list ){
				b.setPos(b.px,b.py-1);
				b.fall--;
				if(b.fall==0){
					work.remove(b);
				}else{
					b.removeFromGrid();
				}
			}
		}
		for( b in work ){
			b.display(b.px,b.py-coef);
		}


		if( work.length == 0 ){
			checkCombo();
		}


	}
	function buildFallList(){
		work = new mt.flash.PArray();
		var ymax = Cs.YMAX;

		for( x in 0...Cs.XMAX ){
			if( grid[x][Cs.YMAX]!=null ){
				var fall = 0;
				for( y in 0...ymax ){
					var ball = grid[x][y];
					if(fall>0 ){
						if(ball!=null){
							ball.fall = fall;
							work.push(ball);
							ball.removeFromGrid();
						}else {
							fall++;
							if(y>=Cs.YMAX)break;
						}
					}else if( ball == null ) {
						fall = 1;
					}
				}
			}
		}
	}

	// GROW
	public function initGrow(){
		cleanColors();
		step = Grow;
		action = updateGrow;
		coef = 0;
	}
	public function updateGrow(){
		coef = Math.min(coef+0.1,1);
		for( b in work ){
			b.setVisible(true);
			b.root._xscale = b.root._yscale = coef*100;
			b.mcShade._xscale = b.mcShade._yscale = coef*100;
		}
		if(coef==1){
			setMiss(3);
			initPlay();
		}


	}

	// CLEAN
	function cleanColors(){
		// NEW
		work = new mt.flash.PArray();
		for( x in 0...Cs.XMAX ){
			var y = Cs.YMAX;
			while( true ){
				var b = grid[x][y];
				if(b==null)break;
				work.push(b);
				y++;
			}
		}

		// NEW GRID
		var ngrid = [];
		for( x in 0...Cs.XMAX ){
			var a  = grid[x].copy();
			while( a.length > Cs.YMAX )a.remove(null);
			ngrid[x] = a;
			for( y in 0...Cs.YMAX*2 ){
				var b = ngrid[x][y];
				b.removeFromGrid();
				//b.savePos();
				b.px = x;
				b.py = y;
				b.insertInGrid();
			}
		}

		var to = 0;
		while( true ){
			for( b in work )b.setColor();
			if(checkFuturCombo(ngrid)==0)break;
			if(to++>100){
				trace("COLOR TIMEOUT");
				break;
			}
		}


		//for( b in balls )b.loadPos();
		for( b in balls ){
			b.display(b.px,b.py);

		}
	}
	function checkFuturCombo(ngrid){

		//
		var n = 0;
		// GROUPS
		var flag = false;
		var list = getGroups(ngrid);
		for( a in list ){
			if(a.length>=Cs.COMBO_LIMIT){
				n+=a.length;
			}
		}



		return n;



	}

	// LEVEL UP
	function levelUp(){

		lvl++;
		switch(lvl){
			case 3 :	Cs.COLOR_MAX++;
			case 7 :	Cs.COLOR_MAX++;
			case 12 :	Cs.COLOR_MAX++;
			case 20 :	Cs.COLOR_MAX++;
			case 30 :	Cs.COLOR_MAX++;
			case 45 :	Cs.COLOR_MAX++;
		}

	}

	// GAMEOVER
	function initGameOver(){
		step = GameOver;
		action = updateGameOver;

		KKApi.gameOver({});

	}
	function updateGameOver(){

	}

	// INTER
	function initInter(){
		missList = new mt.flash.PArray();
		var max = 3;
		for( i in 0...max ){
			var mc = Game.me.dm.attach("mcTurn",Game.DP_FG);
			mc._x = 16;//Cs.mcw*0.5 + ((i/(max-1))*2-1)*36;
			mc._y = 220+i*28;
			mc.gotoAndStop(2);
			missList.push(mc);
		}
	}
	function setMiss(n){
		if(missList.cheat)KKApi.flagCheater();
		miss = n;
		var id = 0;
		for( mc in missList ){
			if( miss>id ){
				mc.gotoAndStop(2);
			}else{
				mc.gotoAndStop(1);
			}
			id++;
		}


	}

	//
	function fxScore(x,y,n,?col){
		//return;
		var p = new mt.bumdum.Phys(Game.me.dm.attach("partScore",DP_SCORE));
		p.x = x;
		p.y = y;
		var field:flash.TextField = cast(p.root.smc).field;
		field.text = Std.string(n);
		p.weight = -(0.2+Math.random()*0.1);
		p.vy = 2;
		p.timer = 25;
		//p.fadeType = 0;
		p.sleep = Math.random()*2;
		p.root.stop();
		p.updatePos();
		if(col!=null){
			//Filt.glow(p.root,1,2,0);
			Filt.glow(p.root,4,4,col);
		}
	}


	// CODE
	// EXE-CUTE
	// CPU
	// BINARI
	// BINAIRE
	// BINAREA
	// OCTET
	// SABOTAGE

	// Flame'n'code
	// ILLI-CODE



//{
}























