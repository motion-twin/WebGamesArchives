package ui;

import flash.display.BitmapData;
import mt.deepnight.slb.BSprite;

class VariantButton extends Button {
	public function new(p, str, cb, ?active=false) {
		super(p, str, cb, 1);

		setFontColor(0xFFFFFF);
		setBitmapLabel(str);
		setSize(102, 35);
		setBg( m.Global.ME.tiles.get("btnDifficulty") );

		if( active )
			press();
	}

	override function applyLabelFilters(bd:BitmapData) {
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0x0,0.25, 0,0,1));
	}

	public function press() {
		setBg( m.Global.ME.tiles.get("btnDifficulty", 1) );
	}

	public function unpress() {
		setBg( m.Global.ME.tiles.get("btnDifficulty", 0) );
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		if( label!=null )
			label.y += 3;
	}
}
