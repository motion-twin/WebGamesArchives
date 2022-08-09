package m;

import flash.display.Sprite;
import mt.deepnight.mui.Group;
import mt.deepnight.mui.VGroup;
import mt.deepnight.mui.HGroup;
import mt.deepnight.slb.BSprite;
import mt.MLib;
import mt.Metrics;
import ui.*;
import Const;

class CustomMatch extends MenuBase {
	var menu		: Group;
	var back		: BackButton;
	var title		: MenuLabel;

	public function new() {
		super();

		title = new MenuLabel(wrapper, Lang.QuickMatch);

		menu = new VGroup(wrapper);
		menu.removeBorders();
		menu.margin = 10;

		var all = [
			{ name:Lang.Easy+" I", d:0.1, v:Normal },
			{ name:Lang.Easy+" II", d:0.2, v:Normal },
			{ name:Lang.Normal+" I", d:0.3, v:Normal },
			{ name:Lang.Normal+" II", d:0.5, v:Normal },
			{ name:Lang.Hard+" I", d:0.4, v:Hard},
			{ name:Lang.Hard+" II", d:0.8, v:Hard},
			{ name:Lang.Epic+" I", d:0.75, v:Epic},
			{ name:Lang.Epic+" II", d:1, v:Epic},
		];

		var g = new HGroup(menu, 1);
		g.removeBorders();
		var i = 0;
		for( m in all ) {
			new SmallMenuButton(g, m.name, onStart.bind(m.d, m.v, m.name));
			i++;
			if( i%2==0 ) {
				g = new HGroup(menu, 1);
				g.removeBorders();
			}
		}

		back = new BackButton(wrapper, onBack);

		onResize();
	}

	override function onBackKey() {
		super.onBackKey();
		onBack();
	}

	override function unregister() {
		super.unregister();

		menu.destroy();
		title.destroy();
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
		menu.y = Std.int(getHeight()*0.6-menu.getHeight()*0.5);

		title.x = Std.int(getWidth()*0.5-title.getWidth()*0.5);
		title.y = menu.y - title.getHeight()-10;
	}


	function onSelectVariant(v:GameVariant) {
		Global.ME.variant = v;
		Global.ME.run(this, function() new CustomMatch(), false);
		Global.SBANK.UI_select(1);
	}

	function onStart(diff:Float, v:GameVariant, name:String) {
		Global.SBANK.UI_valide(1);
		Global.ME.run(this, function() new MatchIntro( TeamInfos.generate(diff, v, name), v ), false);
	}
}