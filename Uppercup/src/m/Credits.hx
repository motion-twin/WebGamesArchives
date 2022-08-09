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

class Credits extends MenuBase {

	var back		: BackButton;
	var menu		: VGroup;

	public function new() {
		super();

		menu = new VGroup(wrapper);
		menu.removeBorders();
		menu.margin = 20;

		var all = [
			{ label:Lang.CreditDev, name:"Motion Twin", url:"http://motion-twin.com", twitter:"motiontwin", fb:"motiontwin" },
			{ label:Lang.CreditMusic, name:"El Mobo", url:"http://elmobo.bandcamp.com", twitter:"elmobo", fb:"elmobo" },
		];

		for( e in all ) {
			var g = new VGroup(menu);
			g.removeBorders();
			g.margin = 0;
			new MenuLabel(g, e.label, 2);

			var hg = new HGroup(g);
			hg.removeBorders();
			var l = new MenuLabel(hg, e.name, 3);
			l.setStyle(LS_Gold);
			l.setWidth(200);
			l.setHAlign(Left);

			new UrlTinyButton(hg, tiles.get("btnLink"), e.url);
			new UrlTinyButton(hg, tiles.get("btnTwitter"), "https://twitter.com/"+e.twitter);
			new UrlTinyButton(hg, tiles.get("btnFb"), "https://facebook.com/"+e.fb);
		}

		new ui.MenuLabel(menu, Lang.Version+" "+Global.ME.getVersion());

		back = new BackButton(wrapper, onBack);

		onResize();
	}

	function openUrl(url:String) {
		var r = new flash.net.URLRequest(url);
		flash.Lib.getURL(r);
	}

	override function onBackKey() {
		super.onBackKey();
		onBack();
	}

	override function unregister() {
		super.unregister();

		menu.destroy();
		back.destroy();
	}

	function onBack() {
		Global.SBANK.UI_back(1);
		Global.ME.run(this, function() new Settings(false), false);
	}

	override function onResize() {
		super.onResize();

		if( menu==null )
			return;

		menu.x = Std.int(getWidth()*0.5-menu.getWidth()*0.5);
		menu.y = Std.int(getHeight()*0.5-menu.getHeight()*0.5);
	}

	override function update() {
		super.update();

		fx.godLight();
		fx.godSparks();
	}
}