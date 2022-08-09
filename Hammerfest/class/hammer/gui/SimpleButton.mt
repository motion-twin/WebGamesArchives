class gui.SimpleButton extends gui.Item
{
	var event : void -> void;
	var key : int;
	var toggle : int;
	var fl_keyLock : bool;

	var body : MovieClip;
	var left : MovieClip;
	var right : MovieClip;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initButton(c:gui.Container, l, key, func) {
		init(c,l);

		event = func;
		this.key = key;

		var me = this;
		body.onRelease = fun() { me.release() };
		body.onRollOut = fun() { me.rollOut() };
		body.onRollOver = fun() { me.rollOver() };

		left.onRelease = fun() { me.event() };
		left.onRollOut = fun() { me.rollOut() };
		left.onRollOver = fun() { me.rollOver() };

		right.onRelease = fun() { me.event() };
		right.onRollOut = fun() { me.rollOut() };
		right.onRollOver = fun() { me.rollOver() };


		rollOut();
	}

	/*------------------------------------------------------------------------
	DÉFINI UNE TOUCHE BASCULE EN COMPLÉMENT DE LA KEY
	------------------------------------------------------------------------*/
	function setToggleKey(k) {
		toggle = k;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(c:gui.Container, l:String, k:int, func) {
		var b : gui.SimpleButton = downcast( c.depthMan.attach("hammer_editor_button", Data.DP_INTERF) );
		b.initButton(c,l,k, func);
		return b;
	}


	/*------------------------------------------------------------------------
	EVENTS
	------------------------------------------------------------------------*/
	function release() {
		if ( !container.fl_lock ) {
			event();
		}
	}
	function rollOut() {
		var f = "1";
		left.gotoAndStop(f);
		body.gotoAndStop(f);
		right.gotoAndStop(f);
	}
	function rollOver() {
		var f = "2";
		left.gotoAndStop(f);
		body.gotoAndStop(f);
		right.gotoAndStop(f);
	}


	/*------------------------------------------------------------------------
	DÉFINI LE LABEL
	------------------------------------------------------------------------*/
	function setLabel(l) {
		field.text = l;
		body._width = field.textWidth+5;
		right._x = body._width;
		width = left._width + body._width + right._width;
	}

	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LA COMBINAISON DE TOUCHE EST ACTIVÉE
	------------------------------------------------------------------------*/
	function shortcut():bool {
		return
			Key.isDown(key) &&
			( (toggle==null && !Key.isDown(Key.CONTROL) && !Key.isDown(Key.SHIFT)) || Key.isDown(toggle));
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		if ( container.fl_lock ) {
			return;
		}

		if ( !shortcut() ) {
			fl_keyLock = false;
		}
		if ( shortcut() && !fl_keyLock ) {
			event();
			fl_keyLock = true;
		}
	}


}
