import swapou2.Data ;

class swapou2.RotatorFace extends swapou2.Rotator {

	var save_help;
	var char_color;
	var linkId, faceId ;
	var sub, bg, char : MovieClip ;

	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initRotatorFace(menu:swapou2.Menu, gridPos, faceId, linkId, help) {
		var xf,yf,x,y ;
		save_help = help;
		yf = Math.floor( gridPos/Data.FACES_BY_LINE ) ;
		xf = Math.floor( gridPos - yf * Data.FACES_BY_LINE ) ;

		x = Data.ROTATOR_FACE_X + xf * Data.ROTATOR_FACE_WIDTH ;
		y = Data.ROTATOR_FACE_Y + yf * Data.ROTATOR_FACE_HEIGHT ;
		if ( xf==Math.floor(Data.FACES_BY_LINE*0.5) ) {
			y -= Data.ROTATOR_FACE_HEIGHT * 0.5
		}

		this.linkId = linkId ;
		this.faceId = faceId ;

		this.initRotator( menu, x,y, gridPos*0.5, help ) ;

		xMove *= 0.8 ;
//		speed *= 1.5

		this.sub.sub.gotoAndStop( string(faceId+1) ) ;
		this.gotoAndStop( "1" ) ;
		this.sub.gotoAndStop("1") ;
		this.sub.sub.bg.gotoAndStop("1") ;
		this.sub.sub.char.gotoAndStop("1") ;
		char_color = new Color( this.sub.sub.char );
	}


	/*------------------------------------------------------------------------
	EVENT: ROLLOVER
	------------------------------------------------------------------------*/
	function over() {
		super.over() ;
	}


	/*------------------------------------------------------------------------
	EVENT: CLIC
	------------------------------------------------------------------------*/
	function release() {
		super.release() ;
		if ( !active || locked ) return ;
		menu.onFaceSelect(linkId, faceId) ;
	}


	/*------------------------------------------------------------------------
	ANIM DE ROLLOVER
	------------------------------------------------------------------------*/
	function update() {
		super.update() ;
		if (isOver && active && !locked) {
			this.sub.nextFrame() ;
			if ( sub._currentframe == sub._totalframes )
				this.sub.gotoAndStop("1") ;
		}
		else
			if ( sub._currentframe > 1 ) {
				this.sub.nextFrame() ;
				if ( sub._currentframe == sub._totalframes )
					this.sub.gotoAndStop("1")
			}
	}

	function enable() {
	  active = true ;
	  char_color.reset();
	  help = save_help;
	}

	function disable() {
		active = false ;
		var ct = {
			ra : 0,
			rb : 106,

			ga : 0,
			gb : 134,

			ba : 0,
			bb : -51,

			aa : 100,
			ab : 100
		};
//		var ct = {
//			ra : 15,
//			rb : 30,
//
//			ga : 15,
//			gb : 60,
//
//			ba : 15,
//			bb : 30,
//
//			aa : 100,
//			ab : 100
//		};
		char_color.setTransform(ct);
		help = "?????";
	}

}
