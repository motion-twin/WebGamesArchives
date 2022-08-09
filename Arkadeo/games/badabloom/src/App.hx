package;

import flash.display.Sprite;
import flash.events.Event;
import haxe.Log;

#if nme
import nme.display.FPS;
#else
import openfl.display.FPS;
#end

class App extends Sprite 
{
	var inited:Bool;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		
		var g = new Game();
		addChild( g );

		addChild( new FPS(10, 10, 0xFFFFFF) );
		
		var log = new most.Log();
		log.y = 40;
		log.x = 0;
		Log.trace = log.trc;
		addChild( log );
	}

	/* SETUP */
	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.addChild(new App());
	}
}
