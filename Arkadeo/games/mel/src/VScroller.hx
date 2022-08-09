package ;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import gfx.Plan3;
import mt.fx.Flash;
import mt.gx.Pool;

import mt.gx.Debug;
import mt.Rand;

using mt.gx.Ex;

class VScroller
{
	public var start : Int;
	public var pageSize : Int;
	public var curScroll : Int;
	public var curPage : Int;
	
	public var draw : Array<Int>;
	
	public var game(get, null) : Game; function get_game() return Game.me
	
	public function new( start, pageSize)
	{
		this.start = start;
		this.pageSize = pageSize;
		draw = [-1,0];
	}
	
	public function refresh( scroll : Float )
	{
		if ( scroll < start )
			scroll = start;
			
		curPage = Std.int((scroll + start ) / pageSize + 1);
		
		for ( i in draw)
			if( i != curPage && i != curPage+1 && i != curPage+2)
				hidePage(i);
	
		draw[0] = curPage;
		draw[1] = curPage + 1;
		draw[2] = curPage + 2;
		
		drawPage( curPage );
		drawPage( curPage + 1 );
		drawPage( curPage + 2 );
		
		curScroll = Std.int(scroll+0.5);
	}
	
	public function getPageScroll( i : Int )
	{
		return  start + i * pageSize;
	}
	
	public function hidePage( i : Int )
	{
	}
		
	public function drawPage( i : Int )
	{
	}
	
}


class KeyedBitmap extends flash.display.Bitmap
{
	public var key : Null<Int>;//key is the num of the page regarded

	public function new()
	{
		super();
	}
}

class ClipScroller extends VScroller
{
	//frames
	public var bmps : IntHash< {k:Int,data:flash.display.BitmapData, readers:List<KeyedBitmap >} >;
	public var heads : Pool<KeyedBitmap>;
	public var clip : flash.display.MovieClip;
	public var seed : Int;
	function newReader()
	{
		var bmp = new KeyedBitmap();
		bmp.visible = false;
		return bmp;
	}
	
	public function new(mc)
	{
		super( - Lib.h(), Lib.h() );
		
		clip = mc;
		heads = new Pool<KeyedBitmap>( function() return new KeyedBitmap() );
		bmps = new IntHash();
		
		for ( i in 1...clip.totalFrames+1 )
		{
			clip.gotoAndStop( i );
			var bmp = mt.deepnight.Lib.flatten(clip);
			bmps.set( i, { k:i, data:bmp.bitmapData,readers:new List() });
		}
	}
	
	function getFrame( i )
	{
		return  bmps.get( 1 + new mt.Rand( Std.int( (seed * Game.getSeed() * (i * 123456743)) ^ 0xdeadbeef ) ).random( clip.totalFrames ));
	}
	
	public override function hidePage( i )
	{
 		super.hidePage(i);
		var f = getFrame(i);
		for ( bmp in f.readers)
		{
			if ( bmp.key == i )
			{
				bmp.visible = false;
				f.readers.remove( bmp );
				bmp.key = null;
				
				bmp.parent.removeChild( bmp );
				heads.destroy(bmp);
			}
		}
	}
	
	function viewToScroll(f:Float)
	{
		return f * 1;
	}
	
	public function update()
	{
		super.refresh( viewToScroll( game.view.y ) );
	}
	
	function scrollY(i)
	{
		return viewToScroll( game.view.y) - getPageScroll(i) /*+ Lib.h()*/;
	}
	
	public override function drawPage( i )
	{
		super.drawPage(i);
		var f = getFrame(i);
		for ( rd in f.readers)
			if ( rd.key == i )
			{
				rd.y = scrollY( i );
				rd.visible = true;
				return;
			}
		
		var rd = heads.create();
		rd.key = i;
		f.readers.pushBack( rd );
		rd.bitmapData = f.data;
		rd.y = scrollY( i );
		rd.visible = true;
		addReader(rd);
	}
	
	function addReader(rd:DisplayObject)
	{
		throw "implement me";
	}
	
	public function getMaxIndex():Null<Int>	{
		var n : Null<Int>= null;
		for ( r in  heads.getUsed())
		{
			var idx = r.parent.getChildIndex( r );
			if (n == null)
				n = idx;
			else if ( idx > n )
				n = idx;
		}
		return n;
	}
	
	public function getMinIndex():Null<Int>{
		var n : Null<Int>= null;
		for ( r in  heads.getUsed())
		{
			var idx = r.parent.getChildIndex( r );
			if (n == null)
				n = idx;
			else if ( n > idx )
				n = idx;
		}
		return n;
	}
}


class P3Scroller extends ClipScroller
{
	public function new()
	{
		super( new gfx.Plan3() );
		seed = 101;
	}
	
	override function viewToScroll(f:Float)
		return f * 0.05
	
	override function addReader(rd:DisplayObject)
	{
		game.addChild( rd );
		game.setChildIndex( rd, game.level.p3index );
	}
}

class P2Scroller extends ClipScroller
{
	public function new()
	{
		super( new gfx.Plan2() );
		seed = 101101;
	}
	
	override function viewToScroll(f:Float)
		return f * 0.15
	
	override function addReader(rd)
	{
		game.addChild( rd );
		game.setChildIndex( rd, game.level.p3.getMaxIndex()+1 );
	}
}

class P2BScroller extends P2Scroller{
	public function new()
	{
		super();
		seed = 0x101101de;
	}
	
	override function viewToScroll(f:Float)
		return f * 0.10
	
	override function addReader(rd:DisplayObject)
	{
		rd.scaleX = -1;
		rd.x = Lib.w();
		game.addChild( rd );
		game.setChildIndex( rd, game.level.p2.getMaxIndex()+1 );
	}
}