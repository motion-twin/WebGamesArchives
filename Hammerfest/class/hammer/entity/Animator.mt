class entity.Animator extends entity.Trigger
{

	var sub				: MovieClip;
	var animId			: int;

	var frame			: float;
	var animFactor		: float;
	var blinkTimer		: float;

	var blinkColor		: int;
	var blinkColorAlpha	: int;
	var blinkAlpha		: int;


	var fl_anim			: bool;
	var fl_loop			: bool;
	var fl_blink		: bool;
	var fl_alphaBlink	: bool;
	var fl_stickyAnim	: bool;

	var fadeStep		: float;

	private var fl_blinking	: bool;
	private var fl_blinked	: bool;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		frame = 0;
		fadeStep = 0;
		animFactor = 1.0;
		fl_loop			= false;
		fl_blinking		= false;
		fl_blinked		= true;
		fl_stickyAnim	= false;

		fl_alphaBlink	= true;
		fl_blink		= true;
		blinkTimer		= 0;
		blinkColor		= 0xffffff;
		blinkAlpha		= 20;
		blinkColorAlpha	= 30;
		enableAnimator();
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g:mode.GameMode) {
		super.init(g);
		this.gotoAndStop("1");
		sub.stop();
	}


	/*------------------------------------------------------------------------
	ACTIVE/DÉSACTIVE L'ANIMATOR
	------------------------------------------------------------------------*/
	function enableAnimator() {
		fl_anim = true;
		this.stop();
	}
	function disableAnimator() {
		fl_anim = false;
		this.play();
	}


	/*------------------------------------------------------------------------
	ACTIVE/DÉSACTIVE LE CLIGNOTEMENT
	------------------------------------------------------------------------*/
	function blink(duration) {
		if ( !fl_blink ) {
			return;
		}
		fl_blinking = true;
		blinkTimer = duration;
	}
	function stopBlink() {
		fl_blinking = false;
		if ( fl_alphaBlink ) {
			alpha = 100;
		}
		else {
			resetColor();
		}
	}

	/*------------------------------------------------------------------------
	LANCE UN CLIGNOTEMENT BASÉ SUR LA DURÉE DE VIE
	------------------------------------------------------------------------*/
	function blinkLife() {
		if ( lifeTimer/totalLife<=0.1 ) {
			blink(Data.BLINK_DURATION_FAST);
		}
		else if ( lifeTimer/totalLife<=0.3 ) {
			blink(Data.BLINK_DURATION);
		}
	}


	/*------------------------------------------------------------------------
	REDÉFINI LE PATH VERS L'ANIMATION
	------------------------------------------------------------------------*/
	function setSub(mc) {
		sub = mc;
	}


	/*------------------------------------------------------------------------
	EVENT: FIN D'ANIM
	------------------------------------------------------------------------*/
	function onEndAnim(id:int) {
		unstickAnim();
		// Do nothing
	}

	function stickAnim() {
		fl_stickyAnim = true;
	}

	function unstickAnim() {
		fl_stickyAnim = false;
	}


	/*------------------------------------------------------------------------
	MET L'ENTITÉ DANS UNE PHASE D'ANIM DONNÉE (1 À N)
	------------------------------------------------------------------------*/
	function playAnim( animObject ) {
		if ( fl_stickyAnim || fl_kill || !fl_anim ) {
			return;
		}
		if ( animId == animObject.id && fl_loop == animObject.loop ) {
			return;
		}

		animId = animObject.id;
		this.gotoAndStop(""+(animId+1));
		sub.gotoAndStop("1");
		fl_loop = animObject.loop;
		frame = 0;
	}

	/*------------------------------------------------------------------------
	FORCE LA VALEUR DU FLAG DE LOOP
	------------------------------------------------------------------------*/
	function forceLoop(flag) {
		fl_loop = flag;
	}


	/*------------------------------------------------------------------------
	RELANCE L'ANIMATION EN COURS
	------------------------------------------------------------------------*/
	function replayAnim() {
		var id = animId;
		var fid = ( (id==1)?2:1 );
		playAnim( {id:fid,	loop:fl_loop} );
		playAnim( {id:id, 	loop:fl_loop} );
	}

//	/*------------------------------------------------------------------------
//	LANCE UN FADE AU BLANC
//	------------------------------------------------------------------------*/
//	function fade(duration) {
//		fadeStep = duration * Timer.fps / 100;
//		// 20   1
//		//      2
//	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update();

		// Clignotement
		if ( fl_blink ) {
			if ( !fl_blinking && lifeTimer>0 ) {
				blinkLife();
			}
			if ( fl_blinking ) {
				blinkTimer-=Timer.tmod;
				if ( blinkTimer<=0 ) {
					if ( fl_blinked ) {
						if ( fl_alphaBlink ) {
							alpha = 100;
						}
						else {
							resetColor();
						}
						fl_blinked = false;
					}
					else {
						if ( fl_alphaBlink ) {
							alpha = blinkAlpha;
						}
						else {
							setColorHex(blinkColorAlpha,blinkColor);
						}
						fl_blinked = true;
					}
					blinkLife();
				}
			}
		}


		if ( !fl_anim ) return;


		// Lecture du subMovie
		if ( frame>=0 ) {
			var fl_break=false;
			frame += animFactor*Timer.tmod;
			while (!fl_break && frame>=1) {
				if (sub._currentframe==sub._totalframes ) {
					if ( fl_loop ) {
						sub.gotoAndStop("1");
					}
					else {
						frame = -1;
						onEndAnim(animId);
						fl_break=true;
					}
				}
				if (!fl_break) {
					sub.nextFrame();
					frame--;
				}
			}
		}
	}

}
