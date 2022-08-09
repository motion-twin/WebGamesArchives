import mt.MLib;

import h2d.Tile;
import h2d.SpriteBatch;
import mt.deepnight.slb.BLib;

class TiledTexture extends h2d.Sprite {
	var baseX		: Float;
	var baseY		: Float;
	var wid			: Float;
	var hei			: Float;
	var priority	: Int;

	var lib			: BLib;
	var sb			: SpriteBatch;
	var elements	: Array<BatchElement>;

	public function new(sb:SpriteBatch, lib:BLib, x,y,w,h) {
		super(sb);
		this.sb = sb;
		this.lib = lib;
		baseX = x;
		baseY = y;
		wid = w;
		hei = h;
		priority = 0;
		elements = [];
	}

	override function dispose() {
		if( elements!=null ) {
			for(e in elements)
				e.remove();
			elements = null;

			sb = null;
		}

		super.dispose();
	}

	public function setPriority(p:Int) {
		priority = p;
		for(e in elements)
			e.changePriority(priority);
	}

	public function fill(k:String, frame:Int, scale:Float, alpha:Float) {
		for(e in elements)
			e.remove();
		elements = [];

		var fd = lib.getFrameData(k,frame);
		var baseTile = lib.getTile(k,frame);
		var dx = 0.;
		var dy = 0.;
		var rwid = fd.realFrame.realWid * scale;
		var rhei = fd.realFrame.realHei * scale;
		while( dy<hei ) {
			var t = baseTile;

			// Crop tile
			if( dx+rwid>=wid || dy+rhei>=hei ) {
				var nw = (wid-dx)/scale;
				var nh = (hei-dy)/scale;
				t = t.sub( 0, 0, Std.int( MLib.fmin(t.width, nw) ), Std.int( MLib.fmin(t.height, nh) ) );
			}

			// Add it
			var b = sb.alloc(t, priority);
			b.alpha = alpha;
			b.scale(scale);
			b.x = baseX + dx;
			b.y = baseY + dy;
			dx+=rwid;
			if( dx>=wid ) {
				dx = 0;
				dy+=rhei;
			}
			elements.push(b);
		}
	}
}