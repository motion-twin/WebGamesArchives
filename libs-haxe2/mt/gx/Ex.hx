package mt.gx;
import haxe.Serializer;
import haxe.Unserializer;

/**
 * ...
 * @author de
 */
typedef EmbedLambda		= Lambda;
typedef EmbedLambdaEx 	= mt.gx.LambdaEx;
typedef Rd 				= mt.gx.RandomEx;
typedef EmbedArrayEx 	= mt.gx.ArrayEx;
typedef EmbedListEx 	= mt.gx.ListEx;
typedef EmbedEnumEx		= mt.gx.EnumEx;

typedef EmbedDathEx		= mt.gx.DateEx;
typedef EmbedStringEx 	= mt.gx.StringEx;
typedef EmbedHashEx		= mt.gx.HashEx;
typedef EmbedIntHashEx 	= mt.gx.IntHashEx;
typedef EmbedEnumFlagsEx = mt.gx.EnumFlagsEx;
typedef EmbedDebug 		= mt.gx.Debug;


#if(flash||nme||flax)
typedef EmbedMcEx			= mt.gx.as.McEx;
typedef EmbedAsLib 			= mt.gx.as.Lib;
typedef EmbedColTransEx 	= mt.gx.as.ColTransEx;
typedef EmbedGfxEx 			= mt.gx.as.GfxEx;

typedef TF 			 		= flash.text.TextField;
typedef TFO			 		= flash.text.TextFormat;
typedef MC 			 		= flash.display.MovieClip;
typedef SP 			 		= flash.display.Sprite;
typedef BMD 		 		= flash.display.BitmapData;
typedef BMP			 		= flash.display.Bitmap;
typedef DO 			 		= flash.display.DisplayObject;
typedef DOC			 		= flash.display.DisplayObjectContainer;
typedef MX			 		= flash.geom.Matrix;
typedef CT 			 		= flash.geom.ColorTransform;
typedef PT 			 		= flash.geom.Point;
#end

#if haxe3 @:publicFields #end
class Ex #if !(haxe3) implements haxe.Public #end{
	public static inline function assert<B>( d : Null<B> , msg:String = "" )
	{
		if ( d == null )
		{
			throw "assert "+msg;
		}
		else {
			return d;
		}
	}
	
	public static function deepCopy<T>( v:T ) : T { 
		var type = Type.typeof(v);
		return switch( type )
		{
			case TNull: null;
			case TBool: v;
			case TInt: v;
			case TFloat: v;
			case TFunction: v;
			
			case TEnum(e):
				var en = Type.createEnum(e,Std.string(e) );
				en;
			
			case TObject:
				var obj : Dynamic = {}; 
				for( ff in Reflect.fields(v) ) 
					Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff))); 
				obj; 
			
			case TClass(c):
				var fields = Reflect.fields(v);
				//pour gérer string par exemple
				//des not work with hash :(
				if ( fields.length == 0 )
				{
					Type.createInstance(c, [v]);
				}
				else
				{
					var obj = Type.createEmptyInstance(c); 
					for( ff in fields ) 
						Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff))); 
					obj; 
				}
			
			case TUnknown://TODO
				v;
				//Reflect.copy(v);
				//Unserializer.run( Serializer.run( v ) );
		}
	} 

	public static function id() {
		
	}
}
