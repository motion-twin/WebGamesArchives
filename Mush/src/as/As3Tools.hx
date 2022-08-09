package ;

import flash.display.DisplayObject;
import flash.text.TextField;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.net.URLLoader;
import flash.events.*;
import flash.events.Event;
/**
 * ...
 * @author de
 */

class As3Tools
{

	public static function setNextAnim( el : mt.pix.Element, str:String, loop = false)
	{
		if ( el.store.timelines.get( str ) == null)
			return;
			
		try
		{
			if ( el.anim != null )
			{
				if ( el.anim.playSpeed <= MathEx.EPSILON)
					el.play( str, loop);
				else
					el.anim.onFinish = function() el.play( str , loop);
			}
			else
				el.play( str , loop);
		}
		catch (d:Dynamic)
		{
			Debug.MSG(d);
		}
	}
	
	public static inline function pixel32( el : mt.pix.Element, x:  Float , y : Float ) : Int
	{
		var p = el.localToGlobal( new flash.geom.Point(x, y ));
		var pre = el.hitTestPoint( p.x,p.y,false);
		return
		( !pre ) ? 0
		:
		{
			var bmp :flash.display.BitmapData = el.currentFrame.texture;
			var fr = el.currentFrame;
			
			var ox = -Std.int(fr.width * el.frameAlignX);
			var oy = -Std.int(fr.height * el.frameAlignY);
			
			ox += fr.ddx;
			oy += fr.ddy;
			
			var tx = fr.x - ox +x;
			var ty = fr.y - oy +y;
			
			bmp.getPixel32( Std.int(tx), Std.int(ty));
		}
	}
	
	public static inline function hitTest( el : mt.pix.Element, x:  Float , y : Float ) : Bool
	{
		return (pixel32( el, x, y ) & 0xFF000000) != 0;
	}
	
	public static function tfield(color = 0xFFFFFF, size = 8, font = "galaxy", align = -1)
	{
		var field = new TextField();
		field.width = 200;
		field.height = 20;
		field.selectable = false;
		field.embedFonts = true;
		var tf = field.getTextFormat();
		tf.color = color;
		tf.font = font;
		tf.size = size;
		
		tf.align = [flash.text.TextFormatAlign.LEFT, flash.text.TextFormatAlign.CENTER, flash.text.TextFormatAlign.RIGHT][align + 1];
		field.defaultTextFormat = tf;
		return field;
	}
	
	public static inline function colTans()
	{
		return new flash.geom.ColorTransform();
	}
	
	public static function detach(  a : flash.display.DisplayObject )
	{
		if( a!=null && a.parent != null)
			a.parent.removeChild( a );
	}
	
	
	public static function toFront( mc : DisplayObject )
	{
		if( mc.parent != null)
			mc.parent.setChildIndex( mc , mc.parent.numChildren-1 );
	}
	
	
	public static function sendBefore( mc0 : DisplayObject, mc1 : DisplayObject )
	{
		if ( mc0.parent != mc1.parent )
			return;
			
		var i = mc1.parent.getChildIndex( mc1 );
		mc1.parent.setChildIndex( mc0,i  );
	}
	
	public static function putBefore( mc0 : DisplayObject, mc1 : DisplayObject )
	{
		detach( mc0);
		var i = mc1.parent.getChildIndex( mc1 );
		mc1.parent.addChildAt( mc0,i + 1 );
	}
	
	public static function putAfter( mc0 : DisplayObject, mc1 : DisplayObject )
	{
		detach( mc0);
		var i = mc1.parent.getChildIndex( mc1 );
		mc1.parent.addChildAt( mc0,i  );
	}
	
	public static function toBack( mc : DisplayObject)
	{
		if( mc.parent != null)
			mc.parent.setChildIndex( mc , 0);
	}
	
	public static function tf( txt : String, col : Int, fnt : String, sz : Int = 8 )
	{
		var t = new flash.text.TextField();
		t.text = txt;
		t.textColor = col;
		t.visible = true;
		t.selectable = false;
		t.mouseEnabled = false;
		t.embedFonts = true;
		
		var txtFmt : flash.text.TextFormat = t.getTextFormat();
		txtFmt.font = fnt;
		txtFmt.size = sz;
		t.setTextFormat( txtFmt );
		t.defaultTextFormat = txtFmt;

		return t;
	}
	
	public static function loadBitmap( path:String , cbk : String->BitmapData->Void, ?err:Void->Void)
	{
		var loader: flash.display.Loader = new flash.display.Loader();
		function onComplete (event:Event)
		{
			var content : Bitmap = cast loader.content;
			var bitmapData = content.bitmapData;
			cbk( path, bitmapData );
		}
			
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR , function(e) if(err!=null) err() else Debug.MSG(e) );
		loader.load(new flash.net.URLRequest(path));
	}
	
	
}