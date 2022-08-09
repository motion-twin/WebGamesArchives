package m;

import flash.display.Sprite;
import mt.deepnight.mui.VGroup;
import mt.deepnight.mui.HGroup;
import mt.deepnight.slb.BSprite;
import mt.MLib;
import mt.Metrics;
import ui.*;

class HandModeSelect extends MenuBase {
	var menu		: VGroup;
	var back		: BackButton;
	var title		: MenuLabel;
	var team		: TeamInfos;

	public function new(t) {
		super();
		team = t;
		gaPageName = null;

		menu = new VGroup(wrapper);
		menu.removeBorders();
		menu.margin = 5;

		title = new MenuLabel(wrapper, Lang.ChooseHandMode);
		new BigMenuButton(menu, Lang.Right, onSelect.bind(false));
		new BigMenuButton(menu, Lang.Left, onSelect.bind(true));

		back = new BackButton(wrapper, onBack);

		onResize();
	}

	override function onBackKey() {
		super.onBackKey();
		onBack();
	}

	function onSelect(left:Bool) {
		Global.SBANK.UI_valide(1);
		playerCookie.data.leftHanded = left;
		playerCookie.save();
		Ga.event("settings", "leftHanded", Std.string(left));
		Global.ME.run(this, function() new Game(team, Global.ME.variant), true);
	}


	override function unregister() {
		super.unregister();

		title.destroy();
		menu.destroy();
		back.destroy();
	}

	function onBack() {
		Global.SBANK.UI_back(1);
		Global.ME.run(this, function() new StageSelect(team.lid,true), false);
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
}