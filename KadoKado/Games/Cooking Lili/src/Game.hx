import KKApi;
import mt.Timer;
import mt.bumdum.Plasma;
import mt.flash.Volatile;

import Level;
import Girl;

enum Step {
	Play;
	Resolve;
	GameOver;
}

typedef T_ScoreMC = {
	> flash.MovieClip,
	field	: flash.TextField,
	timer	: Float,
}

typedef T_Swap = {
	pair	: T_Pair,
	step	: Float,
}

typedef T_LogTurn = {
	t	: Float,
	dp	: Int,
	sc	: Int,
}


class Game {
	public static var FALL_SPEED		= 8;
	public static var RAISE_SPEED		= 12;
	public static var FALL_DELAY		= 9;

	public var step			: Step;
	public var dm			: mt.DepthManager;
	public var fxDm			: mt.DepthManager;
	public var level		: Level;
	var swapPair			: T_Pair;

	public var root			: flash.MovieClip;
	public var swapper		: flash.MovieClip;
	var falls				: Volatile<Int>;
	var explList			: Array<Token>;
	var unarmList			: Array<Token>;
	var warnings			: Array<Token>;
	var warnStep			: Float;
	var raiseCpt			: Volatile<Int>;
	public var girl			: Girl;

//	var sparkList			: Array<Spark>;
//	var iceList				: Array<Ice>;
	public var fxList		: Array<Fx>;
	var shortFxList			: Array<flash.MovieClip>;
	var scoreList			: Array<T_ScoreMC>;
	var swapAnim			: T_Swap;
	var lastPair			: T_Pair;
	var goStep				: Volatile<Float>;
	var explTimer			: Float;

	var plasma				: Plasma;
	var fxMc				: flash.MovieClip;

	var upTimer				: Volatile<Float>;

	var log					: List<T_LogTurn>;
	var currentRound		: T_LogTurn;
	var time				: Volatile<Float>;

	static public var me	: Game;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	public function new( mc : flash.MovieClip ){
		haxe.Log.setColor(0xffffff);
		if ( haxe.Firebug.detect() )
			haxe.Firebug.redirectTraces();

		root = mc;
		me = this;
		fxList = new Array();
		shortFxList = new Array();
		scoreList = new Array();
		upTimer = 0;
		dm = new mt.DepthManager(root);
		var bg = dm.attach("bg",Const.DP_BG);
		bg.gotoAndStop( Std.random(bg._totalframes) );
		log = new List();
		time = 0;

		plasma = new Plasma(dm.empty(Const.DP_PLASMA),Const.GWID,Const.GHEI);
		plasma.filters.push( new flash.filters.BlurFilter(5,7) );
		plasma.ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,-4);
		plasma.root.blendMode = "add";
		fxMc = dm.empty(Const.DP_FX);
		fxDm = new mt.DepthManager(fxMc);

		step = Play;


		girl = new Girl(this);

		swapper = dm.attach("swapper",Const.DP_INTERF);
		swapper._xscale = 100*(Const.TWID*2)/40;
		swapper._yscale = 100*(Const.THEI)/20;
		//      1
		// 50   40

		// generation
		level = new Level();
		for (x in 0...level.map.length) {
			var col = level.map[x];
			for (y in 0...col.length)
				col[y].attach(x,y);
		}

//		level.initSolver(); // HACK

		root.onMouseDown = onClick;
	}


	/*------------------------------------------------------------------------
	ADD SCORE
	------------------------------------------------------------------------*/
	public function addScore(sc:KKConst,x,y) {
		currentRound.sc+=KKApi.val(sc);
		KKApi.addScore(sc);
		var mc : T_ScoreMC = cast dm.attach("score",Const.DP_INTERF);
		mc._x = x;
		mc._y = y;
		mc.field.text = ""+KKApi.val(sc);
		mc.field.filters = [ new flash.filters.GlowFilter(0x0,1, 3,3,3) ];
		mc.timer = 0;
//		mc._x = Const.GWID*0.5;
//		mc._y = Const.GHEI*0.5;
//		mc._xscale = 800;
//		mc._yscale = mc._xscale;
//		mc.blendMode = "overlay";
		scoreList.push(mc);
	}


	/*------------------------------------------------------------------------
	EVENT: CLICK
	------------------------------------------------------------------------*/
	function onClick() {
		if ( step!=Play )
			return;

		swapPair = getPair();
		if ( swapPair!=null && level.different(swapPair) ) {
			girl.startSwap(swapPair, callback(onSwapAnim));
			step = Resolve;
			currentRound = {
				t	: time,
				dp	: 0,
				sc	: 0,
			}
		}
	}

	function onSwapAnim() {
		redraw();
		clearWarnings();
		explTimer = 0;
		level.swap(swapPair);
		swapAnim = { pair:swapPair, step:0.0 };
	}


	/*------------------------------------------------------------------------
	GETS THE PAIR UNDER MOUSE
	------------------------------------------------------------------------*/
	function getPair() {
		var x = Level.x_rtc(root._xmouse);
		var y = Level.y_rtc(root._ymouse);
		var dx = 0;
		var dy = 0;
		var xCenter = Level.x_ctr( x ) + Const.TWID*0.5;
		var yCenter = Level.y_ctr( y ) + Const.THEI*0.5;
		var ang = Math.atan2( yCenter-root._ymouse, xCenter-root._xmouse )*180 / Math.PI;
		if ( ang<0 ) {
			ang+=360;
		}
		if ( ang<=45 || ang>315 ) {
			// left
			dx = 1;
			x--;
		}
		else if ( ang<=135 ) {
			// up
			dy = 1;
			y--;
		}
		else if ( ang<=225 ) {
			// right
			dx = 1;
		}
		else if ( ang<=315 ) {
			// down
			dy = 1;
		}
		return level.getPair(x,y,dx,dy);
	}



	/*------------------------------------------------------------------------
	CHECKS BEFORE END OF ROUND
	------------------------------------------------------------------------*/
	function check() {
		var l = level.check(true);
		if ( l!=null ) {
			currentRound.dp++;
			var lists = level.explode(l);
			explList = lists.explNow;
			unarmList = lists.explArm;
			for (token in unarmList) {
				for (i in 0...Std.random(4)+2) {
					var ice = new Ice( this, token.mc._x+Const.TWID*0.5, token.mc._y+Const.THEI*0.5 );
					token.mc.ice._visible = false;
					var fx = dm.attach("fx_ice_break",Const.DP_FX);
					fx._x = token.mc._x;
					fx._y = token.mc._y;
					fx.smc.smc._rotation = token.mc.ice._rotation;
					shortFxList.push(fx);
					fxList.push(ice);
				}
			}
		}
		else {
			endRound();
		}
	}

	/*------------------------------------------------------------------------
	FX: SPARK
	------------------------------------------------------------------------*/
	function addSpark(x:Float,y:Float,id) {
		var s = new Spark(
			this,
			fxDm,
			x + Std.random(Const.TWID) * (Std.random(2)*2-1),
			y + Std.random(Const.THEI) * (Std.random(2)*2-1),
			id
		);
		fxList.push(s);
	}


	/*------------------------------------------------------------------------
	STOPS WARNING ANIMATION
	------------------------------------------------------------------------*/
	function clearWarnings() {
		for (w in warnings) {
			w.mc._x = Level.x_ctr(w.x);
			w.mc._y = Level.y_ctr(w.y);
			w.mc.filters = [];
		}
		warnings = new Array();
	}


	/*------------------------------------------------------------------------
	FULL REDRAW
	------------------------------------------------------------------------*/
	function redraw() {
		for (y in 0...Level.HEI) {
			for (x in 0...Level.WID) {
				var t = level.map[x][y];
				t.mc._y = Level.y_ctr(t.y);
				t.mc._y = Level.y_ctr(t.y);
			}
		}
	}


	// *** GAME EVENTS

	/*------------------------------------------------------------------------
	EVENT: END OF EXPLOSIONS
	------------------------------------------------------------------------*/
	function onEndSwap() {
		check();
	}

	/*------------------------------------------------------------------------
	EVENT: END OF EXPLOSIONS
	------------------------------------------------------------------------*/
	function onEndExplosion() {
		falls = level.gravity();
		if ( falls==0 )
			check();
	}


	/*------------------------------------------------------------------------
	EVENT: END OF FALLS
	------------------------------------------------------------------------*/
	function onFelt() {
		for (x in 0...Level.WID) {
			for (y in 0...Level.HEI) {
				var t=level.map[x][y];
				if (t!=null) {
					if ( t.mc._x != Level.x_ctr(x) || t.mc._y != Level.y_ctr(y) ) {
						trace("invalid pos for token @ "+x+","+y+" !");
						t.mc._alpha = 35;
					}
					if ( t.fall!=0 )
						trace("invalid fall value for token @ "+x+","+y+" !");
				}
			}
		}
		check();
	}

	/*------------------------------------------------------------------------
	EVENT: LINE COMPLETLY ADDED
	------------------------------------------------------------------------*/
	function onLineAdded() {
		warnings = level.getWarnings();
		warnStep = 0;
		step = Play;
	}

	/*------------------------------------------------------------------------
	EVENT: DEATH !
	------------------------------------------------------------------------*/
	function onGameOver() {
		goStep = 0;
		/***
		// HACK
		for (i in 0...300)
			log.add({
				t	: Std.random(10)*1.0,
				dp	: Std.random(4)+1,
				sc	: Std.random(9999),
			});
		/***/
		//var scores = new Array();
		//var times = new Array();
		//var depths = new Array();
		//var limit = 70;
		//for(l in log) {
			//scores.push(l.sc);
			//depths.push(l.dp);
			//times.push(Std.int(l.t));
			//if ( --limit<=0 )
				//break;
		//}
//
		//KKApi.gameOver( {cpt:log.length, sc:scores, dp:depths, t:times} );
		KKApi.gameOver(new Array());
		step = GameOver;
	}


	/*------------------------------------------------------------------------
	END OF A ROUND (AFTER RESOLVE)
	------------------------------------------------------------------------*/
	function endRound() {
		upTimer = 0;
		step = Resolve;
		currentRound.t = time-currentRound.t;
		log.add(currentRound);
		if ( !level.addLine() ) {
			onGameOver();
			return;
		}
		level.endRound();
		raiseCpt = Level.WID;
		for (x in 0...Level.WID) {
			var t = level.map[x][Level.HEI-1];
			t.attach( x, Level.HEI-1 );
			t.mc._y+=Const.THEI;
		}


//		level.initSolver();
	}


	// *** UPDATES

	/*------------------------------------------------------------------------
	MAIN LOOPS
	------------------------------------------------------------------------*/
	public function update() {
		time+=Timer.deltaT;
		if ( lastPair!=null ) {
			lastPair.t1.mc.filters = [];
			lastPair.t2.mc.filters = [];
			lastPair = null;
		}
		switch(step){
			case Play		: updateGame();
			case Resolve	: updateResolve();
			case GameOver	: updateGameOver();
			default:
				trace("unknown step");
		}
		updateFx();
	}


	/*------------------------------------------------------------------------
	FX LOOP
	------------------------------------------------------------------------*/
	function updateFx() {
		// plasma!
		plasma.drawMc(fxMc);
		plasma.update();

		// warnings
		warnStep+=0.2 * Timer.tmod;
		for (w in warnings) {
			w.mc._x = Level.x_ctr(w.x) + Std.random(10)/10 * (Std.random(2)*2-1);
			w.mc._y = Level.y_ctr(w.y) + Std.random(10)/10 * (Std.random(2)*2-1);
			w.mc.filters = [ new flash.filters.GlowFilter( 0xff0000, Math.abs(Math.cos(warnStep)), 4,4, 3 ) ];
		}

		// score pops
		var i=0;
		while (i<scoreList.length) {
			var sc = scoreList[i];
			sc.timer+=0.05*Timer.tmod;
			sc._alpha = Math.cos(Math.PI*0.5*sc.timer)*100;
			sc._y -= 0.5*Timer.tmod;
			if ( sc.timer>=1 ) {
				sc.removeMovieClip();
				scoreList.splice(i,1);
				i--;
			}
			i++;
		}

		// sparks
		var i=0;
		while (i<fxList.length) {
			var fx = fxList[i];
			fx.update();
			if ( fx.mc==null ) {
				fxList.splice(i,1);
				i--;
			}
			i++;
		}

		// ice
//		i=0;
//		while (i<iceList.length) {
//			var ice = iceList[i];
//			ice.update();
//			if (ice.mc._y>=Const.GHEI+5 ) {
//				ice.mc.removeMovieClip();
//				iceList.splice(i,1);
//				i--;
//			}
//			i++;
//		}


		// clean up
		i=0;
		while(i<shortFxList.length) {
			var mc = shortFxList[i];
			if ( mc._currentframe==mc._totalframes ) {
				mc.removeMovieClip();
				shortFxList.splice(i,1);
				i--;
			}
			i++;
		}
	}


	/*------------------------------------------------------------------------
	GAMEOVER LOOP
	------------------------------------------------------------------------*/
	function updateGameOver() {
		swapper._visible = false;
		var fact = 1-Math.cos(goStep);
		for(y in 0...Level.HEI) {
			if ( y/Level.HEI<=fact ) {
				for(x in 0...Level.WID) {
					var token = level.map[x][y];
					if ( token!=null ) {
						token.mc._x -= Timer.tmod*(1.5+Std.random(3));
						token.mc._rotation -= Timer.tmod*5;
						if ( x%3==0 || (x+y)%3==0 ) {
							token.mc._y -= Timer.tmod*1;
							token.mc._rotation -= Timer.tmod*2;
						}
						if ( (x+y)%6==0 ) {
							token.mc._x -= Timer.tmod*Std.random(4);
						}
						token.mc._alpha -=Timer.tmod*(2+Std.random(6));
						if ( token.mc._alpha<=0 ) {
							token.mc.removeMovieClip();
							level.map[x][y] = null;
						}
					}
				}
			}
		}
		goStep+=0.05*Timer.tmod;

		girl.update();
	}


	function updateResolve() {
		swapper._visible = false;

		// swapping
		if ( swapAnim!=null ) {
			swapAnim.step+=Timer.tmod*0.1;
			if ( swapAnim.step>=1 ) {
				swapAnim.step = 1;
			}
			swapAnim.pair.t1.mc._x = Level.x_ctr(swapAnim.pair.x) + swapAnim.pair.dx*Const.TWID*swapAnim.step;
			swapAnim.pair.t1.mc._y = Level.y_ctr(swapAnim.pair.y) + swapAnim.pair.dy*Const.THEI*swapAnim.step;
			swapAnim.pair.t1.mc._xscale = 100 + 50*Math.sin(swapAnim.step*Math.PI);
			swapAnim.pair.t1.mc._yscale = swapAnim.pair.t1.mc._xscale;
			swapAnim.pair.t1.mc._x -= 4*Math.sin(swapAnim.step*Math.PI);
			swapAnim.pair.t1.mc._y -= 4*Math.sin(swapAnim.step*Math.PI);
			dm.over(swapAnim.pair.t1.mc);

			swapAnim.pair.t2.mc._x = Level.x_ctr(swapAnim.pair.x)+swapAnim.pair.dx*Const.TWID - swapAnim.pair.dx*Const.TWID*swapAnim.step;
			swapAnim.pair.t2.mc._y = Level.y_ctr(swapAnim.pair.y)+swapAnim.pair.dy*Const.THEI - swapAnim.pair.dy*Const.THEI*swapAnim.step;
			swapAnim.pair.t2.mc._xscale = 100 - 50*Math.sin(swapAnim.step*Math.PI);
			swapAnim.pair.t2.mc._yscale = swapAnim.pair.t2.mc._xscale;
			swapAnim.pair.t2.mc._x += 4*Math.sin(swapAnim.step*Math.PI);
			swapAnim.pair.t2.mc._y += 4*Math.sin(swapAnim.step*Math.PI);

			if ( swapAnim.step>=1 ) {
				swapAnim = null;
				onEndSwap();
			}
		}


		// explosions
		if ( explTimer>0 || explList.length>0 ) {
			var i=0;
			while (i<explList.length) {
				var token = explList[i];
				var bx = Std.random(5);
				var by = 5-bx;
				token.mc.filters = [ new flash.filters.GlowFilter(0xffffff,1, 10,10, 3,1, true), new flash.filters.GlowFilter(0xffffff,1, Std.random(15), Std.random(15),3 ) ];
//				token.mc._alpha = 50+Std.random(50);
				token.mc._x = Level.x_ctr(token.x) + (Std.random(20)/10) * (Std.random(2)*2-1);
				token.mc._y = Level.y_ctr(token.y) + (Std.random(20)/10) * (Std.random(2)*2-1);
				var chance = 4;
				if ( explList.length<=2 ) {
					chance = 2;
				}
				if ( Std.random(chance)==0 ) {
					var exp = fxDm.attach("fx_explode",Const.DP_FX);
					exp._x = token.mc._x+Const.TWID*0.5;
					exp._y = token.mc._y+Const.THEI*0.5;
					exp._xscale = 100 + Std.random(50);
					exp._yscale = exp._xscale;
					exp._rotation = Std.random(360);
					for (i in 0...1) {
						addSpark(exp._x,exp._y,token.id);
					}
					token.mc.removeMovieClip();
					explList.splice(i,1);
					shortFxList.push(exp);
					i--;
					if ( explList.length<=0 ) {
						explTimer = FALL_DELAY;
					}
				}
				i++;
			}
			if ( explTimer>0 ) {
				explTimer-=Timer.tmod;
				if ( explTimer<=0 ) {
					onEndExplosion();
				}
			}
		}

		// falls
		if ( falls>0 ) {
			for (x in 0...Level.WID) {
				for (y in 0...Level.HEI) {
					var token = level.map[x][y];
					if ( token.fall>0 ) {
						token.mc._y+=FALL_SPEED;
						token.moveDist+=FALL_SPEED;
						if ( token.moveDist>=Const.THEI ) { // felt from 1 token height
							token.fall--;
							token.moveDist -= Const.THEI;
							if ( token.fall<=0 ) {
								token.mc._y = Level.y_ctr(y);
								falls--;
							}
						}
					}
				}
			}
			// full redraw
			if ( falls==0 ) {
				onFelt();
			}
		}

		// line added
		if ( raiseCpt>0 ) {
			for (x in 0...Level.WID) {
				var d = 2 * ( Math.sin(Math.PI*x/Level.WID) + 1 );
				var fl_done = false;
				for (y in 0...Level.HEI) {
					var token = level.map[x][y];
					if ( token.mc._y>Level.y_ctr(token.y) ) {
						fl_done = false;
						token.mc._y-=d;
						token.moveDist+=d;
						if ( token.mc!=null && token.mc._y<=Level.y_ctr(token.y) ) {
							fl_done = true;
							token.attach(token.x,token.y);
						}
					}
				}
				if ( fl_done ) {
					raiseCpt--;
//					level.map[x][Level.HEI-1].attach(x,Level.HEI-1);
				}
			}
			if ( raiseCpt<=0 ) {
				onLineAdded();
			}
		}

		girl.update();
	}


	/*------------------------------------------------------------------------
	GAME LOOP
	------------------------------------------------------------------------*/
	function updateGame() {
//		level.updateSolver(); // hack

		// auto up
		var t = Math.min( 4, Math.max( Timer.tmod, 0.5 ) );
		upTimer+=t;
		if ( upTimer>=0.75*KKApi.val(Const.AUTOUP_TIMER) ) {
			for (col in level.map) {
				var t = col[Level.HEI-1];
				if ( t!=null ) {
					t.mc._y = Level.y_ctr(t.y) + Std.random(10)/10 * (Std.random(2)*2-1);
				}
				t = col[Level.HEI-2];
				if ( t!=null ) {
					t.mc._y = Level.y_ctr(t.y) + Std.random(6)/10 * (Std.random(2)*2-1);
				}
			}
		}
		if ( upTimer>=KKApi.val(Const.AUTOUP_TIMER) ) {
			redraw();
			endRound();
		}

		// cursor
		var p = getPair();
		if ( p==null ) {
			swapper._visible = false;
		}
		else {
			swapper._visible = true;
			swapper._x = Level.x_ctr(p.x);
			swapper._y = Level.y_ctr(p.y);
			if ( p.dx>0 ) {
				swapper._x += Const.TWID;
				swapper._y += Const.THEI*0.5;
				swapper._rotation = 0;
			}
			else {
				swapper._rotation = 90;
				swapper._x += Const.TWID*0.5;
				swapper._y += Const.THEI;
			}
			p.t1.mc.filters = [ new flash.filters.GlowFilter( 0xffffff,1, 7,7, 7 ) ];
			p.t2.mc.filters = [ new flash.filters.GlowFilter( 0xffffff,1, 7,7, 7 ) ];
			dm.over(p.t2.mc);
			dm.over(p.t1.mc);
		}
		lastPair = p;

		// girl
		girl.update();

		if( level.variety != level.cvariety ) KKApi.flagCheater();
		if( level.diff != level.cdiff ) KKApi.flagCheater();
	}

}
