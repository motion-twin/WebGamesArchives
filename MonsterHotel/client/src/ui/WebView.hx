package ui;

#if mBase
import mtnative.webview.WebView;

class WebView extends H2dProcess {
	public static var CURRENT : WebView;

	var ctrap			: h2d.Interactive;
	var back			: h2d.Interactive;
	var shadow			: h2d.Bitmap;
	var web				: mtnative.webview.WebView;
	var barWid			: Float;

	public function new(url:String) {
		CURRENT = this;
		super();
		Main.ME.uiWrapper.add(root, Const.DP_WEBVIEW);

		if( url.charAt(0)!="/" ) url = "/"+url;
		url = App.current.makeSiteUrl( url );

		barWid = mt.Metrics.cm2px(0.8);
		Game.ME.pause();
		Main.ME.gameWrapper.visible = false;
		SoundMan.mute();

		ctrap = new h2d.Interactive(4,4, root);
		ctrap.backgroundColor = alpha(Const.BLUE);

		back = new h2d.Interactive(barWid, barWid, root);
		back.onClick = onClose;

		var btWid = barWid*0.9;
		//var e = Assets.tiles.h_get("sideIconOff", 0, 0.5,0.5, true, root);
		//e.setPos(barWid*0.5, barWid*0.5);
		//e.constraintSize(btWid);
		//e.scaleX*=-1;
		var e = Assets.tiles.h_get("iconRemove", 0, 0.5,0.5, true, root);
		e.setPos(barWid*0.5, barWid*0.5);
		e.constraintSize(btWid*0.8);
		e.scaleX*=-1;

		shadow = Assets.tiles.getColoredH2dBitmap("white", 0x393160, 1, root);

		#if mBase
		web = new mtnative.webview.WebView();
		App.current.configureDefaultWebView( web );
		web.loadUrl(url);
		#end

		onResize();
	}

	function onClose(_) {
		destroy();
	}

	override function onResize() {
		super.onResize();

		shadow.setSize( mt.Metrics.pixelDensity(), h() );
		shadow.x = barWid-shadow.width;
		ctrap.setSize(w(), h());
		web.setRectangle(barWid,0, w()-barWid, h());
	}


	public function onBack() {
		destroy();
	}


	override function onDispose() {
		super.onDispose();

		ctrap = null;
		back = null;
		shadow = null;

		web.destroy();
		web = null;

		SoundMan.unmute();
		if( Game.ME!=null )
			Game.ME.resume();

		if( Main.ME.gameWrapper!=null )
			Main.ME.gameWrapper.visible = true;

		if( CURRENT==this )
			CURRENT = null;
	}
}

#else

class WebView extends H2dProcess {
	public function new(url:String) {
		super();
		new ui.Notification(Lang.untranslated("Not supported on this device"));
		new ui.Notification(Lang.untranslated(url));
		onNextUpdate = destroy;
	}
}

#end
