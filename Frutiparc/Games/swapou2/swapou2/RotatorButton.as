import swapou2.Data ;

class swapou2.RotatorButton extends swapou2.Rotator {

	var label ;
	var yId ;
	var linkId ;
	var txtField ;

	var sub ;

	public var releaseCallback ;


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initRotatorButton( menu:swapou2.Menu, y, label, linkId, help ) {
		super.initRotator( menu, Data.BUTTON_X, y*Data.BUTTON_HEIGHT + Data.BUTTON_Y, y, help ) ;

    yId = Math.floor(y) ;
		this.label = label ;
		sub.txtField.text = label ;

		this.linkId = linkId ;
		if ( linkId<0 )
			this.sub.gotoAndStop(2) ;
		else
			this.sub.gotoAndStop(1) ;

		update() ;
	}


	/*------------------------------------------------------------------------
	EVENT: CLIC
	------------------------------------------------------------------------*/
	function release() {
		super.release() ;

		if (!active || locked) return ;

		if ( releaseCallback != undefined )
			releaseCallback() ;
		menu.onButtonSelect(linkId,yId) ;
	}


	/*------------------------------------------------------------------------
	ANIM DE ROLLOVER
	------------------------------------------------------------------------*/
	function update() {
		super.update() ;
		if (isOver && active && !locked) {
			this.nextFrame() ;
			if ( _currentframe == _totalframes )
				this.gotoAndStop("1") ;
		}
		else
			if ( _currentframe > 1 ) {
				this.nextFrame() ;
				if ( _currentframe == _totalframes )
					this.gotoAndStop("1")
			}
	}


}