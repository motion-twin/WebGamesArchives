import flash.display.Bitmap;
import mt.flash.Timer;

@:bitmap("assets/splash.png") class GfxSplash extends flash.display.BitmapData {}

class Main {
	static var ACTIVE = true;
	static var GLOBAL : m.Global;

	static var snap : Bitmap;
	static var deltaTime = 0.0;
	static var splash : Bitmap;
	static var frameSkip = true;

	public static function main() {
		#if webDemo
		flash.Lib.current.stage.quality = flash.display.StageQuality.MEDIUM;
		#else
		flash.Lib.current.stage.quality = flash.display.StageQuality.LOW;
		#end
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

		splash = new Bitmap(new GfxSplash(0,0));
		flash.Lib.current.addChild(splash);

		flash.Lib.current.stage.addEventListener( flash.events.Event.RESIZE, onResize );
		onResize(null);

		haxe.Timer.delay(init, #if prod 300 #else 50 #end);
	}

	static function init() {
		flash.Lib.current.stage.addEventListener( flash.events.Event.DEACTIVATE, onDeactivate);
		flash.Lib.current.stage.addEventListener( flash.events.Event.ACTIVATE, onActivate);
		flash.Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, update );
		#if prod
		//flash.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener( flash.events.UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError );
		#end

		start();
	}

	static function onUncaughtError(e:flash.events.UncaughtErrorEvent) {
		trace("uncaugh "+e.text);
		e.stopPropagation();
		e.preventDefault();

		var processList = mt.deepnight.Process.GLOBALS.filter( function(p) {
			return p!=m.Global.ME && p!=m.IapMan.ME;
		});


		// Send report
		var report = e.errorID+" "+e.error+" "+flash.system.Capabilities.version+" "+processList.join("_");
		var r = new haxe.Http("http://"+Const.DOMAIN+"/tid/logError/?err="+StringTools.urlEncode(report));
		r.request(true);

		try {
			// Try to reboot
			for( p in processList )
				p.destroy();
			new m.Error(e.error);
		}
		catch(ec:Dynamic) {
			// Everything is lost!
			trace("Game crashed, sorry :(");
			trace("Reason : ");
			trace(e.errorID+" "+e.error);
			trace(ec);
		}
	}

	static function onResize(_) {
		if( splash.bitmapData!=null ) {
			var w = mt.Metrics.w();
			var h = mt.Metrics.h();
			var sx = w/splash.bitmapData.width;
			var sy = h/splash.bitmapData.height;
			splash.scaleX = splash.scaleY = mt.MLib.fmax(sx,sy);
			splash.x = Std.int(w*0.5 - splash.width*0.5);
			splash.y = Std.int(h*0.5 - splash.height*0.5);
		}
	}

	static function start() {
		GLOBAL = new m.Global( flash.Lib.current );
		splash.bitmapData.dispose();
		splash.bitmapData = null;
	}

	static function onDeactivate(_) {
		if( !ACTIVE )
			return;

		ACTIVE = false;
		flash.Lib.current.removeEventListener( flash.events.Event.ENTER_FRAME, update );
		Timer.pause();

		snap = mt.deepnight.Lib.flatten(GLOBAL.root);
		var ct = new flash.geom.ColorTransform();
		ct.color = Const.BG_COLOR;
		ct.alphaMultiplier = 0.8;
		snap.bitmapData.colorTransform(snap.bitmapData.rect, ct);

		flash.Lib.current.addChild(snap);
		flash.system.System.pauseForGCIfCollectionImminent(0.1);
	}

	static function onActivate(_) {
		if( ACTIVE )
			return;

		ACTIVE = true;
		flash.Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, update );
		Timer.resume();

		snap.bitmapData.dispose();
		snap.bitmapData = null;
		snap.parent.removeChild(snap);
		snap = null;

		GLOBAL.root.visible = ACTIVE;
	}


	public static function disableFrameSkip() {
		frameSkip = false;
	}
	public static function enableFrameSkip() {
		frameSkip = true;
	}


	static function update(_) {
		Timer.update();
		deltaTime+=Timer.deltaT*0.2;

		var ideal = 1/Const.FPS;
		var frames = mt.MLib.floor( deltaTime/ideal );
		frames = mt.MLib.clamp(frames, 1, 3);
		#if video
		frames = 1;
		#end

		if( !frameSkip ) {
			deltaTime = Timer.deltaT;
			frames = 1;
		}

		var i = 0;
		while( i<frames ) {
			var render = i==frames-1;
			mt.deepnight.Process.updateAll(render);
			if( render )
				mt.deepnight.mui.Component.updateAll();
			deltaTime-=ideal;
			i++;
		}
		if( deltaTime<0 )
			deltaTime = 0;
	}
}