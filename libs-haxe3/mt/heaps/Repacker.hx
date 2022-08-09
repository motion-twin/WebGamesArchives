package mt.heaps;
import h3d.Engine;
import h3d.Vector;

@:publicFields
class RepackerEntry {
	
	var source		: flash.display.BitmapData;
	var sourceTile	: h3d.Vector;
	var scaleX		: Float=1.0;
	var scaleY		: Float=1.0;
	
	var destTile 	: h3d.Vector;
	var name		: String;
	
	public function new(bmd,?v,?name:String) {
		source = bmd;
		sourceTile = v==null ? new Vector(0, 0, bmd.width, bmd.height) : v;
		destTile = new Vector(0, 0, 0, 0);
		this.name = name;
	}
		
	inline function width() 
		return Math.round(sourceTile.z);
	
	inline function height() 
		return Math.round(sourceTile.w);
		
	public inline function forScale(s) {
		scaleX = scaleY = s;
		return this;
	}
	
	public inline function forWidth(px) {
		scaleX = px / width();
		scaleY = scaleX;
		return this;
	}
	
	public inline function forHeight(px) {
		scaleY = px / height();
		scaleX = scaleY;
		return this;
	}
}

/**
 * Usage:
	 * //declare hd sources
	 * 	var source = [ "assets/ui/attack.png", "assets/ui/defense.png" ];
		var sourceEntries = source.map(function(e) { 
			//retrieve data
			var bmd = openfl.Assets.getBitmapData( e );
			var re = new RepackerEntry( bmd , e) 
			
			//hint for final size at screen
			.forHeight( Math.round( 300 * VikingHud.uiScale() ) );
			return re;
		});
		
		var bmd = mt.heaps.Repacker.repackBicubic( sourceEntries );
		uiMasterTile = h2d.Tile.fromFlashBitmap( bmd );
		
		inline function r(v) return Math.round(v);
		for ( s in sourceEntries ) {
			uiTiles.set( s.name, new Tile( 
				uiMasterTile.getTexture(), 
				r(s.destTile.x), r(s.destTile.y), r(s.destTile.z), r(s.destTile.w )));
		}
	 * 
	 * 
	 * 
	 * 
	 * 
	 * 
	 * 
 */
class Repacker {
	
	static inline function compTex(e0:RepackerEntry, e1:RepackerEntry) :Int {
		var t0w = e0.width();
		var t0h = e0.height();
		
		var t1w = e1.width();
		var t1h = e1.height();
		
		return Math.round(t0w * t0h - t1w * t1h);
	}
	
	public static function texSize() {
		return  h3d.Engine.getCurrent().driver.query(MaxTextureSize);
	}
	
	public static var padding = 0;
	public static function repackBicubic( tiles:  Array<RepackerEntry>) : flash.display.BitmapData {
		var packer = new hxd.tools.Packer();
		var pad = padding<<1;
		var hPad = pad >> 1;
		var wsum = 0;
		var hsum = 0;
		for ( l in tiles) {
			wsum += Math.round(l.width() * l.scaleX);
			hsum += Math.round(l.height() * l.scaleY);
		}
		
		var sizeSq = texSize();
		while( sizeSq>1 ){
			if( sizeSq /2 > wsum && sizeSq /2 > hsum )
				sizeSq>>=1;
			else 
				break;
		}
		
		#if h3d
		if ( sizeSq > h3d.Engine.getCurrent().driver.query(MaxTextureSize) )
			throw "texture size assert";
		#end
		
		//sort out what goes where
		var bn = new hxd.tools.BinPacker(sizeSq, sizeSq);
		var r : flash.geom.Rectangle; 
		tiles.sort( compTex );
		
		for (e in tiles) {
			r = bn.quickInsert(e.width() * e.scaleX + pad, e.height() * e.scaleY + pad);
			e.destTile.x = Std.int(r.x) + hPad;
			e.destTile.y = Std.int(r.y) + hPad;
			e.destTile.z = r.width - hPad;
			e.destTile.w = r.height - hPad;
		}
		
		var dest = new flash.display.BitmapData(sizeSq, sizeSq, true, 0x0);
		for ( e in tiles )
			mt.gx.Scaler.resizeAt( 
				dest, 		Std.int(e.destTile.x), 		Std.int(e.destTile.y), 	
							Math.round(e.destTile.z),	Math.round(e.destTile.w ),
							
				e.source, 	Std.int(e.sourceTile.x),	Std.int(e.sourceTile.y), 
							e.width(),					e.height()
			);
				
		return dest;
	}
}