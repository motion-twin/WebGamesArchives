package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.mui.VGroup;
import mt.deepnight.mui.HGroup;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Lib;
import mt.MLib;
import mt.Metrics;
import ui.*;

@:bitmap("assets/otherGames/braziball.png") class GfxBraziball extends BitmapData {}

class MoreGames extends MenuBase {
	static var GAMES = [
		//{ name:"Hordes Zero", bmp:new Bitmap(new GfxBraziball(0,0)), ios:null, android:null },
		{ name:"Braziball", bd:new GfxBraziball(0,0), ios:"https://itunes.apple.com/us/app/braziball-puzzle/id882440210?l=fr&ls=1&mt=8", android:"market://details?id=air.com.motiontwin.Braziball" },
	];

	var back		: BackButton;
	var title		: MenuLabel;
	var menu		: VGroup;

	public function new() {
		super();

		title = new MenuLabel(wrapper, Lang.OurGames, 3);

		menu = new VGroup(wrapper);
		menu.removeBorders();
		menu.margin = 5;

		for( game in GAMES ) {
			if( Lib.isIos() && game.ios==null || Lib.isAndroid() && game.android==null )
				continue;

			var g = new HGroup(menu);
			g.color = 0x111C26;

			var left = new VGroup(g);
			left.removeBorders();
			var l = new MenuLabel(left, game.name, 2);
			l.setStyle(LS_Gold);
			new MediumMenuButton(left, Lang.Install, function() {
				Ga.pageview("/extern/ad/"+game.name);
				var url = Lib.isAndroid() ? game.android : game.ios;
				flash.Lib.getURL(new flash.net.URLRequest(url));
			});

			var bmp = new Bitmap(game.bd);
			new mt.deepnight.mui.Image(g, bmp, function() {
				bmp.bitmapData = null;
				bmp = null;
			});
		}

		menu.separator(true);
		new BigMenuButton(menu, Lang.OurWebGames, onWebGames );

		back = new BackButton(wrapper, onBack);

		onResize();
	}

	function onWebGames() {
		Ga.pageview("/extern/ad/web");
		flash.Lib.getURL( new flash.net.URLRequest("http://twinoid.com") );
	}

	override function onBackKey() {
		super.onBackKey();
		onBack();
	}

	override function unregister() {
		super.unregister();

		title.destroy();
		menu.destroy();
		back.destroy();
	}

	function onBack() {
		Global.SBANK.UI_back(1);
		Global.ME.run(this, function() new Intro(), false);
	}

	override function onResize() {
		super.onResize();

		if( menu==null )
			return;

		menu.x = Std.int(getWidth()*0.5-menu.getWidth()*0.5);
		menu.y = Std.int(getHeight()*0.5-menu.getHeight()*0.5);

		title.x = Std.int(getWidth()*0.5-title.getWidth()*0.5);
		title.y = menu.y - title.getHeight()-10;
	}
}