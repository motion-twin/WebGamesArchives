class Entity extends MovieClip
{
	var game		: mode.GameMode ;


	var x			: float ; // real coords
	var y			: float ;

	var oldX		: float ; // previous real coords
	var oldY		: float ;

	var cx			: int ; // bottom entity case coords
	var cy			: int ;

	var fcx			: int ; // under feet case coords
	var fcy			: int ;

	var _xOffset	: float ; // graphical offset of mc (for shoots)
	var _yOffset	: float ;

	var rotation	: float ;
	var alpha		: float ;
	var minAlpha	: float ;
	var scaleFactor	: float ; // facteur (1.0)
	var defaultBlend: BlendMode;
	var blendId		: int; // int value of blendMode

	var types		: int ;

	var scriptId	: int ;

	var lifeTimer	: float ;
	var totalLife	: float ;

	var fl_kill		: bool ;
	var fl_destroy	: bool ;
	var world		: levels.GameMechanics ;

	var uniqId		: int ;
	var parent		: Entity ;
	var color		: Color ;

	var sticker			: MovieClip ;
	var stickerX		: float ;
	var stickerY		: float ;
	var elaStickFactor	: float;
	var stickTimer		: float;
	var fl_stick		: bool;
	var fl_stickRot		: bool;
	var fl_stickBound	: bool;
	var fl_elastick		: bool;
	var fl_softRecal	: bool;

	var softRecalFactor	: float;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		types = 0 //new Array() ;

		x = 0 ;
		y = 0 ;
		alpha = 100 ;
		rotation = 0 ;
		minAlpha = 35 ;
		defaultBlend = BlendMode.NORMAL;
		stickTimer	= 0;

		_xOffset = 0 ;
		_yOffset = 0 ;

		updateCoords() ;

		fl_kill			= false ;
		fl_destroy		= false ;
		fl_stickRot		= false ;
		fl_stickBound	= false;
		fl_softRecal	= false;

		if ( game.manager.fl_debug ) {
			this.onRelease	= release;
			this.onRollOver	= rollOver;
			this.onRollOut	= rollOut;
		}
	}



	/*------------------------------------------------------------------------
	INIT
	------------------------------------------------------------------------*/
	function init(g:mode.GameMode) {
		game = g ;
		uniqId = game.getUniqId() ;
		register(Data.ENTITY) ;
		world = game.world;
		scale(100) ;
	}


	/*------------------------------------------------------------------------
	ENREGISTRE UN NOUVEL ÉLÉMENT
	------------------------------------------------------------------------*/
	function register( type:int ) {
		game.addToList( type, this ) ;
		types |= type ;
	}

	/*------------------------------------------------------------------------
	ENREGISTRE UN NOUVEL ÉLÉMENT
	------------------------------------------------------------------------*/
	function unregister( type:int ) {
		game.removeFromList( type, this ) ;
		types ^= type ;
	}

	/*------------------------------------------------------------------------
	RENVOIE TRUE SI L'ENTITÉ EST DU TYPE SPÉCIFIÉ
	------------------------------------------------------------------------*/
	function isType(t) {
		return (types&t) > 0;
	}

	/*------------------------------------------------------------------------
	DÉFINI L'ENTITÉ PARENTE
	------------------------------------------------------------------------*/
	function setParent( e:Entity ) {
		parent = e ;
	}


	/*------------------------------------------------------------------------
	DÉFINI LE TEMPS DE VIE
	------------------------------------------------------------------------*/
	function setLifeTimer(t) {
		lifeTimer = t ;
		totalLife = t ;
	}

	/*------------------------------------------------------------------------
	MET À JOUR LE TEMPS DE VIE (SANS CHANGER LE TOTAL INITIAL)
	------------------------------------------------------------------------*/
	function updateLifeTimer(t) {
		if ( totalLife==null ) {
			setLifeTimer(t);
		}
		else {
			lifeTimer = t;
		}
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE TIMER DE VIE
	------------------------------------------------------------------------*/
	function onLifeTimer() {
		destroy() ;
	}


	/*------------------------------------------------------------------------
	HIT TEST DE BOUNDING BOX
	------------------------------------------------------------------------*/
	function hitBound(e:Entity) : bool {
		var res =(
			x+_width/2 > e.x-e._width/2 &&
			y > e.y-e._height &&
			x-_width/2 < e.x+e._width/2 &&
			y-_height < e.y
			) ;
		return res ;
	}


	/*------------------------------------------------------------------------
	L'ENTITÉ EN RENCONTRE UNE AUTRE
	------------------------------------------------------------------------*/
	function hit(e: Entity) {
		// do nothing
	}


	/*------------------------------------------------------------------------
	DESTRUCTEUR
	------------------------------------------------------------------------*/
	function destroy() {
		fl_kill = true ;
		fl_destroy = true ;
		unstick() ;
		for( var i=0;i<32;i++ ) {
			if ( (types&(1<<i)) > 0 ) {
				game.unregList.push( {type:Math.round(Math.pow(2,i)), ent:this} ) ;
			}
		}
		game.killList.push(this) ;
	}


	/*------------------------------------------------------------------------
	COLLE UN MC À L'ENTITÉ
	------------------------------------------------------------------------*/
	function stick(mc:MovieClip,ox,oy) {
		if (sticker._name!=null) {
			unstick();
		}
		sticker = mc ;
		stickerX = ox ;
		stickerY = oy ;
		fl_stick = true;
		fl_stickRot = false ;
		fl_stickBound = false;
		fl_elastick = false;
	}

	/*------------------------------------------------------------------------
	ACTIVE L'ELASTICITÉ DU STICKER (algo du cameraman bourré)
	------------------------------------------------------------------------*/
	function setElaStick(f) {
		if ( fl_elastick ) {
			return;
		}
		elaStickFactor	= f;
		fl_elastick		= true;
		stickerX		*= elaStickFactor;
		stickerY		*= elaStickFactor;
	}


	/*------------------------------------------------------------------------
	DÉCOLLE LE STICKER
	------------------------------------------------------------------------*/
	function unstick() {
		fl_stick = false;
		sticker.removeMovieClip() ;
	}


	/*------------------------------------------------------------------------
	ACTIVE LE SOFT-RECAL (coordonnées graphiques en retard sur les réelles)
	------------------------------------------------------------------------*/
	function activateSoftRecal() {
		fl_softRecal = true;
		softRecalFactor = 0.1;
	}


	// *** DEBUG ***
	function release() {
		if ( Key.isDown(Key.SHIFT) ) {
			if ( Key.isDown(Key.CONTROL) ) {
				Log.trace("Full serialization: "+short());
				System.setClipboard( Log.toString(this) );
			}
			else {
				Log.clear();
				Log.trace( short() );
				Log.trace("----------");
				Log.trace("dir="+Std.cast(this).dir+" dx="+Std.cast(this).dx+" dy="+Std.cast(this).dy+" xscale="+_xscale);
			}
		}
	}

	function rollOver() {
		if ( Key.isDown(Key.SHIFT) ) {
			var filter = new flash.filters.GlowFilter();
			filter.quality = 1;
			filter.color = 0xffffff;
			filter.strength = 200;
			filters = [filter];
		}
	}

	function rollOut() {
		if ( filters != null ) {
			filters = null;
		}
	}



	// *** DÉFORMATIONS ET TRANSFORMATIONS

	/*------------------------------------------------------------------------
	MASQUE/AFFICHE L'ENTITÉ
	------------------------------------------------------------------------*/
	function hide() {
		_visible = false ;
		if ( sticker._name!=null ) {
			sticker._visible = _visible ;
		}
	}
	function show() {
		_visible = true ;
		if ( sticker._name!=null ) {
			sticker._visible = _visible ;
		}
	}


	/*------------------------------------------------------------------------
	RE-SCALE DE L'ENTITÉ
	------------------------------------------------------------------------*/
	function scale(n:float) {
		scaleFactor = n/100 ;
		_xscale = n ;
		_yscale = _xscale ;
	}


	/*------------------------------------------------------------------------
	DÉFINI UN FILTRE DE COULEUR (HEXADÉCIMAL)
	------------------------------------------------------------------------*/
	function setColorHex( a:int, col:int ) {
		var coo = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
		var ratio  = a/100;
		var ct = {
			ra:int(100-a),
			ga:int(100-a),
			ba:int(100-a),
			aa:100,
			rb:int(ratio*coo.r),
			gb:int(ratio*coo.g),
			bb:int(ratio*coo.b),
			ab:0
		};
		color = new Color(this);
		color.setTransform( ct );
	}


	/*------------------------------------------------------------------------
	ANNULE LE FILTRE DE COULEUR
	------------------------------------------------------------------------*/
	function resetColor() {
		color.reset();
		color = null;
	}


	/*------------------------------------------------------------------------
	MODIFIE LE BLEND MODE
	------------------------------------------------------------------------*/
	function setBlend(m:BlendMode) {
		defaultBlend	= m;
		blendMode		= m;
		blendId			= Std.cast(m);
	}



	// *** COORDONNÉES

	/*------------------------------------------------------------------------
	MISE À JOUR DES COORDONNÉES DE CASE
	------------------------------------------------------------------------*/
	function updateCoords() {
		cx = Entity.x_rtc(x) ;
		cy = Entity.y_rtc(y) ;
		fcx = Entity.x_rtc(x) ;
		fcy = Entity.y_rtc(y+Math.floor(Data.CASE_HEIGHT/2)) ;
	}


	/*------------------------------------------------------------------------
	CONVERSION REAL -> CASE
	------------------------------------------------------------------------*/
	static function rtc(x,y) {
		return {
			x : Entity.x_rtc(x),
			y : Entity.y_rtc(y)
		} ;
	}
	static function x_rtc(n):int {
		return Math.floor(n/Data.CASE_WIDTH) ;
	}
	static function y_rtc(n):int {
		return Math.floor((n-Data.CASE_HEIGHT/2)/Data.CASE_HEIGHT) ;
	}


	/*------------------------------------------------------------------------
	CONVERSION CASE -> REAL
	------------------------------------------------------------------------*/
	static function x_ctr(n):float {
		return n*Data.CASE_WIDTH + Data.CASE_WIDTH*0.5 ;
	}
	static function y_ctr(n):float {
		return n*Data.CASE_HEIGHT + Data.CASE_HEIGHT;
	}


	/*------------------------------------------------------------------------
	NORMALISE UN ANGLE (EN DEGRÉ) DANS L'INTERVAL 0-360
	------------------------------------------------------------------------*/
	function adjustAngle(a) {
		while (a<0) {
			a+=360 ;
		}
		while (a>=360) {
			a-=360 ;
		}
		return a ;
	}


	function adjustToLeft() {
		x = x_ctr(cx) ;
		y = y_ctr(cy) ;
		x-=Data.CASE_WIDTH*0.5+1
	}
	function adjustToRight() {
		x = x_ctr(cx) ;
		y = y_ctr(cy) ;
		x+=Data.CASE_WIDTH*0.5-1
	}
	function centerInCase() {
		x = x_ctr(cx) ;
		y = y_ctr(cy) ;
	}


	/*------------------------------------------------------------------------
	RENVOIE LA DISTANCE DE L'ENTITÉ À UNE CASE
	------------------------------------------------------------------------*/
	function distanceCase(cx:int,cy:int) {
		return Math.sqrt( Math.pow(cy-this.cy,2) + Math.pow(cx-this.cx,2) );
	}

	function distance(x:float,y:float) {
		return Math.sqrt( Math.pow(y-this.y,2) + Math.pow(x-this.x,2) );
	}


	// *** UPDATES

	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		// Durée de vie
		if ( lifeTimer>0 ) {
			lifeTimer-=Timer.tmod ;
			if ( lifeTimer<=0 ) {
				onLifeTimer() ;
			}
		}

		if ( stickTimer>0 ) {
			stickTimer-=Timer.tmod;
			if ( stickTimer<=0 ) {
				unstick();
			}
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE LE NOM COURT DU MOVIE
	------------------------------------------------------------------------*/
	function short():String {
		var str : String = ""+Std.cast(this) ;
		str = str.slice(str.lastIndexOf(".",9999)+1,9999)
		str = str + "(@"+cx+","+cy+")";
		return str ;
	}

	/*------------------------------------------------------------------------
	renvoie tous les types
	------------------------------------------------------------------------*/
	function printTypes() {
		var l = new Array();
		var b = 0;
		for (var i=0;i<30;i++) {
			var fl = ((types&(1<<b++))>0);
			if ( fl ) {
				l.push(i);
			}
		}
		return l.join(",");
	}


	/*------------------------------------------------------------------------
	CLOTURE DES UPDATES
	------------------------------------------------------------------------*/
	function endUpdate() {
		updateCoords() ;
		if ( fl_softRecal ) {
			var tx = x+_xOffset;
			var ty = y+_yOffset;
			_x = _x + (tx-_x)*softRecalFactor;
			_y = _y + (ty-_y)*softRecalFactor;
			softRecalFactor += 0.02*Timer.tmod;
			if ( softRecalFactor>=1 || ( Math.abs(tx-_x)<=1.5 && Math.abs(ty-_y)<=1.5 ) ) {
				fl_softRecal = false;
			}
		}
		if ( !fl_softRecal ) {
			_x = x+_xOffset ;
			_y = y+_yOffset ;
		}
		_rotation = rotation ;
		_alpha = Math.max(minAlpha, alpha) ;
		if ( alpha!=100 && blendId<=2 ) {
			blendMode = BlendMode.LAYER;
		}
		else {
			blendMode = defaultBlend;
		}
		oldX = x ;
		oldY = y ;
		if ( fl_stick ) {
			if ( fl_elastick ) {
				sticker._x = sticker._x + (x-sticker._x)*elaStickFactor + stickerX;
				sticker._y = sticker._y + (y-sticker._y)*elaStickFactor + stickerY;
			}
			else {
				sticker._x = x + stickerX;
				sticker._y = y + stickerY;
			}
			if ( fl_stickRot ) {
				sticker._rotation+=8*Timer.tmod;
			}
			if ( fl_stickBound ) {
				sticker._x = Math.max( sticker._x, sticker._width*0.5 );
				sticker._x = Math.min( sticker._x, Data.GAME_WIDTH-sticker._width*0.5 );
			}
		}
	}

}
