package m;

import flash.display.Sprite;
import mt.deepnight.mui.Group;
import mt.deepnight.mui.VGroup;
import mt.deepnight.mui.HGroup;
import mt.deepnight.slb.BSprite;
import mt.MLib;
import mt.Metrics;
import ui.*;

class LangSelect extends MenuBase {
	var menu		: Group;
	var back		: BackButton;

	public function new() {
		super();

		menu = new VGroup(wrapper);
		menu.removeBorders();
		menu.margin = 3;

		back = new BackButton(wrapper, onBack);

		var old = playerCookie.data.lang;
		var g = new HGroup(menu);
		g.removeBorders();
		var langs = ["fr", "en", "es", "de", "pt", "hu", "it", "ru", "tr"];
		for(k in langs) {
			if( g.countChildren()>=3 ) {
				g = new HGroup(menu);
				g.removeBorders();
			}
			try {
				Global.ME.setLang(k, true);
			}
			catch(e:Dynamic) {
				popUp("Couldn't read language file : "+k);
			}
			new SmallMenuButton(g, Lang.Language, onSelect.bind(k));
		}
		Global.ME.setLang(old, true);

		var tg = new TextGroup(menu);
		tg.addText("Do you want to help us out? Give us a hand translating our game!", 40);
		new BigMenuButton(menu, "Contact us!", onContact);

		onResize();
	}

	function onContact() {
		var subject = flash.system.Capabilities.language.toUpperCase()+" translation";
		flash.Lib.getURL( new flash.net.URLRequest("mailto:uppercup@motion-twin.com?subject="+subject) );
	}

	override function onBackKey() {
		super.onBackKey();
		onBack();
	}

	function onSelect(id:String) {
		Global.ME.setLang(id);
		onBack();
	}

	function onBack() {
		Global.SBANK.UI_back(1);
		Global.ME.run(this, function() new Settings(false), true);
	}


	override function unregister() {
		super.unregister();

		menu.destroy();
		back.destroy();
	}

	override function onResize() {
		super.onResize();

		if( menu==null )
			return;

		menu.forceRenderNow();
		menu.x = Std.int(getWidth()*0.5-menu.getWidth()*0.5);
		menu.y = Std.int(getHeight()*0.5-menu.getHeight()*0.5);
	}
}