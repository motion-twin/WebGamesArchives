package m;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import mt.deepnight.mui.VGroup;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Color;
import mt.deepnight.Lib;
import mt.MLib;
import mt.Metrics;
import ui.*;

@:bitmap("screenshots/map.jpg") class GfxScreenMap extends BitmapData {}
@:bitmap("screenshots/colors.jpg") class GfxScreenColors extends BitmapData {}
@:bitmap("screenshots/thunder.jpg") class GfxScreenThunder extends BitmapData {}
@:bitmap("screenshots/kick.jpg") class GfxScreenKick extends BitmapData {}
@:bitmap("screenshots/killers.jpg") class GfxScreenKiller extends BitmapData {}

class BuyScreen extends MenuBase {
	static var STIMER = Const.seconds(2.5);

	var buyBt		: BuyButton;
	var restoreBt	: SmallMenuButton;
	var back		: Button;
	var beer		: BSprite;
	var mask		: Bitmap;
	var textMask	: Bitmap;

	var screenshots	: Array<{ bmp:Bitmap, txt:String }>;
	var texts		: Bitmap;
	var curScreen	: Int;
	var swrapper	: Sprite;
	var backToMap	: Bool;

	var prev		: ArrowButton;
	var next		: ArrowButton;

	public function new(?backToMap=false) {
		super();
		this.backToMap = backToMap;
		screenshots = [];
		curScreen = 0;

		mask = new Bitmap( new BitmapData(getWidth(), getHeight(), true, Color.addAlphaF(Const.BG_COLOR, 0.8)) );
		wrapper.addChild(mask);

		root.addEventListener( flash.events.TransformGestureEvent.GESTURE_SWIPE, onSwipe );

		swrapper = new Sprite();
		wrapper.addChild(swrapper);
		var slist = [
			{ bd:new GfxScreenMap(0,0), txt:Lang.BuyScreenMap },
			{ bd:new GfxScreenColors(0,0), txt:Lang.BuyScreenColors },
			{ bd:new GfxScreenThunder(0,0), txt:Lang.BuyScreenOriginal1 },
			{ bd:new GfxScreenKick(0,0), txt:Lang.BuyScreenOriginal2 },
			{ bd:new GfxScreenKiller(0,0), txt:Lang.BuyScreenDevs },
		];
		for(sinf in slist) {
			var source = new Bitmap(sinf.bd);
			source.filters = [
				new flash.filters.GlowFilter(0xFFFFFF,1, 8,8, 100, 1,true),
				new flash.filters.GlowFilter(0x0,0.6, 16,16),
			];
			var bmp = Lib.flatten(source, 16);
			swrapper.addChild(bmp);
			bmp.alpha = 0;
			bmp.scaleX = bmp.scaleY = 0.55;
			screenshots.push({ bmp:bmp, txt:sinf.txt });
			source.bitmapData.dispose();
			source.bitmapData = null;
		}
		cd.set("autoNext", STIMER);

		prev = new ArrowButton(wrapper, false, showPrev);
		next = new ArrowButton(wrapper, true, showNext);

		beer = Global.ME.tiles.get("beerEdition");
		wrapper.addChild(beer);

		back = new BackButton(wrapper, onBack);
		buyBt = new BuyButton(wrapper, Lang.LoadingPrice, onBuyLocked);
		restoreBt = new SmallMenuButton(wrapper, Lang.RestoreShort, onRestore);

		textMask = new Bitmap( new BitmapData(getWidth(), 32, true, Color.addAlphaF(0x2F0000, 0.75)) );
		wrapper.addChild(textMask);

		IapMan.ME.loadProducts(onProducts);

		onResize();
		showScreen(curScreen, true);
		tw.completeAll();
	}

	override function unregister() {
		root.removeEventListener( flash.events.TransformGestureEvent.GESTURE_SWIPE, onSwipe );

		super.unregister();

		for(s in screenshots) {
			s.bmp.bitmapData.dispose();
			s.bmp.bitmapData = null;
		}
		screenshots = null;

		prev.destroy();
		next.destroy();

		beer.dispose();
	}


	function onProducts(success:Bool) {
		if( buyBt!=null )
			buyBt.destroy();

		var price = IapMan.ME.getUnlockPrice();
		if( price==null )
			buyBt = new BuyButton(wrapper, Lang.ProductNotAvailable, onBuyLocked);
		else {
			//price = StringTools.replace(price, String.fromCharCode(160), " ");
			//buyBt = new BuyButton(wrapper, Lang.BuyButton({ _price:price }), onBuy);
			buyBt = new BuyButton(wrapper, Lang.BuyPage, onBuy);
		}
		restoreBt.wrapper.parent.addChild(restoreBt.wrapper);
		onResize();
	}


	function onSwipe(e:flash.events.TransformGestureEvent) {
		if( e.offsetX==-1 )
			showNext();
		else if( e.offsetX==1 )
			showPrev();
	}

	inline function showNext() {
		showScreen(curScreen+1, true);
		cd.set("autoNext", STIMER*2);
	}

	inline function showPrev() {
		showScreen(curScreen-1, false);
		cd.set("autoNext", STIMER*2);
	}


	function showScreen(id, next:Bool) {
		if( id>=screenshots.length )
			id = 0;
		if( id<0 )
			id = screenshots.length-1;

		var dir = next?1:-1;
		curScreen = id;

		if( texts!=null ) {
			var bmp = texts;
			tw.create(bmp.x, bmp.x-50*dir, 500);
			tw.create(bmp.alpha, 0, 500).onEnd = function() {
				bmp.bitmapData.dispose();
				bmp.bitmapData = null;
				bmp.parent.removeChild(bmp);
			}
			texts = null;
		}

		for(i in 0...screenshots.length) {
			var s = screenshots[i];
			tw.terminateWithoutCallbacks(s.bmp.x);
			tw.terminateWithoutCallbacks(s.bmp.alpha);
			var x = 10;
			if( id==i ) {
				// Appear
				s.bmp.rotation = Lib.rnd(-3, -1);
				s.bmp.x = x + 200*dir;
				s.bmp.y = Lib.rnd(5,15);

				tw.create(s.bmp.alpha, 1, 300);
				tw.create(s.bmp.x, x, 300);

				// Texts
				var tf = Global.ME.createField(s.txt, FBig, true);
				tf.textColor = 0xFFFF80;
				tf.filters = [
					new flash.filters.DropShadowFilter(1,90, 0xD76600,1, 0,0),
					new flash.filters.GlowFilter(0x2F0A00,1, 2,2,10),
					new flash.filters.GlowFilter(Const.BG_COLOR,0.6, 8,8,1),
					//new flash.filters.GlowFilter(0xFF7900,0.6, 8,8,1),
				];
				texts = Lib.flatten(tf, 16);
				wrapper.addChild(texts);
				texts.bitmapData = Lib.scaleBitmap(texts.bitmapData, 2, true);
				texts.x = getWidth()*0.5 - texts.width*0.5;
				texts.y = getHeight()*0.68 - texts.height*0.5;
				tw.create(texts.alpha, 0>1, 1000);
				fx.textLine(texts.y+45, -dir);
				textMask.y = texts.y+40;
			}
			else {
				// Disappear
				tw.create(s.bmp.alpha, 0, 500);
				tw.create(s.bmp.x, x-200*dir, 300);
			}
		}

	}


	function onCancel() {
		resume();
	}

	function onSuccess(productId:String) {
		Global.ME.run(this, function() new Thanks(true), false);
	}

	function onFail(err:String) {
		fx.flashBang(0xFF0000, 1, 1000);
		resume();
	}

	function onBuy() {
		//fx.flashBang(0xFFAC00, 0.75, 1000);
		pause();
		Global.SBANK.UI_valide(1);
		IapMan.ME.buy(onSuccess, onFail, onCancel);
	}

	function onRestore() {
		new Restore(this);
	}

	function onBuyLocked() {
		fx.flashBang(0xFF0000, 0.75, 1000);
		Global.SBANK.UI_select(1);
	}


	override function onBackKey() {
		super.onBackKey();
		onBack();
	}

	function onBack() {
		if( backToMap )
			Global.ME.run(this, function() new StageSelect(-1), true);
		else
			Global.ME.run(this, function() new Intro(), false);

		Global.SBANK.UI_back(1);
	}

	override function onResize() {
		super.onResize();

		if( mask==null )
			return;

		mask.width = getWidth();
		mask.height = getHeight();

		if( buyBt!=null ) {
			buyBt.x = Std.int( getWidth()*0.4-buyBt.getWidth()*0.5 );
			buyBt.y = Std.int( getHeight()*0.87-buyBt.getHeight()*0.5 );
		}

		restoreBt.x = Std.int( getWidth()-restoreBt.getWidth()-5 );
		restoreBt.y = Std.int( getHeight()*0.87-restoreBt.getHeight()*0.5 );

		prev.y = getHeight()*0.5 - prev.getHeight()*0.5;
		next.x = getWidth() - next.getWidth();
		next.y = getHeight()*0.5 - next.getHeight()*0.5;

		var sy = getHeight()*0.4/beer.getBitmapDataReadOnly().height;
		beer.scaleX = beer.scaleY = sy;
		beer.x = Std.int(getWidth()*0.75 - beer.width*0.5);
		beer.y = 2;
	}


	override function update() {
		super.update();

		if( time%2==0 ) {
			// Button
			var w = buyBt.getWidth();
			var h = buyBt.getHeight();
			fx.blingBling(buyBt.x+w*0.25, buyBt.y+h*0.2, w*0.5, h*0.7);

			// Beer
			fx.blingBling(beer.x, beer.y, beer.width, beer.height);
		}

		if( !cd.has("autoNext") ) {
			cd.set("autoNext", STIMER);
			showScreen(curScreen+1, true);
		}
	}
}

