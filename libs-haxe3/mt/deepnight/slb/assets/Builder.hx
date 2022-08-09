package mt.deepnight.slb.assets;
import mt.deepnight.slb.BLib;
import mt.deepnight.Lib;
import mt.MLib;
import flash.display.BitmapData;

private typedef TileData = {
	bd		: BitmapData,
	id		: String,
	finalX	: Int,
	finalY	: Int,
	wid		: Int,
	hei		: Int,
}

class Builder {
	var tiles			: Array<TileData>;

	public function new() {
		tiles = [];
	}

	public function addColor(id:String, col:UInt, alpha:Float, ?w=4, ?h=4) {
		var bd = new flash.display.BitmapData(w,h, alpha!=1, 0x0);
		bd.fillRect( bd.rect, mt.deepnight.Color.addAlphaF(col,alpha) );
		addBitmapData(id, bd);
	}

	public function addBitmapData(id:String, bd:BitmapData) {
		tiles.push({
			id			: id,
			bd			: bd,
			finalX		: 0,
			finalY		: 0,
			wid			: bd.width,
			hei			: bd.height,
		});
	}

	/**
	 * Create and returns a BLib from the current Builder textures
	 * @param	wid Must be a power of 2
	 * @param	hei Must be a power of 2
	 * @param	autoDestroyBuilder Set to TRUE to auto-destroy the Builder instance after the BLib creation
	 */

	public function createLib(wid:Int, hei:Int, autoDestroyBuilder:Bool) : Null<BLib> {
		if( !MLib.isPow2(wid) || !MLib.isPow2(hei) )
			throw '${wid}x${hei} isn\'t a power of 2';

		var remain = pack(wid,hei);
		if( remain>0 ) {
			#if debug
			trace('Builder.hx: packing failed, ${wid}x${hei} is not enough, $remain textures remaining.');
			#end
			return null;
		}

		// Build source texture
		var bd = new flash.display.BitmapData(wid, hei, true, 0x0);
		var pt = new flash.geom.Point(0,0);
		for(t in tiles) {
			pt.x = t.finalX;
			pt.y = t.finalY;
			bd.copyPixels(t.bd, t.bd.rect, pt, false);
		}
		pt = null;

		// Prepare lib
		var lib = new mt.deepnight.slb.BLib( bd #if h3d, h2d.Tile.fromFlashBitmap(bd) #end );
		for(t in tiles)
			lib.slice(t.id, t.finalX, t.finalY, t.wid, t.hei);

		if( autoDestroyBuilder )
			destroy();

		return lib;
	}


	public function destroy() {
		for(t in tiles)
			t.bd.dispose();
		tiles = null;
	}



	function pack(wid:Int, hei:Int) {
		var stock = tiles.copy();

		var baseX = 0;
		var baseY = 0;
		var ok = true;
		while( stock.length>0 ) {
			stock.sort(function(a,b) return -Reflect.compare(a.wid*a.hei, b.wid*b.hei));
			// Get a new reference rectangle
			var ref = stock.splice(0,1)[0];
			ref.finalX = baseX;
			ref.finalY = baseY;
			baseX+=ref.wid;
			baseY+=ref.hei;

			if( baseX>=wid || baseY>=hei )
				return stock.length;

			// Fill to the right
			var x = ref.finalX + ref.wid;
			var y = ref.finalY;
			var smaller = stock.filter(function(r) return r.hei<=ref.hei);
			smaller.sort( function(a,b) return -Reflect.compare(a.hei, b.hei) );
			while( smaller.length>0 && x<wid ) {
				var r = smaller.shift();
				if( x+r.wid<wid ) {
					r.finalX = x;
					r.finalY = y;
					x+=r.wid;
					stock.remove(r);
				}
			}

			// Fill to the bottom
			var x = ref.finalX;
			var y = ref.finalY + ref.hei;
			var smaller = stock.filter(function(r) return r.wid<=ref.wid);
			smaller.sort( function(a,b) return -Reflect.compare(a.wid, b.wid) );
			while( smaller.length>0 && x<wid ) {
				var r = smaller.shift();
				if( y+r.hei<hei ) {
					r.finalX = x;
					r.finalY = y;
					y+=r.hei;
					stock.remove(r);
				}
			}
		}

		return 0;
	}
}