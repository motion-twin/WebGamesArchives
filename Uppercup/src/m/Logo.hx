package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import mt.MLib;
import mt.Metrics;
import ui.*;

@:bitmap("assets/mt.png") class GfxLogo extends flash.display.BitmapData {}
@:bitmap("assets/mtHollow.png") class GfxLogoHollow extends flash.display.BitmapData {}

class Logo extends MenuBase {
	//var logo		: BSprite;
	//var sheet		: BLib;
	var logo		: Bitmap;
	var logoHollow	: Bitmap;
	var done		: Bool;

	public function new() {
		super(false);
		done = false;

		bg.bitmapData.fillRect( bg.bitmapData.rect, 0x0 );

		root.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, onMouseDown );

		logoHollow = new Bitmap( new GfxLogoHollow(0,0) );
		wrapper.addChild(logoHollow);
		logoHollow.visible = false;
		logoHollow.scaleX = logoHollow.scaleY = 0.6;

		logo = new Bitmap( new GfxLogo(0,0) );
		wrapper.addChild(logo);
		logo.visible = false;
		logo.scaleX = logo.scaleY = 0.6;

		if( playerCookie.data.music )
			Global.ME.startMusic();
		else
			Global.ME.stopMusic();
		delayer.add( onComplete, 3100 );

		onResize();

		delayer.add(run, 100);
		Main.disableFrameSkip();

		gaPageName = null;
		Ga.pageview("/app/version/"+Global.ME.getVersion());
		#if press
		Ga.event("general", "launch", "press");
		#elseif webDemo
		Ga.event("general", "launch", "webDemo");
		#else
		Ga.event("general", "launch", "mobile");
		#end
	}

	function run() {
		fx.logo(logo, logoHollow, this);
	}

	override function unregister() {
		root.removeEventListener( flash.events.MouseEvent.MOUSE_DOWN, onMouseDown );

		super.unregister();

		logo.bitmapData.dispose();
		logo.bitmapData = null;
		logo = null;

		logoHollow.bitmapData.dispose();
		logoHollow.bitmapData = null;
		logoHollow = null;

		Main.enableFrameSkip();
	}

	function onMouseDown(_) {
		onComplete();
	}

	function onComplete() {
		if( done )
			return;

		done = true;
		Global.SBANK.public_but().playOnChannel(Crowd.CHANNEL, 0.5);
		Global.ME.run(this, function() new Intro(), false);
	}

	override function onResize() {
		super.onResize();

		if( logo==null )
			return;

		logo.x = Std.int(getWidth()*0.5 - logo.width*0.5);
		logo.y = Std.int(getHeight()*0.5 - logo.height*0.5);
		logoHollow.x = Std.int(getWidth()*0.5 - logoHollow.width*0.5);
		logoHollow.y = Std.int(getHeight()*0.5 - logoHollow.height*0.5);
	}
}