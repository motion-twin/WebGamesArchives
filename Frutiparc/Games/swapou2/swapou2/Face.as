import swapou2.Data ;


class swapou2.Face extends MovieClip {

	// Movies
	var sub ;
	var fake ;

	// Divers
	public var skinId, stateId, bgId ; // xxx

	var normalBg, normalState, currentState ;
	var shake ;
	var timer ;
	var scale ;



	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(x,y,id) {
		_x = x ;
		_y = y ;

		skinId = 0 ;
		stateId = 0 ;
		bgId = 0 ;

		normalBg = 0 ;
		normalState = 0 ;
		currentState = normalState ;
		shake = 0 ;
		timer = 0 ;

		//    fake = Std.cast( Std.attachMC(this, "face", 0) ) ;
		fake._x = 0 ;
		fake.stop() ;
		fake.bg.stop() ;
		fake.char.stop() ;

		setFace(id, 0, normalBg) ;

		fake._alpha = 0 ;
		fake._visible = false ;

	}


	/*------------------------------------------------------------------------
	REDIMENSIONNE LA FACE
	------------------------------------------------------------------------*/
	function setScale(s) {
		scale = s/100 ;
		_xscale = s ;
		_yscale = _xscale ;
	}


	/*------------------------------------------------------------------------
	DUPLIQUE LA FACE EN COURS DANS LE FAKE
	------------------------------------------------------------------------*/
	private function duplicate() {
		fake.gotoAndStop(skinId+1) ;
		fake.bg.gotoAndStop(6) ;
		fake.char.gotoAndStop(stateId+1) ;
		fake._visible = true ;
		fake._alpha = 100 ;
	}


	/*------------------------------------------------------------------------
	INVERSION HORIZONTALE (FACE IA)
	------------------------------------------------------------------------*/
	function flip() {
		this.sub.bg._xscale = -this.sub.bg._xscale ;
		this.sub.char._xscale = -this.sub.char._xscale ;		
		//    this._xscale = -this._xscale ;
		if ( this.sub.bg._xscale<0 )
			sub.bg._x += Data.FACE_WIDTH ;
		else
			sub.bg._x -= Data.FACE_WIDTH ;
		fake.bg._xscale = sub.bg._xscale;
		fake._xscale = sub.bg._xscale;
		fake._x = sub.bg._x;
		//    this._x = x ;
		normalBg = 1 ;
		setBg(0,normalBg) ;
	}


	/*------------------------------------------------------------------------
	FOND
	------------------------------------------------------------------------*/
	function setBg(t,id) {
		timer = t ;
		duplicate() ;
		bgId = id ;
		sub.bg.gotoAndStop( string(bgId+1) ) ;
	}


	/*------------------------------------------------------------------------
	SKIN
	------------------------------------------------------------------------*/
	function setSkin(id) {
		duplicate() ;
		skinId = id ;
		this.sub.gotoAndStop( string(skinId+1) ) ;
		setState(0,stateId) ;
	}


	/*------------------------------------------------------------------------
	ÉTAT
	------------------------------------------------------------------------*/
	function setState(t,id) {
		timer = t ;
		duplicate() ;
		stateId = id ;
		sub.char.gotoAndStop( string(stateId+1) ) ;
	}


	/*------------------------------------------------------------------------
	REDÉFINI LA FACE
	------------------------------------------------------------------------*/
	private function setFace( skinId, stateId, bgId ) {
		duplicate() ;

		this.skinId = skinId ;
		this.stateId = stateId ;
		this.bgId = bgId ;

		sub.gotoAndStop( string(skinId+1) ) ;
		sub.bg.gotoAndStop( string(bgId+1) ) ;
		sub.char.gotoAndStop( string(stateId+1) ) ;
		update();
	}


	/*------------------------------------------------------------------------
	ACTIVE LE SHAKE SUR LA FACE
	------------------------------------------------------------------------*/
	function shakeItBaby(timer) {
		shake = timer ;
	}




	/*------------------------------------------------------------------------
	REMET LA FACE DANS SON ÉTAT NORMAL ACTUEL
	------------------------------------------------------------------------*/
	function reset() {
		currentState = normalState ;
		setFace(skinId, normalState, normalBg) ;
		if ( shake>0 )
			shake = 1 ;
	}

	/*------------------------------------------------------------------------
	COMBO: COLÈRE
	------------------------------------------------------------------------*/
	function setAngry(t) {
		timer = t ;
		setFace(skinId, 2, 4) ;
	}

	/*------------------------------------------------------------------------
	COMBO: JOIE
	------------------------------------------------------------------------*/
	function setHappy(t) {
		timer = t ;
		setFace(skinId, 4, 3) ;
	}

	/*------------------------------------------------------------------------
	COMBO: MORT
	------------------------------------------------------------------------*/
	function setDead(t) {
		timer = t ;
		setFace(skinId, 5, 1) ;		
	}

	/*------------------------------------------------------------------------
	COMBO: ATTAQUE
	------------------------------------------------------------------------*/
	function setAttack(t) {
		timer = t ;
		setFace(skinId, 2, 4) ;
	}

	/*------------------------------------------------------------------------
	COMBO: TOUCHÉ
	------------------------------------------------------------------------*/
	function setHit(t) {
		timer = t ;
		setFace(skinId, 3, 2) ;
		shakeItBaby(t) ;
	}

	/*------------------------------------------------------------------------
	ÉTAT: CALME
	------------------------------------------------------------------------*/
	function normal() {
		normalState = 0 ;
	}

	/*------------------------------------------------------------------------
	ÉTAT: PANIQUÉ
	------------------------------------------------------------------------*/
	function panic() {
		normalState = 1 ;
	}



	/*------------------------------------------------------------------------
	BOUCLE MAIN
	------------------------------------------------------------------------*/
	function update() {
		if ( timer>0 ) {
			timer-=Std.tmod ;
			if ( timer<=0 ) {
				timer = 0 ;
				reset() ;
			}
		}

		if ( timer==0 && currentState!=normalState )
			reset() ;


		// Fade
		if ( fake._alpha>0 ) {
			fake._alpha -= Std.tmod * Data.FACE_SPEED ;
			if ( fake._alpha<=0 ) {
				fake._alpha = 0 ;
				fake._visible = false ;
			}
		}

		// Tremblement
		if ( shake > 0 ) {
			shake-=Std.tmod ;
			if ( shake<=0 ) {
				sub.char._x = Data.FACE_WIDTH*0.5 ;
				sub.char._y = Data.FACE_HEIGHT*0.5 ;
			}
			else {
				sub.char._x = Data.FACE_WIDTH*0.5 + random(10)/10 * (random(2)*2-1) ;
				sub.char._y = Data.FACE_HEIGHT*0.5 + random(10)/10 * (random(2)*2-1) ;
			}
		}
	}

}
