package mt.flash;

import hxd.Key;
import mt.flash.GamePad;

enum Mode {
	Keyboard;
	Pad;
}

class Controller {
	static var CUR_MODE : Mode = Keyboard;
	static var EXCLUSIVE_ID : String = null;
	static var GC : GamePad;
	static var SUSPEND_TIMER = 0.;
	static var UNIQ_ID = 0;
	static var LONG_PRESS = 0.35; // seconds
	static var SHORT_PRESS = 0.17; // seconds
	static var GLOBAL_LOCK = false;
	public static var ALLOW_AUTO_SWITCH = true;

	static var primary : Map<Int,Int> = new Map();
	static var secondary : Map<Int,Int> = new Map();
	static var third : Map<Int,Int> = new Map();

	public var mode(get,never) : Mode; inline function get_mode() return CUR_MODE;
	var id : String;
	var manualLock = false;

	public function new(id:String, ?exclusive=false) {
		this.id = id + (UNIQ_ID++);
		suspendTemp(0.1);
		if( exclusive )
			takeExclusivity();

		if( GC==null ) {
			GC = new GamePad(0.4);
			GC.onAnyControl = function() {
				if( ALLOW_AUTO_SWITCH && CUR_MODE!=Pad )
					CUR_MODE = Pad;
			}
			Boot.ME.s2d.addEventListener( function(e:hxd.Event) {
				if( ALLOW_AUTO_SWITCH && e.kind==EMove && CUR_MODE!=Keyboard )
					CUR_MODE = Keyboard;
			});
		}
	}

	public static inline function toggleInvert(axis:PadKey) return GC.toggleInvert(axis);

	public static function bind(k:PadKey, keyboardKey:Int, ?alternate1:Int, ?alternate2:Int) {
		primary.set(k.getIndex(), keyboardKey);

		if( alternate1!=null )
			secondary.set(k.getIndex(), alternate1);

		if( alternate2!=null )
			third.set(k.getIndex(), alternate2);
	}

	public static inline function getPrimaryKey(k:PadKey) : Null<Int> {
		return primary.get( k.getIndex() );
	}
	public static inline function getSecondaryKey(k:PadKey) : Null<Int> {
		return secondary.get( k.getIndex() );
	}
	public static inline function getThirdKey(k:PadKey) : Null<Int> {
		return third.get( k.getIndex() );
	}

	public inline function isKeyboard() return CUR_MODE==Keyboard;
	public inline function isGamePad() return CUR_MODE==Pad;

	public static inline function setKeyboard() CUR_MODE = Keyboard;
	public static inline function setGamePad() CUR_MODE = Pad;

	public inline function lock() manualLock = true;
	public inline function unlock() manualLock = false;
	public inline function locked() return manualLock || GLOBAL_LOCK || ( EXCLUSIVE_ID!=null && EXCLUSIVE_ID!=id ) || haxe.Timer.stamp()<SUSPEND_TIMER;

	public static function lockGlobal() GLOBAL_LOCK = true;
	public static function unlockGlobal() {
		if( GLOBAL_LOCK ) {
			GLOBAL_LOCK = false;
			suspendTemp();
		}
	}

	public inline function isDown(k:PadKey)      return !locked() && ( isKeyboardDown(getPrimaryKey(k)) || isKeyboardDown(getSecondaryKey(k)) || isKeyboardDown(getThirdKey(k)) || GC.isDown(k) );
	public inline function isPressed(k:PadKey)   return !locked() && ( isKeyboardPressed(getPrimaryKey(k)) || isKeyboardPressed(getSecondaryKey(k)) || isKeyboardPressed(getThirdKey(k)) || GC.isPressed(k) );

	public inline function isShortPressed(k:PadKey)  return !locked() && framePresses.get(k.getIndex())==1;
	public inline function isLongPressed(k:PadKey)   return !locked() && framePresses.get(k.getIndex())==2;
	public inline function isLongPressing(k:PadKey)  return !locked() && getLongPressRatio(k)>0;

	public inline function leftDown()        return isDown(AXIS_LEFT_X_NEG);
	public inline function leftPressed()     return isPressed(AXIS_LEFT_X_NEG);
	public inline function dpadLeftDown()    return isDown(DPAD_LEFT);
	public inline function dpadLeftPressed() return isPressed(DPAD_LEFT);

	public inline function rightDown()        return isDown(AXIS_LEFT_X_POS);
	public inline function rightPressed()     return isPressed(AXIS_LEFT_X_POS);
	public inline function dpadRightDown()    return isDown(DPAD_RIGHT);
	public inline function dpadRightPressed() return isPressed(DPAD_RIGHT);

	public inline function upDown()          return isDown(AXIS_LEFT_Y_POS);
	public inline function upPressed()       return isPressed(AXIS_LEFT_Y_POS);
	public inline function dpadUpDown()      return isDown(DPAD_UP);
	public inline function dpadUpPressed()   return isPressed(DPAD_UP);

	public inline function downDown()        return isDown(AXIS_LEFT_Y_NEG);
	public inline function downPressed()     return isPressed(AXIS_LEFT_Y_NEG);
	public inline function dpadDownDown()    return isDown(DPAD_DOWN);
	public inline function dpadDownPressed() return isPressed(DPAD_DOWN);
	public inline function dpadDownLongPressed()    return !locked() && framePresses.get(DPAD_DOWN.getIndex())==2;
	public inline function dpadDownLongPressing()   return !locked() && getLongPressRatio(DPAD_DOWN)>0;
	public inline function dpadDownLongPressRatio() return getLongPressRatio(DPAD_DOWN);

	public inline function aDown()           return isDown(A);
	public inline function aPressed()        return isPressed(A);
	public inline function aShortPressed()   return !locked() && framePresses.get(A.getIndex())==1;
	public inline function aLongPressed()    return !locked() && framePresses.get(A.getIndex())==2;
	public inline function aLongPressing()   return !locked() && getLongPressRatio(A)>0;
	public inline function aLongPressRatio() return getLongPressRatio(A);

	public inline function bDown()           return isDown(B);
	public inline function bPressed()        return isPressed(B);
	public inline function bShortPressed()   return !locked() && framePresses.get(B.getIndex())==1;
	public inline function bLongPressed()    return !locked() && framePresses.get(B.getIndex())==2;
	public inline function bLongPressing()   return !locked() && getLongPressRatio(B)>0;
	public inline function bLongPressRatio() return getLongPressRatio(B);

	public inline function xDown()           return isDown(X);
	public inline function xPressed()        return isPressed(X);
	public inline function xShortPressed()   return !locked() && framePresses.get(X.getIndex())==1;
	public inline function xLongPressed()    return !locked() && framePresses.get(X.getIndex())==2;
	public inline function xLongPressing()   return !locked() && getLongPressRatio(X)>0;
	public inline function xLongPressRatio() return getLongPressRatio(X);
	public inline function xValue()          return GC.getValue(AXIS_LEFT_X_POS);

	public inline function yDown()           return isDown(Y);
	public inline function yPressed()        return isPressed(Y);
	public inline function yShortPressed()   return !locked() && framePresses.get(Y.getIndex())==1;
	public inline function yLongPressed()    return !locked() && framePresses.get(Y.getIndex())==2;
	public inline function yLongPressing()   return !locked() && getLongPressRatio(Y)>0;
	public inline function yLongPressRatio() return getLongPressRatio(Y);
	public inline function yValue()          return GC.getValue(AXIS_LEFT_Y_POS);

	public inline function ltDown()          return isDown(LT);
	public inline function ltPressed()       return isPressed(LT);

	public inline function rtDown()          return isDown(RT);
	public inline function rtPressed()       return isPressed(RT);

	public inline function lbDown()          return isDown(LB);
	public inline function lbPressed()       return isPressed(LB);

	public inline function rbDown()          return isDown(RB);
	public inline function rbPressed()       return isPressed(RB);

	public inline function startPressed()    return isPressed(START);
	public inline function selectPressed()   return isPressed(SELECT);


	public inline function takeExclusivity()  EXCLUSIVE_ID = id;

	public inline function releaseExclusivity() {
		if( EXCLUSIVE_ID==id ) {
			EXCLUSIVE_ID = null;
			suspendTemp();
		}
	}

	static inline function suspendTemp(?sec=0.2) {
		SUSPEND_TIMER = haxe.Timer.stamp() + sec;
	}

	public inline function isKeyboardDown(k:Null<Int>)     return k!=null && !locked() && Key.isDown(k);
	public inline function isKeyboardUp(k:Null<Int>)       return k!=null && !locked() && !Key.isDown(k);
	public inline function isKeyboardPressed(k:Null<Int>)  return k!=null && !locked() && Key.isPressed(k);

	public function dispose() {
		releaseExclusivity();
		suspendTemp();
	}


	// Autofire management

	//var autoFires : Map<String,Float>;
	//var acd : mt.Cooldown;
	//function updateAutoFire(k:String) {
		//if( !GC.isDown(k) )
			//autoFires.set(k, 0);
		//else
			//autoFires.set(k, autoFires.get(k)+1);
	//}
//
	//inline function isPressedWithAutoFire(k:String) {
		//return GC.isDown(k) && !cdb.
	//}


	// Long presses management

	static var pressTimers : Map<Int,Float> = new Map();
	static var framePresses : Map<Int,Int> = new Map();
	static var longPressLock : Map<Int,Bool> = new Map();
	static var hasAnyPress = false;

	static function updateLongPress(k:PadKey) {
		var idx = k.getIndex();
		if( !pressTimers.exists(idx) )
			pressTimers.set(idx,-1);

		if( GC.isDown(k) || Key.isDown(getPrimaryKey(k)) || Key.isDown(getSecondaryKey(k)) || Key.isDown(getThirdKey(k)) ) {
			if( pressTimers.get(idx)==-1 )
				pressTimers.set(idx, haxe.Timer.stamp());

			// Long press detected
			if( haxe.Timer.stamp()-pressTimers.get(idx)>=LONG_PRESS ) {
				if( !longPressLock.exists(idx) ) {
					framePresses.set(idx, 2);
					hasAnyPress = true;
					longPressLock.set(idx,true);
				}
			}
		}
		else {
			if( longPressLock.exists(idx) )
				longPressLock.remove(idx);

			if( pressTimers.get(idx)!=-1 ) {
				if( !framePresses.exists(idx) ) {
					// Short press detected
					if( haxe.Timer.stamp()-pressTimers.get(idx)<=SHORT_PRESS ) {
						hasAnyPress = true;
						framePresses.set(idx, 1);
					}
				}
				pressTimers.set(idx, -1);
			}
		}
	}

	public inline function getLongPressRatio(k:PadKey) : Float {
		if( framePresses.exists(k.getIndex()) || pressTimers.get(k.getIndex())<0 )
			return 0;

		return MLib.fclamp( ( haxe.Timer.stamp()-pressTimers.get(k.getIndex()) - SHORT_PRESS ) / ( LONG_PRESS - SHORT_PRESS ), 0, 1 );
	}

	public static function beforeUpdate() {
		GamePad.update();

		if( GC!=null ) {
			if( hasAnyPress ) {
				hasAnyPress = false;
				framePresses = new Map();
			}

			updateLongPress(A);
			updateLongPress(B);
			updateLongPress(X);
			updateLongPress(Y);
			updateLongPress(START);
			updateLongPress(DPAD_DOWN);
		}
	}
}
