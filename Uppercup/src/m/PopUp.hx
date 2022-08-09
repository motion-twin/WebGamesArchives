package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.mui.Window;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Color;
import mt.deepnight.Lib;
import mt.MLib;
import mt.Metrics;
import ui.*;

class PopUp extends MenuBase {
	var texts			: TextGroup;
	var mask			: Bitmap;

	var menu			: MenuBase;

	public function new(m:MenuBase, str:String) {
		super(false, false);

		gaPageName = null;
		menu = m;
		menu.pause();

		mask = new Bitmap( new BitmapData(100,100,true, Color.addAlphaF(Const.BG_COLOR,0.9)) );
		wrapper.addChild(mask);

		wrapper.addEventListener( flash.events.MouseEvent.CLICK, function(_) close() );

		texts = new TextGroup(wrapper);
		texts.addText(str);

		Global.SBANK.boing(1);
		bg.visible = false;

		onResize();
	}


	override function onResize() {
		super.onResize();

		if( texts==null )
			return;

		texts.x = getWidth()*0.5 - texts.getWidth()*0.5;
		texts.y= getHeight()*0.5 - texts.getHeight()*0.5;

		mask.width = getWidth();
		mask.height = getHeight();
	}

	override function unregister() {
		menu.resume();

		super.unregister();

		texts.destroy();

		mask.bitmapData.dispose();
		mask.bitmapData = null;

		menu = null;
	}

	function close() {
		destroy();
	}
}