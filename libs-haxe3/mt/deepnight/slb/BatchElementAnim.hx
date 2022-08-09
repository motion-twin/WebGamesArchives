package mt.deepnight.slb;

import h2d.Drawable;
import h2d.SpriteBatch;
import mt.deepnight.slb.*;
import mt.deepnight.slb.BLib;
import mt.deepnight.slb.SpriteInterface;

class BatchElementAnim extends BatchElement {

	var bs						: BSprite;
	var destroyed				: Bool;

	public function new(sb:SpriteBatch, l:BLib, k:String, ?plays=99999, ?centerX=0.0, ?centerY=0.0) {
		super(l.tile.clone());

		destroyed = false;
		sb.add(this);

		bs = new BSprite();
		bs.isH2d = true;
		bs.set(l);
		bs.a.play(k, plays);
		bs.onFrameChange = render;
		bs.pivot.setCenter(centerX,centerY);

		render();
	}

	public function toString() return "HSpriteBE_"+bs.groupName+"["+bs.frame+"]";

	function render() {
		var fd = bs.frameData;
		t.setPos(fd.x, fd.y);
		t.setSize(fd.wid, fd.hei);

		if ( bs.pivot.isUsingCoord() ) {
			t.dx = MLib.round(-bs.pivot.coordX - fd.realFrame.x);
			t.dy = MLib.round(-bs.pivot.coordY - fd.realFrame.y);
		}
		else if ( bs.pivot.isUsingFactor() ){
			t.dx = -Std.int(fd.realFrame.realWid * bs.pivot.centerFactorX + fd.realFrame.x);
			t.dy = -Std.int(fd.realFrame.realHei * bs.pivot.centerFactorY + fd.realFrame.y);
		}
	}

	public inline function destroy() remove();
	override function remove() {
		super.remove();
		if( !destroyed ) {
			if (bs != null)
				bs.destroy();
			bs = null;
			destroyed = true;
		}
	}
}
