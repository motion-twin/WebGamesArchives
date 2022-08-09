package ui;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.slb.*;

class ColorPicker {
	public var wrapper	: Sprite;
	var menu			: m.MenuBase;

	var square			: Bitmap;
	var prev			: ArrowButton;
	var next			: ArrowButton;
	var cur				: Int;
	var palette			: Array<UInt>;
	var onColorChange	: Void->Void;

	public function new(menu:m.MenuBase, pal:Array<UInt>, onColorChange:Void->Void) {
		this.menu = menu;
		this.onColorChange = onColorChange;
		cur = 0;
		palette = pal;

		wrapper = new Sprite();
		menu.wrapper.addChild(wrapper);

		prev = new ArrowButton(wrapper, false, onPrev);
		next = new ArrowButton(wrapper, true, onNext);

		square = new Bitmap( m.Global.ME.tiles.getBitmapData("thumbColor") );
		wrapper.addChild(square);

		square.x = 60;
		next.x = 120;
		refresh();
	}

	public function getWidth() return 60*3;
	public function getHeight() return 60;

	public function getColor() {
		return palette[cur];
	}

	public function getColorId() {
		return cur;
	}

	public function select(id:Int) {
		cur = id;
		refresh();
	}

	function onPrev() {
		m.Global.SBANK.UI_select(0.6);
		cur--;
		if( cur<0 )
			cur = palette.length-1;
		menu.fx.hit(wrapper.x + 30, wrapper.y + 30, 0.5);
		refresh();
		onColorChange();
	}

	function onNext() {
		m.Global.SBANK.UI_select(0.6);
		cur++;
		if( cur>=palette.length )
			cur = 0;
		menu.fx.hit(wrapper.x + 150, wrapper.y + 30, 0.5);
		refresh();
		onColorChange();
	}

	function refresh() {
		m.Global.ME.tiles.drawIntoBitmap(square.bitmapData, 0,0, "thumbColor");
		square.bitmapData.applyFilter(square.bitmapData, square.bitmapData.rect, new flash.geom.Point(), mt.deepnight.Color.getBrightnessFilter(-0.3));
		square.bitmapData.applyFilter(square.bitmapData, square.bitmapData.rect, new flash.geom.Point(), mt.deepnight.Color.getColorizeFilter(getColor(),1, 0));
	}

	public function destroy() {
		square.bitmapData.dispose(); square.bitmapData = null;
		prev.destroy();
		next.destroy();
		wrapper.parent.removeChild(wrapper);
	}
}