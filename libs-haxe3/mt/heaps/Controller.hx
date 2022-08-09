package mt.heaps;

import mt.heaps.GamePad;
import hxd.Key;

enum Mode {
	Keyboard;
	Pad;
}

@:allow(mt.heaps.ControllerAccess)
class Controller {
	static var UNIQ_ID = 0;
	static var LONG_PRESS = 0.35; // seconds
	static var SHORT_PRESS = 0.17; // seconds
	static var ALL = [];
	
	var mode : Mode = Keyboard;
	var exclusiveId : String = null;
	var gc : GamePad;
	var suspendTimer = 0.;
	
	var isLocked = false;
	public var allowAutoSwitch = true;

	var primary : Map<Int,Int> = new Map();
	var secondary : Map<Int,Int> = new Map();
	var third : Map<Int,Int> = new Map();
	
	public function new( s2d : h2d.Scene ){
		ALL.push( this );
		gc = new GamePad(0.4);
		/*
		gc.onAnyControl = function() {
			if( allowAutoSwitch && mode!=Pad )
				mode = Pad;
		}
		*/
		s2d.addEventListener( function(e:hxd.Event) {
			if( allowAutoSwitch && e.kind==EMove && mode!=Keyboard )
				mode = Keyboard;
		});
	}
	
	public inline function setKeyboard() mode = Keyboard;
	public inline function setGamePad() mode = Pad;
	
	//public inline function toggleInvert(axis:PadKey) return gc.toggleInvert(axis);

	public function bind(k:PadKey, keyboardKey:Int, ?alternate1:Int, ?alternate2:Int) {
		primary.set(k.getIndex(), keyboardKey);

		if( alternate1!=null )
			secondary.set(k.getIndex(), alternate1);

		if( alternate2!=null )
			third.set(k.getIndex(), alternate2);
	}

	public inline function getPrimaryKey(k:PadKey) : Null<Int> {
		return primary.get( k.getIndex() );
	}
	public inline function getSecondaryKey(k:PadKey) : Null<Int> {
		return secondary.get( k.getIndex() );
	}
	public inline function getThirdKey(k:PadKey) : Null<Int> {
		return third.get( k.getIndex() );
	}
	
	public function lock() isLocked = true;
	public function unlock() {
		if( isLocked ) {
			isLocked = false;
			suspendTemp();
		}
	}
	
	inline function suspendTemp(?sec=0.2) {
		suspendTimer = haxe.Timer.stamp() + sec;
	}
	
	public function createAccess( id:String, ?exclusive=false ){
		return new ControllerAccess(this,id,exclusive);
	}
	
	var pressTimers : Map<Int,Float> = new Map();
	var framePresses : Map<Int,Int> = new Map();
	var longPressLock : Map<Int,Bool> = new Map();
	var hasAnyPress = false;

	function updateLongPress(k:PadKey) {
		var idx = k.getIndex();
		if( !pressTimers.exists(idx) )
			pressTimers.set(idx,-1);

		if( gc.isDown(k) || Key.isDown(getPrimaryKey(k)) || Key.isDown(getSecondaryKey(k)) || Key.isDown(getThirdKey(k)) ) {
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

	public static function beforeUpdate() {
		GamePad.update();
		
		for( c in ALL )
			if( c.gc!=null ) {
				if( c.hasAnyPress ) {
					c.hasAnyPress = false;
					c.framePresses = new Map();
				}

				c.updateLongPress(A);
				c.updateLongPress(B);
				c.updateLongPress(X);
				c.updateLongPress(Y);
				c.updateLongPress(START);
				c.updateLongPress(DPAD_DOWN);
			}
	}
	
}

@:allow(mt.heaps.Controller)
class ControllerAccess {
	
	var parent : Controller;

	public var mode(get,never) : Mode; inline function get_mode() return parent.mode;
	var id : String;
	var manualLock = false;

	function new(parent:Controller, id:String, ?exclusive=false) {
		this.parent = parent;
		this.id = id + (Controller.UNIQ_ID++);
		parent.suspendTemp(0.1);
		if( exclusive )
			takeExclusivity();
	}

	public inline function isKeyboard() return parent.mode==Keyboard;
	public inline function isGamePad() return parent.mode==Pad;

	public inline function lock() manualLock = true;
	public inline function unlock() manualLock = false;
	public inline function locked() return manualLock || parent.isLocked || ( parent.exclusiveId!=null && parent.exclusiveId!=id ) || haxe.Timer.stamp()<parent.suspendTimer;


	public inline function isDown(k:PadKey)      return !locked() && ( isKeyboardDown(parent.getPrimaryKey(k)) || isKeyboardDown(parent.getSecondaryKey(k)) || isKeyboardDown(parent.getThirdKey(k)) || parent.gc.isDown(k) );
	public inline function isPressed(k:PadKey)   return !locked() && ( isKeyboardPressed(parent.getPrimaryKey(k)) || isKeyboardPressed(parent.getSecondaryKey(k)) || isKeyboardPressed(parent.getThirdKey(k)) || parent.gc.isPressed(k) );

	public inline function isShortPressed(k:PadKey)  return !locked() && parent.framePresses.get(k.getIndex())==1;
	public inline function isLongPressed(k:PadKey)   return !locked() && parent.framePresses.get(k.getIndex())==2;
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
	public inline function dpadDownLongPressed()    return !locked() && parent.framePresses.get(DPAD_DOWN.getIndex())==2;
	public inline function dpadDownLongPressing()   return !locked() && getLongPressRatio(DPAD_DOWN)>0;
	public inline function dpadDownLongPressRatio() return getLongPressRatio(DPAD_DOWN);

	public inline function aDown()           return isDown(A);
	public inline function aPressed()        return isPressed(A);
	public inline function aShortPressed()   return !locked() && parent.framePresses.get(A.getIndex())==1;
	public inline function aLongPressed()    return !locked() && parent.framePresses.get(A.getIndex())==2;
	public inline function aLongPressing()   return !locked() && getLongPressRatio(A)>0;
	public inline function aLongPressRatio() return getLongPressRatio(A);

	public inline function bDown()           return isDown(B);
	public inline function bPressed()        return isPressed(B);
	public inline function bShortPressed()   return !locked() && parent.framePresses.get(B.getIndex())==1;
	public inline function bLongPressed()    return !locked() && parent.framePresses.get(B.getIndex())==2;
	public inline function bLongPressing()   return !locked() && getLongPressRatio(B)>0;
	public inline function bLongPressRatio() return getLongPressRatio(B);

	public inline function xDown()           return isDown(X);
	public inline function xPressed()        return isPressed(X);
	public inline function xShortPressed()   return !locked() && parent.framePresses.get(X.getIndex())==1;
	public inline function xLongPressed()    return !locked() && parent.framePresses.get(X.getIndex())==2;
	public inline function xLongPressing()   return !locked() && getLongPressRatio(X)>0;
	public inline function xLongPressRatio() return getLongPressRatio(X);
	public inline function xValue()          return parent.gc.getValue(AXIS_LEFT_X_POS);

	public inline function yDown()           return isDown(Y);
	public inline function yPressed()        return isPressed(Y);
	public inline function yShortPressed()   return !locked() && parent.framePresses.get(Y.getIndex())==1;
	public inline function yLongPressed()    return !locked() && parent.framePresses.get(Y.getIndex())==2;
	public inline function yLongPressing()   return !locked() && getLongPressRatio(Y)>0;
	public inline function yLongPressRatio() return getLongPressRatio(Y);
	public inline function yValue()          return parent.gc.getValue(AXIS_LEFT_Y_POS);

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


	public inline function takeExclusivity()  parent.exclusiveId = id;

	public inline function releaseExclusivity() {
		if( parent.exclusiveId==id ) {
			parent.exclusiveId = null;
			parent.suspendTemp();
		}
	}

	public inline function isKeyboardDown(k:Null<Int>)     return k!=null && !locked() && Key.isDown(k);
	public inline function isKeyboardUp(k:Null<Int>)       return k!=null && !locked() && !Key.isDown(k);
	public inline function isKeyboardPressed(k:Null<Int>)  return k!=null && !locked() && Key.isPressed(k);

	public function dispose() {
		releaseExclusivity();
		parent.suspendTemp();
	}


	public inline function getLongPressRatio(k:PadKey) : Float {
		if( parent.framePresses.exists(k.getIndex()) || parent.pressTimers.get(k.getIndex())<0 )
			return 0;

		return MLib.fclamp( ( haxe.Timer.stamp()-parent.pressTimers.get(k.getIndex()) - Controller.SHORT_PRESS ) / ( Controller.LONG_PRESS - Controller.SHORT_PRESS ), 0, 1 );
	}

}
