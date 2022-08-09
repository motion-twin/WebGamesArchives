class Animation
{
	var game			: mode.GameMode ;
	var mc				: MovieClip ;
	var fl_kill			: bool ;
	var fl_loop			: bool ;
	var fl_loopDone		: bool ;
	var fl_blink		: bool;

	var frame			: float;
	var lifeTimer		: float ;
	var blinkTimer		: float;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(g:mode.GameMode) {
		game		= g ;
		frame		= 0 ;
		lifeTimer	= 0 ;
		blinkTimer	= 0;
		fl_kill		= false ;
		fl_loop		= false ;
		fl_loopDone	= false ;
		fl_blink	= false;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	function attach(x,y, link, depth) {
		mc = game.depthMan.attach(link,depth) ;
		mc._x = x ;
		mc._y = y ;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g:mode.GameMode) {
		game = g ;
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		mc.removeMovieClip() ;
		fl_kill = true ;
	}


	/*------------------------------------------------------------------------
	CLIGNOTTEMENT
	------------------------------------------------------------------------*/
	function blink() {
		fl_blink = true;
	}
	function stopBlink() {
		fl_blink = false;
		mc._alpha = 100;
	}


	/*------------------------------------------------------------------------
	RENVOIE LES INFOS DE CET OBJET
	------------------------------------------------------------------------*/
	function short() {
		return mc._name+" @"+mc._x+","+mc._y;
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		if ( fl_loopDone ) {
			lifeTimer -= Timer.tmod ;
			if ( lifeTimer<=0 ) {
				destroy() ;
			}
		}

		if ( fl_blink ) {
			blinkTimer-=Timer.tmod;
			if ( blinkTimer<=0 ) {
				mc._alpha	= (mc._alpha==100)?30:100;
				blinkTimer	= Data.BLINK_DURATION_FAST;
			}
		}

		frame += Timer.tmod ;
		while (frame>=1) {
			mc.nextFrame() ;
			if ( mc._currentframe == mc._totalframes ) {
				if (fl_loop) {
					mc.gotoAndStop("1") ;
				}
				fl_loopDone = true ;
			}
			frame-- ;
		}
	}
}


