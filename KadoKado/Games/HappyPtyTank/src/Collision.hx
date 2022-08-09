import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/*

	Original AS3 source code from Troy Gilbert
	(http://troygilbert.com/category/game-dev/)

*/
class Collision {

	/**
	   Get the collision rectangle between two display objects.
	**/
	public static function getCollisionRect( target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, pixelPrecise:Bool = false, tolerance:Int = 0 ) : Rectangle {
		// find the intersection of the two bounding boxes
		var intersectionRect = target1.getBounds(commonParent).intersection(target2.getBounds(commonParent));
		if (intersectionRect.size.length > 0){
			if (pixelPrecise){
				// size of rect needs to integer size for bitmap data
				intersectionRect.width = Math.ceil(intersectionRect.width);
				intersectionRect.height = Math.ceil(intersectionRect.height);
				// get the alpha maps for the display objects
				var alpha1 = getAlphaMap(target1, intersectionRect, BitmapDataChannel.RED, commonParent);
				var alpha2 = getAlphaMap(target2, intersectionRect, BitmapDataChannel.GREEN, commonParent);
				// combine the alpha maps
				alpha1.draw(new flash.display.Bitmap(alpha2), null, null, BlendMode.LIGHTEN);
				// calculate the search color
				var searchColor : Int;
				if (tolerance <= 0){
					searchColor = 0x010100;
				}
				else {
					if (tolerance > 1)
						tolerance = 1;
					var byte = Math.round(tolerance * 255);
					searchColor = (byte <<16) | (byte <<8) | 0;
				}
				// find color
				var collisionRect = alpha1.getColorBoundsRect(searchColor, searchColor);
				collisionRect.x += intersectionRect.x;
				collisionRect.y += intersectionRect.y;
				return collisionRect;
			}
			return intersectionRect;
		}
		return null;
	}

	/**
	   Gets the alpha map of the display object and places it in the specified channel.
	**/
	private static function getAlphaMap( target:DisplayObject, rect:Rectangle, channel:Int, commonParent:DisplayObjectContainer ) : BitmapData {
		// calculate the transform for the display object relative to the common parent
		var parentXformInvert = commonParent.transform.concatenatedMatrix.clone();
		parentXformInvert.invert();
		var targetXform = target.transform.concatenatedMatrix.clone();
		targetXform.concat(parentXformInvert);
		// translate the target into the rect's space
		targetXform.translate(-rect.x, -rect.y);
		// draw the target and extract its alpha channel into a color channel
		var bitmapData = new BitmapData(Math.round(rect.width), Math.round(rect.height), true, 0);
		bitmapData.draw(target, targetXform);
		var alphaChannel = new BitmapData(Math.round(rect.width), Math.round(rect.height), false, 0);
		alphaChannel.copyChannel(bitmapData, bitmapData.rect, new Point(0, 0), BitmapDataChannel.ALPHA, channel);
		return alphaChannel;
	}

	/**
	   Get the center of the collision's bounding box.
	**/
	public static function getCollisionPoint( target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, pixelPrecise:Bool = false, tolerance:Int = 0 ) : Point {
		var collisionRect = getCollisionRect(target1, target2, commonParent, pixelPrecise, tolerance);
		if (collisionRect != null && collisionRect.size.length> 0){
			var x = (collisionRect.left + collisionRect.right) / 2;
			var y = (collisionRect.top + collisionRect.bottom) / 2;
			return new Point(x, y);
		}
		return null;
	}

	/**
	   Are the two display objects colliding (overlapping)?
	**/
	public static function isColliding( target1:DisplayObject, target2:DisplayObject, commonParent:DisplayObjectContainer, pixelPrecise:Bool = false, tolerance:Int = 0 ) : Bool {
		var collisionRect = getCollisionRect(target1, target2, commonParent, pixelPrecise, tolerance);
		return (collisionRect != null && collisionRect.size.length > 0);
	}
}
