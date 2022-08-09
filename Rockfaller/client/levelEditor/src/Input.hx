package ;

import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;

/**
 * ...
 * @author Tipyx
 */
class Input
{
	public var left:Bool = false;
	public var right:Bool = false;
	public var a:Bool = false;
	public var p:Bool = false;
	
	public function new() 
	{
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	private function onKeyDown(e:KeyboardEvent):Void {
		if (e.keyCode == Keyboard.LEFT)		left = true;
		if (e.keyCode == Keyboard.RIGHT)	right = true;
		if (e.keyCode == Keyboard.A)		a = true;
		if (e.keyCode == Keyboard.P)		p = true;
	}
	
	private function onKeyUp(e:KeyboardEvent):Void {
		if (e.keyCode == Keyboard.LEFT)		left = false;
		if (e.keyCode == Keyboard.RIGHT)	right = false;
		if (e.keyCode == Keyboard.A)		a = false;
		if (e.keyCode == Keyboard.LEFT)		LE.ME.goToLevel(LE.ME.actualLevel.level - 1);
		if (e.keyCode == Keyboard.RIGHT)	LE.ME.goToLevel(LE.ME.actualLevel.level + 1);
		if (e.keyCode == Keyboard.P)		p = false;
	}
	
	public function destroy() {
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
}