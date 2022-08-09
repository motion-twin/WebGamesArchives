package ;

import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;

import Common;

import process.Game;
import process.Levels;
import data.Settings;

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
	
	var game	: process.Game;
	var levels	: process.Levels;

	public function new() 
	{
		this.game = Game.ME;
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	private function onKeyDown(e:KeyboardEvent):Void {
		this.game = Game.ME;
		this.levels = Levels.ME;
		
		if (game != null || levels != null) {
			if (e.keyCode == Keyboard.LEFT)		left = true;
			if (e.keyCode == Keyboard.RIGHT)	right = true;
			if (e.keyCode == Keyboard.A)		a = true;
			#if debug
			if (e.keyCode == Keyboard.P)		p = true;
			#end			
		}
	}
	
	private function onKeyUp(e:KeyboardEvent):Void {
		this.game = Game.ME;
		this.levels = Levels.ME;
		
		if (game != null || levels != null) {
			if (e.keyCode == Keyboard.LEFT)		left = false;
			if (e.keyCode == Keyboard.RIGHT)	right = false;
			if (e.keyCode == Keyboard.A)		a = false;
			#if debug
			if (e.keyCode == Keyboard.P)		p = false;
			if (e.keyCode == Keyboard.L) {
				//manager.SpecialManager.GEYSER_MOVE(4, true);
				//manager.SpecialManager.GEYSER();
			}
			if (e.keyCode == Keyboard.M) {
				//manager.SpecialManager.GEYSER_MOVE(7, false);
				//manager.SpecialManager.AR_GEYSER[0].reset();
			}
			if (e.keyCode == Keyboard.D)
				Main.ME.showDrawProfiler();
			if (e.keyCode == Keyboard.R)
				Main.ME.resetDrawProfiler();
			#if mBase
			if (e.keyCode == Keyboard.T)
				MobileServer.SEND_PROTOCOL( null );
			#end
			#end
		}
	}
	
	public function destroy() {
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
}
