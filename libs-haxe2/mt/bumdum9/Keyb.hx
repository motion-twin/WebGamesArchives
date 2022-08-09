package mt.bumdum9;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.KeyLocation;


class Keyb implements haxe.Public
{//}
	static var TRACE =  false;

	static var KEY_UP = 	38;
	static var KEY_DOWN = 	40;
	static var KEY_LEFT = 	37;
	static var KEY_RIGHT = 	39;
	static var KEY_ACTION =	32;
	static var KEY_CANCEL =	27;
	static var KEY_DEBUG =	9;
	static var KEY_DEBUG2 =	222;
	
	static var control = false;
	static var alt = false;
	
	static var pressUp:		Void -> Void;
	static var pressDown:	Void -> Void;
	static var pressLeft:	Void -> Void;
	static var pressRight:	Void -> Void;
	static var pressAction:	Void -> Void;
	static var pressCancel:	Void -> Void;
	static var pressDebug:	Void -> Void;
	static var pressDebug2:	Void -> Void;
	static var pressLetter:	Int -> Void;
	static var pressKey:	Int -> Void;
	
	static var defaultActions:Array < Void -> Void > ;
	static var actions:Array < Void -> Void > ;
	static var a = [];

	static function init() {
		//
		defaultActions = [];
		actions = [];
		var trg = flash.Lib.current.stage;
		trg.addEventListener(KeyboardEvent.KEY_DOWN, Keyb.onKeyDown );
		trg.addEventListener(KeyboardEvent.KEY_UP, Keyb.onKeyUp );
		
		trg.addEventListener( Event.DEACTIVATE, lostFocus  );
		
		//
		
		//
		clean();
	}
	
	static function bindDefaultAction(n:Int,f:Void->Void) {
		defaultActions[n] = f;
	}
	
	static function onKeyDown(e:KeyboardEvent) {
		//if(a[e.keyCode]) return;
		a[e.keyCode] = true;
		control = e.ctrlKey;
		alt = e.altKey;
		var char = String.fromCharCode(e.charCode);
		if (TRACE) {
			var char = String.fromCharCode(e.charCode);
			//trace(char );
			trace(" keyCode : " + e.keyCode );
			//trace(" charCode : " + e.charCode );
		}
		//trace(" keyCode : " + e.keyCode );
		if ( e.keyCode >= 65 && e.keyCode <= 90 ) pressLetter(e.keyCode);
		pressKey(e.keyCode);
		switch(e.keyCode) {
			case KEY_UP :		pressUp();
			case KEY_DOWN :		pressDown();
			case KEY_LEFT :		pressLeft();
			case KEY_RIGHT :	pressRight();
			case KEY_ACTION :	pressAction();
			case KEY_CANCEL :	pressCancel();
			
			case KEY_DEBUG :	pressDebug();
			case KEY_DEBUG2 :	pressDebug2();
			default :
				var ac = actions[e.keyCode];
				if ( ac != null) ac();
		}
		
	}
	static function onKeyUp(e:KeyboardEvent) {
		a[e.keyCode] = false;
		control = e.ctrlKey;
		alt = e.altKey;
	}
	
	static function clean() {
		
		actions = [];
		var id = 0;
		for ( n in defaultActions ) {
			actions[id] = n;
			id++;
		}
		
		pressUp = function() { };
		pressDown = function() { };
		pressLeft = function() { };
		pressRight = function() { };
		pressAction = function() { };
		pressCancel = function() { };
		
		pressDebug = function() { };
		pressDebug2 = function() { };
		
		pressLetter = function(n) { };
		pressKey = function(n) { };
	}
	
	static function getKeyName(code:Int) {
		
		if ( code >= 65 && code <= 90 ) return String.fromCharCode( 97 + (code-65) );
		switch(code) {
			case 32 :		return "space";
			case 17 :		return "control";
			case 16 :		return "shift";
			case 13 :		return "enter";
		}
		
		return "?";
		
	}
	
	static function isShift() { return a[16]; }
	static function isUp() { return a[KEY_UP]; }
	static function isDown() { return a[KEY_DOWN]; }
	static function isLeft() { return a[KEY_LEFT]; }
	static function isRight() { return a[KEY_RIGHT]; }
	static function isAction() { return a[KEY_ACTION]; }
	static function isCancel() { return a[KEY_CANCEL]; }
	static function isDebug() { return a[KEY_DEBUG]; }
	static function isDebug2() { return a[KEY_DEBUG2]; }
	
	static function lostFocus(e) {
		for( id in 0...a.length ) a[id] = false;
	}
	
//{
}


