class swapou2.SimpleButton extends MovieClip {
	var x,y ;
	var context ;

	var callback : Function ;
	var isOver ;
	var link ;

	var active ;
	var locked ; // verrou évenementiel (attente serveur par ex)

	public var skin ;

	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function attach(callbackContext, linkage, x,y,callback) {
		if ( skin._name!=undefined )
			skin.removeMovieClip() ;
		skin = Std.cast( Std.attachMC(this, linkage, 0) ) ;
		skin.stop() ;

		this.context = callbackContext ;
		this._x = x ;
		this._y = y ;

		onRelease = release ;
		onRollOver = over ;
		onRollOut = out ;
		this.callback = callback ;

		link = linkage ;
		isOver = false ;
		unlock() ;
		enable() ;
	}


	/*------------------------------------------------------------------------
	EVENT: ROLLOVER
	------------------------------------------------------------------------*/
	function over() {
		isOver = true ;
	}
	/*------------------------------------------------------------------------
	EVENT: ROLLOUT
	------------------------------------------------------------------------*/
	function out() {
		isOver = false ;
	}
	/*------------------------------------------------------------------------
	EVENT: RELEASE
	------------------------------------------------------------------------*/
	function release() {
		if ( active && !locked )
			Std.cast(callback).call(context) ;
	}


	/*------------------------------------------------------------------------
	ÉTATS DU BOUTON
	------------------------------------------------------------------------*/
	function enable() {
		this._alpha = 100 ;
		this.useHandCursor = true ;
		active = true ;
	}
	function disable() {
		this._alpha = 50 ;
		this.useHandCursor = false ;
		active = false ;
	}
	function lock() {
		locked = true ;
	}
	function unlock() {
		locked = false ;
	}


	/*------------------------------------------------------------------------
	BOUCLE DE GESTION
	------------------------------------------------------------------------*/
	function update() {
		if (isOver && active && !locked ) {
			skin.nextFrame() ;
			if ( skin._currentframe == skin._totalframes )
				skin.gotoAndStop("1") ;
		}
		else
			if ( skin._currentframe > 1 ) {
				skin.nextFrame() ;
				if ( skin._currentframe == skin._totalframes )
					skin.gotoAndStop("1")
			}
	}
}

