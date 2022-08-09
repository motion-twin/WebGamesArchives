package ui;

import flash.display.Bitmap;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Lib;

class BigMenuButton extends Button {
	var ptf				: Null<Bitmap>;
	public function new(p, str, cb) {
		super(p, str, cb);

		setSize(300, 45);
		setBg( m.Global.ME.tiles.get("bigButton") );
	}

	public function addPromoFlag() {
		setBg( m.Global.ME.tiles.get("bigButtonPromo") );
		var tf = m.Global.ME.createField(Lang.Sale, FBig, true);
		tf.filters = [
			new flash.filters.GlowFilter(0xFF8204,1, 2,2,4),
			new flash.filters.GlowFilter(0xFF871A,0.7, 8,8,1),
		];

		ptf = Lib.flatten(tf, 4);
		wrapper.addChild(ptf);
		var m = new flash.geom.Matrix();
		m.translate(-ptf.width*0.5, -ptf.height*0.5);
		m.rotate(-0.48);
		m.translate(25,17);
		ptf.transform.matrix = m;
	}

	override function destroy() {
		super.destroy();
		if( ptf!=null ) {
			ptf.bitmapData.dispose();
			ptf.bitmapData = null;
		}
	}
}
