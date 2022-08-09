package mt.flash;

#if macro
import haxe.macro.Expr;
#end

/*
 * Seb: I hereby declare this class Back in Action. May it serves you well! Hail to the Great Holy Keyboard.
 *
 * IMPORTANT : call update() at the very BEGINNING of your main update loop()
 */
class Key {

	//less painful keycode fetching
	public static inline var BACKSPACE	= 8;
	public static inline var TAB		= 9;
	public static inline var ENTER		= 13;
	public static inline var SHIFT		= 16;
	public static inline var CTRL		= 17;
	public static inline var ALT		= 18;
	public static inline var ESCAPE		= 27;
	public static inline var SPACE		= 32;
	public static inline var PGUP		= 33;
	public static inline var PGDOWN		= 34;
	public static inline var END		= 35;
	public static inline var HOME		= 36;
	public static inline var LEFT		= 37;
	public static inline var UP			= 38;
	public static inline var RIGHT		= 39;
	public static inline var DOWN		= 40;
	public static inline var INSERT		= 45;
	public static inline var DELETE		= 46;

	public static inline var NUMBER_0	= 48;
	public static inline var NUMPAD_0	= 96;
	public static inline var F1			= 112;
	public static inline var F2			= 113;
	public static inline var F3			= 114;
	public static inline var F4			= 115;
	public static inline var F5			= 116;
	public static inline var F6			= 117;
	public static inline var F7			= 118;
	public static inline var F8			= 119;
	public static inline var F9			= 120;
	public static inline var F10		= 121;
	public static inline var F11		= 122;
	public static inline var F12		= 123;

	public static inline var A			= 65;
	public static inline var B			= 66;
	public static inline var C			= 67;
	public static inline var D			= 68;
	public static inline var E			= 69;
	public static inline var F			= 70;
	public static inline var G			= 71;
	public static inline var H			= 72;
	public static inline var I			= 73;
	public static inline var J			= 74;
	public static inline var K			= 75;
	public static inline var L			= 76;
	public static inline var M			= 77;
	public static inline var N			= 78;
	public static inline var O			= 79;
	public static inline var P			= 80;
	public static inline var Q			= 81;
	public static inline var R			= 82;
	public static inline var S			= 83;
	public static inline var T			= 84;
	public static inline var U			= 85;
	public static inline var V			= 86;
	public static inline var W			= 87;
	public static inline var X			= 88;
	public static inline var Y			= 89;
	public static inline var Z			= 90;

	public static inline var NUMPAD_MULT = 106;
	public static inline var NUMPAD_ADD	= 107;
	public static inline var NUMPAD_ENTER = 108;
	public static inline var NUMPAD_SUB = 109;
	public static inline var NUMPAD_DOT = 110;
	public static inline var NUMPAD_DIV = 111;


	public static macro function init() {
		var pos = haxe.macro.Context.currentPos();
		haxe.macro.Context.error("mt.Key has changed! Don't call init() anymore and add a call to update() at the BEGINNING of your main update()", pos);
		return {pos:pos, expr:EBlock([])}
	}

	#if (!macro && (flash9 || openfl))

	static var eventsAdded = false;
	static var downCodes = new Map< Int, Bool >();
	static var upCodes =  new Map< Int, Bool >();
	static var toggledCodes = new Map< Int, Int >();
	static var lockedToggles = new Map< Int, Bool >();
	static var ktime = 0;

	public static function destroy() {
		removeEvents();
		downCodes = new Map();
		upCodes = new Map();
		toggledCodes = new Map();
		lockedToggles = new Map();
	}

	static function removeEvents() {
		if( !eventsAdded )
			return;

		eventsAdded = false;
		var stage = flash.Lib.current.stage;
		stage.removeEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.removeEventListener(flash.events.KeyboardEvent.KEY_UP, onKeyUp);
		stage.removeEventListener(flash.events.Event.DEACTIVATE, onDeactivate);
	}

	static function onDeactivate(_) {
		downCodes = new Map();
		upCodes = new Map();
		toggledCodes = new Map();
	}

	static function onKeyDown(e:flash.events.KeyboardEvent) {
		onKey(e.keyCode, true);
	}

	static function onKeyUp(e:flash.events.KeyboardEvent) {
		onKey(e.keyCode, false);
	}

	public static function onKey( code:Int, down:Bool ) {
		if( code>1000 ) // TODO support for soft keys (Android)
			return;

		if ( down ) {
			if( !lockedToggles.exists(code) ) {
				toggledCodes.set(code,0);
				lockedToggles.set(code,true);
			}
			downCodes.set(code, true);
		}
		else {
			upCodes.set(code, true);
			lockedToggles.remove(code);
			// Release Ctrl when Alt pressed (AltGr generates Ctrl+Alt)
			if ( code == 18 )
				upCodes.set(17, true);
		}
	}


	public static function isDown(k:Int) {
		#if debug
		mt.Assert.isTrue(eventsAdded, "Please call Key.update() at least once before using isDown or isToggled");
		#end
		return downCodes.exists(k);
	}

	public static function isToggled(k) {
		#if debug
		mt.Assert.isTrue(eventsAdded, "Please call Key.update() at least once before using isDown or isToggled");
		#end
		return toggledCodes.exists(k);
	}

	public static function update(){
		var stage = flash.Lib.current.stage;
		if( stage==null )
			return;

		if( !eventsAdded ) {
			eventsAdded = true;
			stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(flash.events.Event.DEACTIVATE, onDeactivate);
		}

		ktime++;

		for(k in toggledCodes.keys())
			if( toggledCodes.get(k)==0 )
				toggledCodes.set(k,1);
			else
				toggledCodes.remove(k);

		for( k in upCodes.keys() ) {
			downCodes.remove(k);
			upCodes.remove(k);
		}
	}
	#end


	public static function enableJSKeys(objName:String) {
		#if flash
		try {
			flash.external.ExternalInterface.addCallback("onKeyEvent",#if !flash9 null,#end onKey);
			var r : Null<Bool> = flash.external.ExternalInterface.call("function() { var fla = window.document['"+objName+"']; if( fla == null ) return false; document.onkeydown = function(e) { if( e == null ) e = window.event; fla.onKeyEvent(e.keyCode,true); }; document.onkeyup = function(e) { if( e == null ) e = window.event; fla.onKeyEvent(e.keyCode,false); }; return true; }");
			if( r == null ) r = false;
			return r;
		} catch( e : Dynamic ) {
			return false;
		}
		#else
			return false;
		#end
	}

}

