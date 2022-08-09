package ui;

import mod.ModAssets;

/**
 * ...
 * @author Tipyx
 */
class Button extends h2d.Sprite
{
	public var onClick		: Void-> Void;
	public var ta			: TypeAsset;
	
	public var w			: Int;
	public var h			: Int;
	
	var border				: Int;
	
	var bg					: h2d.Bitmap;
	
	public var text			: h2d.Text;
	var inter				: h2d.Interactive;
	
	public var isActive		: Bool;
	
	public function new(str:String, ta:TypeAsset) {
		super();
		
		this.ta = ta;
		
		border = 2;
		
		isActive = true;
		
		text = new h2d.Text(Settings.FONT_ARIAL_20);
		text.text = str;
		text.textColor = 0x000000;
		text.x = 10;
		text.y = 3;
		
		w = Std.int(text.textWidth < 120 ? 120 : text.textWidth);
		h = Std.int(text.textHeight + 5);
		
		inter = new h2d.Interactive(w, h);
		inter.backgroundColor = 0xFF000000;
		inter.onClick = function(e:hxd.Event) {
			if (onClick != null)
				onClick();
		}
		this.addChild(inter);
		
		bg = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFFFF, Std.int(w - border * 2), Std.int(h - border * 2)));
		bg.x = bg.y = border;
		this.addChild(bg);
		
		this.addChild(text);
	}
	
	public function enable() {
		isActive = true;
		bg.alpha = 1;
	}
	
	public function disable() {
		isActive = false;
		bg.alpha = 0.25;
	}
	
	public function destroy() {
		text.dispose();
		text = null;
		
		bg.dispose();
		bg = null;
		
		inter.dispose();
		inter = null;
	}
}