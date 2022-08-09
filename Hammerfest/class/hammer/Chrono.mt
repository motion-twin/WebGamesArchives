class Chrono {

	var gameTimer		: int;
	var suspendTimer	: int;
	var haltedTimer		: int;
	var fl_stop			: bool;
	var fl_init			: bool;

	var frameTimer		: int; // currentframe time
	var prevFrameTimer	: int;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		suspendTimer	= null;
		frameTimer		= Std.getTimer();
		gameTimer		= frameTimer;
		haltedTimer		= get();

		reset();
		fl_stop			= true;
		fl_init			= false;
	}


	/*------------------------------------------------------------------------
	RENVOIE UN TEMPS FORMATTÉ
	------------------------------------------------------------------------*/
	function formatTime(t:int) {
		var d = new Date();
		d.setTime( t );
		return
			Data.leadingZeros( d.getMinutes()+(d.getHours()-1)*60, 2 ) +"\" "+
			Data.leadingZeros( d.getSeconds(), 2 ) +"' "+
			Data.leadingZeros( d.getMilliseconds(),3 );
	}

	function formatTimeShort(t:int) {
		var d = new Date();
		d.setTime( t );
		var arrond = 0;
		if ( d.getMilliseconds()>=500 ) {
			arrond = 1;
		}
		return
			Data.leadingZeros( d.getMinutes()+(d.getHours()-1)*60, 2 ) +"\" "+
			Data.leadingZeros( d.getSeconds()+arrond, 2 );
	}


	/*------------------------------------------------------------------------
	RENVOIE LA VALEUR DU CHRONO ACTUEL (millisecondes)
	------------------------------------------------------------------------*/
	function get() {
		if ( fl_stop ) {
			return haltedTimer;
		}
		else {
			return Math.floor( frameTimer-gameTimer );
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE LA VALEUR FORMATTÉE
	------------------------------------------------------------------------*/
	function getStr() {
		return formatTime( get() );
	}

	function getStrShort() {
		return formatTimeShort( get() );
	}



	/*------------------------------------------------------------------------
	GESTION DU CHRONO
	------------------------------------------------------------------------*/
	function reset() {
		fl_init			= true;
		fl_stop			= false;
		suspendTimer	= null;
		gameTimer		= frameTimer;
	}

	function start() {
		if ( suspendTimer!=null ) {
			var d = frameTimer-suspendTimer;
			gameTimer+=d;
		}
		haltedTimer = null;
		fl_stop = false;
		suspendTimer = null;
	}

	function stop() {
		if ( fl_stop ) {
			return;
		}
		haltedTimer = get();
		fl_stop = true;
		suspendTimer = frameTimer;
	}



	/*------------------------------------------------------------------------
	GAIN DE TEMPS
	------------------------------------------------------------------------*/
	function timeShift(n) {
		gameTimer = int( Math.min( frameTimer, gameTimer+n*1000 ) );
	}



	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		prevFrameTimer = frameTimer;
		frameTimer = Std.getTimer();
	}

}