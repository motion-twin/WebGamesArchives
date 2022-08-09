package mt.kiroukou.geom;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

using RectangleTools;
class CollisionTools
{
	inline public static function getCollisionRect(target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, ?pixelPrecise:Bool = false, ?tolerance:Float = 255):Rectangle
	{
		// get bounding boxes in common parent's coordinate space
		var rect1:Rectangle = target1.getBounds(commonParent);
		var rect2:Rectangle = target2.getBounds(commonParent);
		// find the intersection of the two bounding boxes
		var intersectionRect:Rectangle = rect1.intersection(rect2);
		// if not pixel-precise, we're done
		if( pixelPrecise)
		{
			// size of rect needs to be integer size for bitmap data
			intersectionRect.x = Math.floor(intersectionRect.x);
			intersectionRect.y = Math.floor(intersectionRect.y);
			intersectionRect.width = Math.ceil(intersectionRect.width);
			intersectionRect.height = Math.ceil(intersectionRect.height);
			// if the rect is empty, we're done
			if( !intersectionRect.isEmpty())
			{
				var x = intersectionRect.x;
				var y = intersectionRect.y;
				// calculate the transform for the display object relative to the common parent
				var parentXformInvert:Matrix = commonParent.transform.concatenatedMatrix.clone();
				parentXformInvert.invert();
				var target1Xform:Matrix = target1.transform.concatenatedMatrix.clone();
				target1Xform.concat(parentXformInvert);
				var target2Xform:Matrix = target2.transform.concatenatedMatrix.clone();
				target2Xform.concat(parentXformInvert);
				// translate the target into the rect's space
				target1Xform.translate(-x, -y);
				target2Xform.translate(-x, -y);
				// combine the display objects
				var bd:BitmapData = new BitmapData(Std.int(intersectionRect.width), Std.int(intersectionRect.height), false);
				bd.draw(target1, target1Xform, new ColorTransform(1, 1, 1, 1, 255, -255, -255, tolerance), BlendMode.NORMAL);
				bd.draw(target2, target2Xform, new ColorTransform(1, 1, 1, 1, 255, 255, 255, tolerance), BlendMode.DIFFERENCE);
				// find overlap
				intersectionRect = bd.getColorBoundsRect(0xffffffff, 0xff00ffff);
				intersectionRect.offset(x, y);
				bd.dispose();
				bd = null;
			}
		}
		return intersectionRect;
	}
	
	inline public static function collide( target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, ?pixelPrecise:Bool = false, ?tolerance:Int = 255, ?size:Float = 1.0 ):Bool
	{
		return getCollisionRect(target1, target2, commonParent, pixelPrecise, tolerance).area() >= size;
	}

}