import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Part;
import mt.bumdum.Lib;
import mt.bumdum.Plasma;

enum Step {
	Play;
	Move;
	Combo(a:Array<Ball>,nlist:Array<Ball>);
	Fill;
	GameOver;
}

typedef GROUP = {id:Int};


class Game {//}


	public static var FL_DEBUG = true;
	public static var MODE = 0;


	public static var DP_BG = 	0;
	public static var DP_SHADE = 	1;
	public static var DP_PLASMA = 	3;
	public static var DP_LINE = 	4;
	public static var DP_BALLS = 	5;
	public static var DP_PARTS = 	7;
	public static var DP_POOL = 	10;
	public static var DP_INTER = 	11;

	public var flForceDeath:Bool;

	public var mult:mt.flash.Volatile<Int>;
	public var colorMax:mt.flash.Volatile<Int>;
	public var toFill:mt.flash.Volatile<Int>;
	public var pool:mt.flash.Volatile<Int>;
	public var ghost:Int;
	public var tcoef:mt.flash.Volatile<Float>;
	public var cycle:mt.flash.Volatile<Float>;
	public var dif:mt.flash.Volatile<Float>;
	public var lck:mt.flash.Volatile<Float>;
	public var rcoef:mt.flash.Volatile<Float>;
	public var nextTimer:mt.flash.Volatile<Float>;
	public var circleDecal:mt.flash.Volatile<Float>;
	public var toScore:KKConst;

	public var balls:Array<Ball>;
	public var bcount:mt.flash.Volatile<Int>;
	public var selection:Array<Ball>;
	public var miniballs:Array<flash.MovieClip>;
	public var mcLine:flash.MovieClip;
	public var mcMult:{>flash.MovieClip, base:{>flash.MovieClip, field:flash.TextField} };
	public var mcScore:{>flash.MovieClip, field:flash.TextField };
	public var plasma:Plasma;

	public var step:Step;
	public var dm:mt.DepthManager;
	public var sdm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:{>flash.MovieClip,chrono:flash.MovieClip,but:flash.MovieClip,field:flash.TextField};
	public var stats:{a:Array<Array<Int>>,lck:Int};
	static public var me:Game;


	public function new( mc : flash.MovieClip ){

		// haxe.Log.setColor(0xFFFFFF);

		root = mc;
		me = this;
		dm = new mt.DepthManager(root);
		bg = cast dm.attach("mcBg",DP_BG);
		bg.cacheAsBitmap = true;

		var mcShade = dm.empty(DP_SHADE);
		sdm = new mt.DepthManager(mcShade);
		mcShade.blendMode = "layer";
		mcShade._alpha = 50;

		circleDecal = 0;
		pool = 0;
		colorMax = 3;
		dif = 0;
		cycle = 50;
		nextTimer = 2000;
		lck = Math.pow( Math.random(),0.5);



		stats = {a:[],lck:Std.int(lck*100)};

		miniballs = [];

		initBalls();
		initPlay();
		//
		initKeyListener();
		initPlasma();

	}

	function initPlasma(){
		plasma = new Plasma(dm.empty(20),Cs.mcw,Cs.mch,0.5);
		var fl = new flash.filters.BlurFilter();
		fl.blurX = 4;
		fl.blurY = 4;
		plasma.filters.push(fl);
		plasma.ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,-15);

		plasma.root.blendMode = "add";

	}

	// UPDATE
	public function update(){

		mt.Timer.tmod /= 2; // GAME WAS BUILT WITH 2 CALLS TO mt.Timer.update

		// haxe.Log.clear();
		/*
		trace("balls: "+balls.length);
		trace("selection: "+selection.length);
		trace("miniballs: "+miniballs.length);
		trace("sprites: "+Sprite.spriteList.length);
		*/
		var a:Array<flash.MovieClip> = untyped KKApi.loader.buttons;
		// trace(a.length);


		/*
		haxe.Log.clear();
		trace(pool);
		*/

		if(flForceDeath)step = GameOver;


		/*
		var st = flash.Lib.getTimer();
		while(flash.Lib.getTimer()-st<80){

		}
		*/


		switch(step){
			case Fill : updateFill();
			case Play : updatePlay(); updateDif();
			case Move : updateDif();
			case Combo(list,nlist): updateCombo(list,nlist);
			case GameOver : updateGameOver();
			default:
		}


		/*
		for( p in Sprite.spriteList ){
			var mc = cast p;
			if(mc.vr!=null)plasma.drawMc(p.root);
		}
		*/

		plasma.update();
		updateBalls();
		updateSprites();

		if(bcount!=balls.length)KKApi.flagCheater();

	}
	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}

	// BALLS
	function initBalls(){
		balls = [];
		bcount = 0;
		for( i in 0...16 )newBall();
	}
	function newBall(){


		var ball = new Ball();
		ball.x = Cs.mcw*0.5;
		ball.y = Cs.mch*0.5;
		ball.flMove = true;

		var id = Std.random(getBallsLength()+1);
		var prev = null;
		var next = null;


		if(Math.random()>lck){
			var to = 0;
			while(true && getBallsLength()>4){
				id = Std.random(getBallsLength()+1);
				prev = getBall(id,-1);
				next = getBall(id,0);
				if(prev.col!=next.col){
					break;
				}
				if(to++>100){
					trace("yahoo!"+getBallsLength());
					break;
				}
			}
		}


		// COL
		if( getBallsLength()>=3){
			if(prev==null){
				next = getBall(id,-1);
				prev = getBall(id,0);
			}

			var cols = [];
			for( n in 0...colorMax )cols.push(n);
			if(prev.group>2)cols.remove(prev.col);
			if(next.group>2)cols.remove(next.col);
			if( prev.col == next.col && prev.group+next.group > 2 ) cols.remove(next.col);
			ball.setSkin( cols[Std.random(cols.length)] );
		}else{
			ball.setSkin( Std.random(colorMax) );
		}

		// INSERT_BALL
		Game.me.balls.insert(id,ball);
		bcount++;




		// START POS
		var a = id/getBallsLength() * 6.28;
		ball.x += Math.cos(a)*200;
		ball.y += Math.sin(a)*200;

		//
		if(getBallsLength()>=4)buildGroups();

	}
	function updateBalls(){

		var max = getBallsLength();
		var circ = max*2*Cs.BRAY;
		var ray = circ/6.28;

		for( i in 0...max ){
			var ball = balls[i];


			var a = 6.28*(i+circleDecal)/max;
			ball.tx = Cs.mcw*0.5 + Math.cos(a)*ray;
			ball.ty = Cs.mch*0.5 + Math.sin(a)*ray;



		}

		/*
		if( ray>132 ){
			initGameOver();
		}
		*/

		if( ray>20 ){
			/*
			if(rcoef==null)rcoef=0;
			rcoef = (rcoef+0.01*mt.Timer.tmod)%1;
			Col.setPercentColor(bg.smc,100,Col.objToCol( Col.getRainbow(rcoef)));
			*/
		}else{
			if(rcoef!=null){
				rcoef=null;
				Col.setPercentColor(bg.smc,0,0);
			}
		}

	}

	// SELECTION
	public function select(ball){
		ballOut();

		var id = getBallId(ball);
		var max = getBallsLength();
		var id2 = (id+Math.ceil(max*0.5))%max;
		ball.flMove = true;




		switch(MODE){
			case 0:
				balls.splice(id,1);
				if(id2>id)id2--;
				// INSERT_BALL
				balls.insert(id2,ball);
			case 1:
				var ball2 = balls[id2];
				balls[id] = ball2;
				balls[id2] = ball;
				ball2.flMove = true;
		}

		//
		step = Move;
		for(b in balls )b.deactivate();

		//
		circleDecal = id2/max;
		incPool(1);
	}
	public function ballOver(ball){
		//ghost = Std.int( Num.sMod( getBallId(ball) + Std.int(getBallsLength()*0.5), getBallsLength() ) ) ;
		//ghost = getBallId(ball);
		selection = [ ball ];

		switch(MODE){
			case 0:
			case 1:
				var max = getBallsLength();
				var id2 = (getBallId(ball)+Std.int(max*0.5))%max;
				var ball2 = balls[id2];
				selection.push(ball2);
		}




		for( b in selection ){
			dm.over(b.root);
			Filt.glow(b.root,8,2,0xFFFFFF,true);
			Filt.glow(b.root,2,4,0xFFFFFF);
		}

		ghost = getBallId(ball);


	}
	public function ballOut(){

		ghost = null;
		mcLine.removeMovieClip();
		mcLine = null;

		for( b in selection ){
			b.root.filters = [];
		}
		/*
		ghost = null;
		mcLine.removeMovieClip();
		mcLine = null;
		*/
	}

	// COMBO
	public function buildGroups(){


		for( b in balls )b.group = 1;
		if(getBallsLength()<=1)return;

		var i = 0;
		var col = null;
		var a = [];
		var to = 0;
		while(true){
			var id = i%getBallsLength();
			var ball = balls[id];
			if( ball.col != col ){
				/*
				if( a.length >= Cs.COMBO_LIMIT ){
					for( b in a )list.push(b);
				}else{
					if( i!=id )break;
				}
				*/

				a = [ball];
				col = ball.col;
				if( i!=id )break;


			}else{

				for( b in a ){
					if(b==ball)break;
					b.group++;
				}
				a.push(ball);
				ball.group = a[0].group;
			}
			i++;

			if(to++>200){
				// HAPPEN
				//trace("buildCombo Error !["+getBallsLength()+"]");
				return;
			}
		}

	}
	public function checkCombo(){

		//groups = [];

		if(getBallsLength()<4){
			initTurn();
			return;
		}

		buildGroups();

		var list = [];
		for( b in balls ){
			if(b.group>=Cs.COMBO_LIMIT)list.push(b);
		}


		if(list.length>0){
			nextTimer = cycle;
			step = Combo(list,[]);
			tcoef = 0;
			toScore = KKApi.cmult( KKApi.const(list.length), Cs.SCORE_BALL );
			toScore = KKApi.cadd(toScore,KKApi.cmult( KKApi.const(list.length-Cs.COMBO_LIMIT), Cs.SCORE_BALL_SUP ));
			toScore = KKApi.cmult( toScore, KKApi.const(mult) );
			//stats.a.push( [list.length,mult] ); //OVERFLOW
			mult++;
		}else{
			mult = 1;
			initTurn();
		}


	}
	public function updateCombo(list:Array<Ball>,nlist:Array<Ball>){

		tcoef = Math.min(tcoef+0.2*mt.Timer.tmod,1);
		if(tcoef<1){
			for( ball in list ){
				Col.setPercentColor(ball.root,tcoef*100,0xFFFFFF);

				ball.root.filters = [];
				var c = Math.pow(tcoef,2);
				Filt.glow(ball.root,c*30,c,0xFFFFFF);

				plasma.drawMc(ball.root);
				//
				/*
				var p = new Ray(dm.attach("mcRay",DP_PARTS));
				p.x = ball.x;
				p.y = ball.y;
				//p.vr = (Math.random()*2-1)*2;
				p.fr = 0.98;
				p.timer = 10;
				p.root._rotation = Math.random()*360;
				p.root._xscale = 10+Math.random()*50;
				p.root._yscale = Math.random()*40;
				*/


			}
		}else{
			/*
			var a = Sprite.spriteList.copy();
			for( sp in a ){
				var p = cast sp;
				if(p.vys!=null)	p.kill();
			}
			*/

			for( ball in list ){
				// REMOVE_BALL
				balls.remove(ball);
				ball.explode();
				bcount--;
			}
			//for( ball in balls )ball.flMove = true;

			KKApi.addScore(toScore);
			displayScore();
			checkCombo();
		}
	}

	// TURN
	public function initTurn(){

		var ballMin = colorMax*4 - 1;
		//pool += 5;
		if( getBallsLength()<ballMin || pool>=Cs.POOL_LIMIT ){
			emptyPool();
			var dif = ballMin-(getBallsLength()+toFill);
			if( dif > 0 ) toFill += dif;
		}else{
			initPlay();
		}
	}
	public function updateFill(){
		tcoef += 0.5*mt.Timer.tmod;
		while(tcoef>=1){
			tcoef--;
			newBall();
			toFill--;
			miniballs.pop().removeMovieClip();

			var circ = getBallsLength()*2*Cs.BRAY;
			var ray = circ/6.28;
			if( ray > 132 ){
				initGameOver();
			}else if(toFill==0){
				initPlay();
			}
		}
	}

	// PLAY
	function initPlay(){
		mult = 1 ;
		for(b in balls )b.activate();
		step = Play;
	}
	function updatePlay(){
		if( nextTimer<=0 ){
			incPool(1);
			if( pool>=Cs.POOL_LIMIT )emptyPool();
			nextTimer += cycle;
		};
	}

	function incPool(inc){
		/*
		for( n in pool...pool+inc ){
			var mc = dm.attach("mcMiniBall",DP_POOL);
			mc._x = 6+n*10;
			mc._y = 6;
			miniballs.push(mc);
		}
		*/

		pool+=inc;

	}
	function emptyPool(){
		tcoef = 0;
		step = Fill;
		toFill = pool;
		pool = 0;
	}

	// GAMEOVER
	function initGameOver(){
		step = GameOver;
		for( b in balls ) untyped b.update = null;
		flForceDeath = true;
	}
	function updateGameOver(){
		if(getBallsLength()>0){
			balls.pop().explode();
			bcount--;
		}else{
			KKApi.gameOver(stats);
			step  = null;
		}
	}

	// DIFFICULTE
	function updateDif(){
		nextTimer-=mt.Timer.tmod;
		dif += mt.Timer.tmod;
		cycle -= mt.Timer.tmod*0.013;

		if( dif*0.05 > Math.pow(colorMax,3) && colorMax<7 ){
			colorMax++;
		}

	}

	// FX
	function displayMult(){
		if(mcMult._visible)mcMult.removeMovieClip();
		mcMult = cast dm.attach("mcMult",DP_INTER);
		mcMult._x = Cs.mcw*0.5;
		mcMult._y = Cs.mch*0.5;
		mcMult.base.field.text = "x"+mult;
	}
	function displayScore(){
		if(mcScore._visible)mcScore.removeMovieClip();
		mcScore = cast dm.attach("mcScore",DP_INTER);
		mcScore._x = Cs.mcw;
		mcScore._y = Cs.mch;
		var str = "+"+KKApi.val(toScore)/(mult-1);
		if(mult>2) str+= " x"+(mult-1);
		mcScore.field.text = str;
		var p = new Part(mcScore);
		p.timer = 16;
		p.fadeLimit =4;

	}

	//
	function getBall(id,inc){
		return balls[ Std.int( Num.sMod(id+inc,getBallsLength()) ) ];
	}
	function getBallId(ball){
		var id = 0;
		for(b in balls){
			if(b==ball)return id;
			id++;
		}
		return null;
	}

	// DEBUG
	function initKeyListener(){
		var kl = {};
		Reflect.setField(kl,"onKeyDown",pressKey);
		Reflect.setField(kl,"onKeyUp",releaseKey);
		flash.Key.addListener(cast kl);
	}
	function pressKey(){
		var n = flash.Key.getCode();
		if(FL_DEBUG){
			var al = 65;
			if( n == flash.Key.ENTER ){

			}
		}

	}
	function releaseKey(){
		var n = flash.Key.getCode();

	}



	function getBallsLength(){
		//return 10+Std.random(10);
		return balls.length;
	}

//{
}



























