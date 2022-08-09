package;

import flash.events.Event;
import openfl.display.Sprite;
import openfl.display.Graphics;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import mt.deepnight.slb.*;

import Protocol;

import data.Settings;
import data.LevelDesign;
import data.DataManager;
import manager.LifeManager;

/**
 * ...
 * @author Tipyx
 */

class PreloaderOFL extends NMEPreloader
{
	public static var ME			: PreloaderOFL;
	
	var slb							: BLib;
	
	var logo						: flash.display.MovieClip;
	var loadingBar					: BSprite;
	var loadingFill					: BSprite;
	var logoMT						: BSprite;
	
	var base						: Float;
	var actualLoadedPrct			: Float;

	public function new() 
	{
		super();
		
		Settings.SET();
		
		mt.deepnight.Lib.redirectTracesToConsole();
		
		ME = this;
		
		removeChildren();
		
		slb = mt.deepnight.slb.assets.TexturePacker.importXml("loader.xml", true);
		
		slb.initBdGroups();
		
		logo = new gfx.Logo();
		logo.x = Std.int(mt.Metrics.w() * 0.5);
		logo.y = Std.int(mt.Metrics.h() * 0.3);
		logo.scaleX = logo.scaleY = 1.5;
		this.addChild(logo);
		
		openfl.Lib.current.stage.color = 0x05060B;
		
		base = 0;
		
		logoMT = slb.get("logoMT");
		logoMT.setCenterRatio(0.5, 0.5);
		logoMT.x = Std.int(mt.Metrics.w() * 0.5);
		logoMT.y = Std.int(mt.Metrics.h() * 0.7);
		this.addChild(logoMT);
		
		loadingFill = slb.get("progressBarBg");
		loadingFill.setCenterRatio(0.5, 0.5);
		loadingFill.x = Std.int(mt.Metrics.w() * 0.5);
		loadingFill.y = Std.int(logoMT.y + logoMT.height);
		this.addChild(loadingFill);
		
		loadingBar = slb.get("progressBar");
		loadingBar.setCenterRatio(0.5, 0.5);
		loadingBar.x = loadingFill.x;
		loadingBar.y = loadingFill.y;
		this.addChild(loadingBar);
		loadingBar.scaleX = 0;
		
		addEventListener(flash.events.Event.ENTER_FRAME, update);
	//	START LOADING
		Protocol.init();
	}
	
	var start : {loaded: Int, total: Int, t: Float} = null;
	override public function onUpdate(bytesLoaded:Int, bytesTotal:Int) {
		if( start == null ){
			trace(bytesLoaded);
			start = {
				loaded: bytesLoaded,
				total: bytesTotal,
				t: haxe.Timer.stamp()
			};
		}
		
		actualLoadedPrct = (bytesLoaded / bytesTotal);
		loadingBar.scaleX = actualLoadedPrct + base;
		
		super.onUpdate(bytesLoaded, bytesTotal);
	}
	
	override public function onLoaded() {
		loadingBar.dispose();
		loadingBar = null;
		
		loadingFill.dispose();
		loadingFill = null;
		
		logoMT.dispose();
		logoMT = null;
		
		slb.destroy();
		slb = null;
		
		ME = null;
		
		removeEventListener(flash.events.Event.ENTER_FRAME, update);
		
		if( start != null ){
			var t = haxe.Timer.stamp();
			var tdiff:Float = t-start.t;
			var bdiff:Int = start.total-start.loaded;
			var o = {};
			Reflect.setField(o,"seconds",tdiff);
			Reflect.setField(o,"bytes",bdiff);
			mt.device.EventTracker.twTrack("clientDownloadStats",o);
		}
		
		super.onLoaded();
	}
	
	function update(e:Event):Void {
		
		slb.updateChildren();
	}
}