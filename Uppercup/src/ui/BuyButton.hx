package ui;

import m.IapMan;
import flash.display.Bitmap;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Lib;

class BuyButton extends Button {
	var ptf				: Null<Bitmap>;

	public function new(p, str, cb) {
		//var price = ;
		//var str = price==null ? Lang.LoadingPrice : Lang.BuyButton({ _price:price });
		super(p, str, cb);

		setFontColor(0xA83200);
		setBitmapLabel(str);

		var s = m.Global.ME.tiles.get("payButtonSmall");
		setSize(s.width, s.height);
		setBg(s);
		hasClickFeedback = false;
	}

	override function applyLabelFilters(bd:flash.display.BitmapData) {
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,-90, 0xDF7500, 1, 0,0));
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0xFFFF80, 0.6, 2,2, 8));
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		if( label!=null )
			label.y = Std.int( h*0.5 - label.height*0.5 - 6 );
	}


	override function destroy() {
		super.destroy();
		if( ptf!=null ) {
			ptf.bitmapData.dispose();
			ptf.bitmapData = null;
		}
	}
}
