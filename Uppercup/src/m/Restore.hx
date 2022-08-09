package m;

import flash.display.Sprite;
import mt.deepnight.mui.VGroup;
import mt.deepnight.mui.HGroup;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Process;
import mt.MLib;
import mt.Metrics;
import ui.*;

class Restore extends MenuBase {
	var menu		: VGroup;

	var pmenu		: MenuBase;

	public function new(m:MenuBase) {
		super(false, false);
		pmenu = m;
		pmenu.pause();
		gaPageName = null;
		bg.alpha = 0.95;

		menu = new VGroup(wrapper);
		menu.removeBorders();
		menu.margin = 5;

		loading();
		delayer.add( function() IapMan.ME.loadProducts(onProducts), 500 );

		onResize();
	}

	override function onBackKey() {
		super.onBackKey();
		onCancel();
	}

	override function unregister() {
		if( pmenu!=null )
			pmenu.resume();

		super.unregister();

		menu.destroy();
	}

	function onProducts(success) {
		menu.removeAllChildren();
		var price = IapMan.ME.getUnlockPrice();
		if( !success || price==null ) {
			var t = new TextGroup(menu);
			t.addText(Lang.NetworkError);
			new BigMenuButton(menu, Lang.Cancel, onCancel);
		}
		else {
			var t = new TextGroup(menu);
			t.addText(Lang.RestoreExplanation);
			var b = new BigMenuButton(menu, Lang.RestorePurchase, onRestore);
			b.hasClickFeedback = false;
			new BigMenuButton(menu, Lang.Cancel, onCancel);
		}
		onResize();
	}

	function loading() {
		menu.removeAllChildren();

		var g = new HGroup(menu);
		g.removeBorders();
		var s = tiles.getAndPlay("ball");
		new mt.deepnight.mui.Image(g, s, function() {
			s.dispose();
		});

		new MenuLabel(g, Lang.Loading);

		onResize();
	}

	function onRestore() {
		cd.set("restore", Const.seconds(5));
		cd.onComplete("restore", onTimeOut);

		loading();

		IapMan.ME.tryToRestore(function(productId:String) {
			cd.unset("restore");
			destroy();
			Global.ME.run(cast pmenu, function() new Thanks(false), false);
			pmenu = null;
		});
	}

	function onTimeOut() {
		menu.removeAllChildren();
		new TextGroup(menu, Lang.RestoreFailed);
		new BigMenuButton(menu, Lang.Cancel, onCancel);
		onResize();
	}

	function onCancel() {
		destroy();
	}

	override function onResize() {
		super.onResize();

		if( menu==null )
			return;

		menu.x = Std.int(getWidth()*0.5-menu.getWidth()*0.5);
		menu.y = Std.int(getHeight()*0.5-menu.getHeight()*0.5);
	}
}