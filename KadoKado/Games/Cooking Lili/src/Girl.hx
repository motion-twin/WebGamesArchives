import mt.Timer;
import Level;

enum Phase {
	Run;
	Stop;
	Break;
	Swap;
}

class Girl {
	static var BREAK_DIST		= 35; // 35
	static var BREAK_TIMER		= 25;
	static var MAX_SPEED		= 15;
	static var MIN_X			= 35+BREAK_DIST;
	static var MAX_X			= Const.GWID-MIN_X;
	static var SWAP_EVENT		= 2; // frame id for swap callback
	static var SWAP_EVENT_FX	= 6; // frame id for swap fx

	var game				: Game;
	var shadow				: flash.MovieClip;
	public var mc			: flash.MovieClip;
	var actMC				: flash.MovieClip;
	var dx					: Float;
	var tx					: Float;
	var delay				: Float;
	var breakTimer			: Float;
	public var onSwapCB		: Void->Void;
	public var phase		: Phase;
	public var swap			: T_Pair;
	public var shineCpt		: Int;
	public var glowStep		: Float;
	var baseGlow			: flash.filters.GlowFilter;

	var swapTimeout			: Float;


	/*------------------------------------------------------------------------
	CONSTRUCTOR
	------------------------------------------------------------------------*/
	public function new(g) {
		game = g;
		delay = 0;
		shadow = game.dm.attach("girlShadow",Const.DP_GIRL);
		mc = game.dm.attach("girl",Const.DP_GIRL);
		mc._y = 60;
		mc._x = Const.GWID*0.5;
		mc.stop();
		baseGlow = new flash.filters.GlowFilter(0x8B072F,1, 2,2,10);
		mc.filters = [baseGlow];
		breakTimer = 0;
		dx = 0;
		phase = Stop;
		glowStep = 0;
	}


	/*------------------------------------------------------------------------
	STARTS SWAP ANIM
	------------------------------------------------------------------------*/
	public function startSwap(p,cb) {
		swapTimeout = 60;
		phase = Swap;
		swap = p;
		onSwapCB = cb;
		actMC.removeMovieClip();
		var id = if(p.dx==0) 1 else 2;
		actMC = game.dm.attach("fx_action_"+id,Const.DP_GIRL);
		actMC._x = mc._x;
		actMC._y = mc._y;
		actMC._xscale = mc._xscale;
	}


	function onSwap() {
		swapTimeout = 0;
		onSwapCB();
	}


	/*------------------------------------------------------------------------
	MAIN LOOP
	------------------------------------------------------------------------*/
	public function update() {
		// extra swap fx overlay
		if ( actMC!=null ) {
			actMC._x = mc._x;
			actMC._y = mc._y;
			actMC._xscale = mc._xscale;
			if ( actMC._currentframe==actMC._totalframes ) {
				actMC.removeMovieClip();
				actMC = null;
			}
		}

		// glow when receiving a spark
		if ( glowStep>0 ) {
			glowStep-=Timer.tmod*0.1;
			if ( glowStep<=0 ) {
				mc.filters = [baseGlow];
			}
			else {
				mc.filters = [
					new flash.filters.GlowFilter(0xffffff,glowStep, Std.random(5)+1,Std.random(5)+1, 6),
					baseGlow
				];
				var fx = new ShineDrop(game,mc._x,mc._y-20);
				game.fxList.push(fx);
			}
		}

		// shine drops
		if ( shineCpt>0 && Std.random(10)<=8 ) {
			shineCpt--;
			var fx = new Shine(game,mc._x,mc._y-20, (mc._currentframe==4) );
			game.fxList.push(fx);
		}

		// moves
		var xm = game.root._xmouse;
		var delta = xm-mc._x;
		var dist = Math.abs(delta);
		if ( xm==0 ) phase = Stop;

		if ( swapTimeout>0 ) {
			swapTimeout-=Timer.tmod;
			if ( swapTimeout<=0 ) {
				onSwap();
			}
		}

		switch (phase) {
		case Swap :
			if (swap.dx!=0 ) {
				mc.gotoAndStop(4);
			}
			else {
				mc.gotoAndStop(3);
			}
			dx*=0.92;
			if ( mc.smc._currentframe==SWAP_EVENT ) { onSwap(); }
			if ( mc.smc._currentframe==SWAP_EVENT_FX ) { shineCpt=10; }
			if ( mc.smc._currentframe==mc.smc._totalframes ) {
				mc.gotoAndStop(1);
				phase=Stop;
			}

		case Stop :
			dx*=0.92;
			if ( dist>BREAK_DIST*2 ) {
				phase = Run;
			}

		case Break :
			breakTimer-=Timer.tmod;
			dx*=0.8;
			if ( mc.smc._currentframe==mc.smc._totalframes ) mc.smc.stop();
			if ( breakTimer<=0 ) {
				dx = 0;
				if ( dist<=BREAK_DIST ) {
					phase = Stop;
					mc.gotoAndStop(1);
				}
				else {
					phase = Run;
				}
			}

		case Run :
			if ( delta<0 && dx>-MAX_SPEED ) {
				dx -= 2*Timer.tmod;
				mc.gotoAndStop(2);
			}
			if ( delta>0 && dx<MAX_SPEED ) {
				dx += 2*Timer.tmod;
				mc.gotoAndStop(2);
			}

			if (dist<=BREAK_DIST ||
				dx<0 && mc._x<xm ||
				dx>0 && mc._x>xm ||
				dx<0 && mc._x<MIN_X ||
				dx>0 && mc._x>MAX_X ) {
				breakTimer=BREAK_TIMER;
				phase = Break;
				mc.gotoAndStop(5);
			}

			if ( dx<0 ) {
				mc._xscale = -100;
			}
			if ( dx>0 ) {
				mc._xscale = 100;
			}
		default : trace("invalid phase for girl");
		}


		if ( breakTimer<=0 ) {
		}

		if ( breakTimer>0 ) {
		}
//		tx = xm;
//		dx = (tx-mc._x)*0.1;

		/*
		delay-=Timer.tmod;
		if ( breakTimer<=0 && delay<=0 ) {
			tx = xm;
		}
		var old = dx;
		dx = (tx-mc._x)*0.1;
<<<<<<< Girl.hx
		if (Math.abs(dx)>=1) {
			mc.gotoAndStop(2);
=======
		if ( breakTimer<=0 && dx/old<0 && Math.abs(dx-old)>=BREAK_MIN ) {
			dx = old;
			mc.gotoAndStop(4);
			breakTimer = 32;
>>>>>>> 1.6
		}
		else {
			breakTimer-=Timer.tmod;
			if ( breakTimer<=0 ) {
				if (Math.abs(dx)>=1) {
					mc.gotoAndStop(2);
				}
				else {
					mc.gotoAndStop(1);
				}
				if ( Math.abs(dx)<=0.3 ) {
					dx = 0;
				}
				if ( dx<0 ) {
					mc._xscale = -100;
				}
				if ( dx>0 ) {
					mc._xscale = 100;
				}
				if ( Math.abs(xm-mc._x)<=10 ) {
					delay = Std.random(5);
				}
			}
		}*/
		mc._x += dx*0.5;
		shadow._x = mc._x+2;
		shadow._y = mc._y;
		if ( mc._xscale<=0 ) shadow._x-=4;
	}
}

