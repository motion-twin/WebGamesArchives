package ;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.geom.Transform;
import flash.geom.Rectangle;

using mt.gx.Ex;

typedef CachedElem =
{
	bmp:Bitmap,
	rect:Rectangle,
}

class RefBmpArr 
{
	var cnt = 0;
	public var arr:Array<CachedElem>;
	
	public function new(arr:Array<CachedElem>)
	{
		this.arr = arr;
		lock();
	}
	
	public function lock()
	{
		cnt++;
	}
	
	public function instance() : Array<CachedElem>
	{
		lock();
		var b = [];
		for ( a in arr )
		{
			var bmp = new Bitmap( a.bmp.bitmapData );
			bmp.transform.matrix = a.bmp.transform.matrix.clone();
			b.push({bmp:bmp,rect:a.rect});
		}
		return b;
	}
	
	public function release()
	{
		cnt--;
		if ( cnt == 0)
			for ( a in arr )
				a.bmp.bitmapData.dispose();
		arr=null;
	}
}

class CachedMc extends Sprite 
{
	var src : RefBmpArr;
	public var cursor : Float = 0;
	var arr : Array<CachedElem>;
	
	var d : Sprite;
	
	public function new( src  : RefBmpArr )
	{
		super();
		
		this.src = src;
		arr = src.instance();
		
		for(a in arr )
		{
			a.bmp.visible = false;
			addChild(a.bmp);
		}
		update(0);
	}
	
	public function makeBox()
	{
		var r = getRect( Game.me );
		d = new Sprite();
		d.graphics.beginFill(0xFF0000);
		d.graphics.drawRect( r.x, r.y, r.width, r.height );
		d.graphics.endFill();
		
		Game.me.addChild( d );
	}
	
	public override function getRect(spr) : Rectangle
	{
		var mr = super.getRect( spr );
		var c = cur();
		var cb = c.bmp;
		var cr = c.rect;
		
		//return new Rectangle( mr.x + cb.x - cr.x + cb.width * 0.5, mr.y +cb.y- cr.y + cb.height * 0.5, cr.width, cr.height );
		return new Rectangle( mr.x - cb.x + cr.x, mr.y - cb.y + cr.y, cr.width, cr.height );
	}
	
	public function cur() return  arr[Std.int(cursor)]
	
	public function update(dfr:Float)
	{
		arr[Std.int(cursor)].bmp.visible = false;
		cursor += dfr;
		if ( cursor >= arr.length ) cursor = 0;
		
		var v = arr[Std.int(cursor)];
		v.bmp.visible = true;
	}
	
	public function kill()
	{
		parent.removeChild( this );
		arr = null;
		src.release();
		src = null;
	}
}


class McCache 
{
	public static function flattenAnim( mc : MovieClip ) : Array<CachedElem>
	{
		var a = [];
		for ( i in 1...mc.totalFrames +1 )
		{
			mc.gotoAndStop( i );
			
			var hb : { _hit : MovieClip } = cast mc;
			var c : CachedElem = { 	bmp:mt.deepnight.Lib.flatten( mc, false, flash.display.StageQuality.BEST ), 
									rect: hb._hit.getRect(mc)}
			a.push(c);
		}
		return a;
	}
	
	static var h = new Hash();
	
	public static function instance(mc : MovieClip)
	{
		return new CachedMc(make(mc)); 
	}
	
	public static function make( mc : MovieClip ) : RefBmpArr
	{
		mc.stop();
		var ref = Std.string(mc+"_"+Std.string(mc.currentFrame)+" "+mc.currentFrameLabel);
		if ( h.exists(ref) )
			return h.get(ref);
		else
		{
			h.set( ref, new RefBmpArr( flattenAnim( mc ) ));
			return h.get(ref);
		}
	}
}