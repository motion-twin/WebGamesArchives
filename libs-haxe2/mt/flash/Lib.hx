package mt.flash;
import mt.fx.Flash;

typedef TextField = flash.text.TextField;
typedef TextFormat = flash.text.TextFormat;

typedef Bitmap = flash.display.Bitmap;
typedef BitmapData = flash.display.BitmapData;

typedef Shape = flash.display.Shape;
typedef DisplayObject = flash.display.DisplayObject;
typedef DisplayObjectContainer = flash.display.DisplayObjectContainer;
typedef Sprite = flash.display.Sprite;
typedef MovieClip = flash.display.MovieClip;

typedef Rectangle = flash.geom.Rectangle;
typedef Point = flash.geom.Point;
typedef Matrix = flash.geom.Matrix;

typedef Key = flash.ui.Keyboard;
typedef Event = flash.events.Event;
typedef MouseEvent = flash.events.MouseEvent;

class Lib
{
	public static inline function randomFrame( mc:flash.display.MovieClip, ?rnd:Int->Int ) :flash.display.MovieClip
	{
		if ( rnd == null ) rnd = Std.random;
		var id = rnd( mc.totalFrames - 1 ) + 1;
		mc.gotoAndStop(id);
		return mc;
	}
	
	public static inline function removeAllChildren( mc : DisplayObjectContainer ) : DisplayObjectContainer
	{
		while( mc.numChildren > 0 )
		{
			mc.removeChildAt(0);
		}
		return mc;
	}

	public static function scale( s : DisplayObject, value:Float ) : DisplayObject
	{
		s.scaleX = s.scaleY = value;
		return s;
	}
	
	public static inline function toFront( mc : DisplayObject ) : DisplayObject
	{
		if( mc.parent != null)
		{
			mc.parent.setChildIndex( mc , mc.parent.numChildren - 1 );
		}
		return mc;
	}

	public static inline function putBefore( mc0 : DisplayObject, mc1 : DisplayObject ) : DisplayObject
	{
		detach( mc0);
		var i = mc1.parent.getChildIndex( mc1 );
		mc1.parent.addChildAt( mc0,i + 1 );
		return mc0;
	}

	public static inline function putAfter( mc0 : DisplayObject, mc1 : DisplayObject ) : DisplayObject
	{
		detach( mc0);
		if( mc1.parent != null)
		{
			var i = mc1.parent.getChildIndex( mc1 );
			mc1.parent.addChildAt( mc0, i  );
		}
		return mc0;
	}

	public static inline function toBack( mc : DisplayObject ) : DisplayObject
	{
		if( mc.parent != null)
		{
			mc.parent.setChildIndex( mc , 0);
		}
		return mc;
	}
	
	public static inline function detach( a : DisplayObject ) : DisplayObject
	{
		if( a.parent != null)
		{
			a.parent.removeChild( a );
		}
		return a;
	}
	
	public static inline function listChildren( mc : DisplayObjectContainer) : Iterable<DisplayObject>
	{
		var v = new #if haxe3 haxe.ds.GenericStack<DisplayObject>() #else haxe.FastList<DisplayObject>() #end;
		for( i in 0...mc.numChildren)
		{
			v.add( mc.getChildAt(i) );
		}
		return v;
	}
	
	public static function listAllChildren( mc : DisplayObjectContainer, ?addContainers:Bool = false) : Iterable<DisplayObject>
	{
		var v = new #if haxe3 haxe.ds.GenericStack<DisplayObject>() #else haxe.FastList<DisplayObject>() #end;
		for( i in 0...mc.numChildren)
		{
			var child = mc.getChildAt(i);
			if ( Std.is( child, DisplayObjectContainer) )
			{
				if ( addContainers ) v.add(child);
				for ( e in Lib.listAllChildren(cast child, addContainers) )
					v.add(e);
			}
			else 
			{
				v.add( child );
			}
		}
		return v;
	}
	
	public static function stopAllAnimation(par:DisplayObjectContainer):DisplayObjectContainer
	{
		if( Std.is(par, MovieClip ))
		{
			var par : MovieClip = cast par;
			par.stop();
		}
		
		for( m in 0...par.numChildren)
		{
			var s = par.getChildAt(m);
			if( Std.is( s , DisplayObjectContainer))
				stopAllAnimation(cast s);
		}
		
		return par;
	}
	
	public static function pixFlatten( target:flash.display.BitmapData, mc:flash.display.DisplayObject, ?padding = 0.0, ?smoothing = false )
	{
		var bounds = mc.getBounds(mc);
		var m = mc.transform.matrix.clone();
		m.translate( -bounds.x, -bounds.y);
		if ( padding != 0.0 ) m.translate( padding, padding);
		target.draw(mc, m, mc.transform.colorTransform, smoothing);
	}
	
	public static function flatten(mc:flash.display.DisplayObject, ?padding=0.0, ?copyTransforms=false, ?smoothing=false, ?quality:flash.display.StageQuality, ?container:Bitmap ) : Bitmap
	{
		var qold = flash.display.StageQuality.HIGH;
		if ( flash.Lib.current.stage != null )
		{
			qold = flash.Lib.current.stage.quality;
			if( quality != null )
			{
				try flash.Lib.current.stage.quality = quality catch( e:Dynamic ) throw("flatten quality error");
			}
		}
		
		var bounds = mc.getBounds(mc);
		var pixels = new BitmapData(mt.MLib.ceil(bounds.width + padding * 2), mt.MLib.ceil(bounds.height + padding * 2), true, 0x0);
		var bmp  = 	if(container != null ) container
					else new Bitmap();
		bmp.bitmapData = pixels;
		//
		var m = new Matrix();
		m.translate(-bounds.x, -bounds.y);
		m.translate(padding, padding);
		pixels.draw(mc, m, mc.transform.colorTransform, smoothing);
		//
		m.identity();
		m.translate(bounds.x, bounds.y);
		m.translate(-padding, -padding);
		if( copyTransforms ) 
		{
			m.scale(mc.scaleX, mc.scaleY);
			m.rotate( mt.MLib.toRad(mc.rotation) );
			m.translate(mc.x, mc.y);
		}
		bmp.transform.matrix = m;
		
		if( quality != null )
		{
			if ( flash.Lib.current.stage != null )
			{
				try flash.Lib.current.stage.quality = qold catch ( e:Dynamic ) throw("flatten quality error");
			}
		}
		return bmp;
	}
}

