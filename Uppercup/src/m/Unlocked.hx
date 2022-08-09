package m;

import flash.display.Sprite;
import mt.deepnight.mui.VGroup;
import mt.deepnight.mui.HGroup;
import mt.deepnight.slb.BSprite;
import mt.MLib;
import mt.Metrics;
import ui.*;

class Unlocked extends MenuBase {
	var menu		: VGroup;
	var back		: BackButton;

	public function new(str) {
		super();

		menu = new VGroup(wrapper);
		menu.removeBorders();
		menu.margin = 5;

		var texts = new TextGroup(menu);
		texts.addText(str);
		new SmallMenuButton(menu, Lang.Continue, onContinue);

		back = new BackButton(wrapper, onBack);
		fx.flashBang(0x0080FF, 1, 1500);
		Global.SBANK.bumper(1);

		onResize();
	}

	override function onBackKey() {
		super.onBackKey();
		onBack();
	}

	function onContinue() {
		Global.SBANK.UI_valide(1);
		Global.ME.run(this, function() new StageSelect(-1,true), true);
	}


	override function unregister() {
		super.unregister();

		menu.destroy();
		back.destroy();
	}

	function onBack() {
		Global.SBANK.UI_back(1);
		Global.ME.run(this, function() new StageSelect(-1,true), false);
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
		fx.confettis(false);
	}
}