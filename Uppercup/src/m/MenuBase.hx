package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import mt.deepnight.Color;
import mt.deepnight.mui.Window;
import mt.deepnight.Lib;
import mt.deepnight.FParticle;
import mt.deepnight.slb.*;
import mt.MLib;
import mt.Metrics;
import ui.*;

class MenuBase extends mt.deepnight.FProcess {
	static var CACHED_BG		: BitmapData = null;

	public var wrapper		: Sprite;
	public var bgFxWrapper	: Sprite;
	public var fx			: MenuFx;
	public var bg			: Bitmap;
	public var tiles		: BLib;
	var playerCookie		: PlayerCookie;
	var musicOnActivate		: Bool;

	var gaPageName			: Null<String>;

	public function new(?hasStadiumBg=true, ?hasFadeIn=true) {
		gaPageName = "/app/menu/" + Type.getClassName(Type.getClass(this));

		super();

		musicOnActivate = true;
		tiles = Global.ME.tiles;
		playerCookie = Global.ME.playerCookie;

		if( hasStadiumBg ) {
			if( CACHED_BG==null )
				CACHED_BG = tiles.getBitmapData("stadium");

			bg = new Bitmap(CACHED_BG);
			root.addChild(bg);
		}
		else {
			bg = new Bitmap( new BitmapData(100,100, false, Const.BG_COLOR) );
			root.addChild(bg);
		}

		wrapper = new Sprite();
		root.addChild(wrapper);

		bgFxWrapper = new Sprite();
		wrapper.addChild(bgFxWrapper);

		fx = new MenuFx(this);

		try {
			flash.desktop.NativeApplication.nativeApplication.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onSoftKeyDown, true );
		} catch(e:Dynamic) {}
		flash.system.System.pauseForGCIfCollectionImminent(0.4);
		onResize();

		if( hasFadeIn )
			Global.ME.fadeIn();

		delayer.add( function() {
			if( gaPageName!=null )
				Ga.pageview( gaPageName );
		}, 50);
	}

	function popUp(str:String) {
		new PopUp(this, str);
	}

	function onSoftKeyDown(e:flash.events.KeyboardEvent) {
		switch( e.keyCode ) {
			case flash.ui.Keyboard.SEARCH :
				e.preventDefault();

			case flash.ui.Keyboard.MENU :
				e.preventDefault();
				if( !isFading() )
					onMenuKey();

			case flash.ui.Keyboard.BACK :
				e.preventDefault();
				if( !isFading() )
					onBackKey();
		}
	}

	inline function isFading() {
		return cd.has("fading");
	}

	override function onActivate() {
		super.onActivate();
		if( playerCookie.data.music && musicOnActivate )
			Global.ME.startMusic();
	}

	override function onDeactivate() {
		super.onDeactivate();
		Global.ME.stopMusic();
	}


	function onBackKey() {}
	function onMenuKey() {}


	public inline function isUnlocked() {
		#if press
		return true;
		#else
		return IapMan.ME.isUnlocked();
		#end
	}


	override function unregister() {
		super.unregister();

		try {
			flash.desktop.NativeApplication.nativeApplication.removeEventListener( flash.events.KeyboardEvent.KEY_DOWN, onSoftKeyDown, true );
		} catch(e:Dynamic) {}
		fx.destroy();
	}

	public inline function getWidth() return MLib.ceil( Const.WID/Const.UPSCALE );
	public inline function getHeight() return MLib.ceil( Const.HEI/Const.UPSCALE );

	override function onResize() {
		super.onResize();

		var w = getWidth();
		var h = getHeight();

		var sx = Const.HEI/bg.bitmapData.height;
		var sy = Const.WID/bg.bitmapData.width;
		bg.scaleX = bg.scaleY = MLib.fmax(sx,sy);
		bg.x = Const.WID*0.5 - bg.width*0.5;

		wrapper.scaleX = wrapper.scaleY = Const.UPSCALE;
	}

	//inline function rnd(min,max,?sign) { return Lib.rnd(min,max,sign); }
	//inline function irnd(min,max,?sign) { return Lib.irnd(min,max,sign); }

	override function update() {
		super.update();
		fx.update();
	}

	override function render() {
		super.render();
		tiles.updateChildren();
	}
}