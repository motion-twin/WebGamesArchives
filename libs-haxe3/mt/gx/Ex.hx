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
typedef EmbedEnumFlagsEx = mt.gx.EnumFlagsEx;

#if(flash||nme||openfl)
typedef EmbedAsLib 			= mt.gx.as.Lib;
typedef EmbedColTransEx 	= mt.gx.as.ColTransEx;
typedef EmbedMcEx 			= mt.gx.as.McEx;
typedef EmbedBt 			= mt.gx.as.Button;

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
typedef K 					= flash.ui.Keyboard;
#end

#if h3d
typedef EmbedH2dEx 			= mt.gx.h2d.Ex;
typedef EmbedH2dButton		= mt.gx.h2d.Button;
typedef EmbedH2dBoundEx 	= mt.gx.h2d.Ex.BoundsEx;
#end

@:publicFields
class Ex {
}
