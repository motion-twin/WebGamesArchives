package mt.geom;

import flash.geom.Point;
import flash.geom.Rectangle;
import mt.MLib;

class RectangleTools
{
	static var TMP_POINT = new Point();
	inline public static function intersect(r1:Rectangle, r2:Rectangle):Bool
	{
		if ( r1.equals(r2) ) return true;
		else if ( r1.containsRect(r2) || r2.containsRect(r1) ) return true;
		else return !(r1.left > r2.right || r1.right < r2.left || r1.top > r2.bottom || r1.bottom < r2.top);
	}
	
	/**
	 * Calculates the intersection between two Rectangles. If the rectangles do not intersect,
	 * this method returns an empty Rectangle object with its properties set to 0. 
	 */
	inline public static function intersection(rect1:Rectangle, rect2:Rectangle, resultRect:Rectangle=null):Rectangle
	{
		if( resultRect == null ) resultRect = new Rectangle();
		//
		var left   = MLib.fmax(rect1.x, rect2.x);
		var right  = MLib.fmin(rect1.x + rect1.width, rect2.x + rect2.width);
		var top    = MLib.fmax(rect1.y, rect2.y);
		var bottom = MLib.fmin(rect1.y + rect1.height, rect2.y + rect2.height);
		if( left > right || top > bottom )
			resultRect.setEmpty();
		else
			RectangleTools.setTo(resultRect, left, top, right-left, bottom-top);
		return resultRect;
	}
	
	inline public static function area(r:Rectangle)
	{
		return r.height * r.width;
	}
	
	public static function scale(r:Rectangle, factor:Float, ?factorY:Float):Rectangle
	{
		var sx = factor, sy = (factorY == null) ? factor : factorY;
		var ox = r.width * (sx - 1);
		var oy = r.height * (sy - 1);
		r.x -= ox/2;
		r.y -= oy/2;
		r.width += ox;
		r.height += oy;
		return r;
	}
	
	inline public static function set(r:Rectangle, x, y, w, h):Rectangle
	{
		r.x = x;
		r.y = y;
		r.width = w;
		r.height = h;
		return r;
	}
	
	inline public static function setTo(r:Rectangle, x, y, w, h):Rectangle
	{
		r.x = x;
		r.y = y;
		r.width = w;
		r.height = h;
		return r;
	}
	
	inline public static function addPoint( r : Rectangle, point : { x:Float, y:Float } ):Rectangle
	{
		if( r.top > point.y ) r.top = point.y;
		if( r.bottom < point.y ) r.bottom = point.y;
		if( r.left > point.x ) r.left = point.x;
		if( r.right < point.x ) r.right = point.x;
		return r;
	}
	
	inline public static function copyFrom(rDest:Rectangle, rSrc:Rectangle) : Rectangle
	{
		rDest.x = rSrc.x;
		rDest.y = rSrc.y;
		rDest.width = rSrc.width;
		rDest.height = rSrc.height;
		return rDest;
	}
	
	inline public static function distanceFromPoint(r:Rectangle, p:Point ):Float
	{
		inline function dist(p1:Point, p2:Point) {
			return Math.sqrt( (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y) );
		}
		TMP_POINT.setTo(r.left,r.top);
		var d1 = dist(TMP_POINT, p);
		TMP_POINT.setTo(r.right, r.top);
		var d2 = dist(TMP_POINT, p);
		TMP_POINT.setTo(r.left, r.bottom);
		var d3 = dist(TMP_POINT, p);
		TMP_POINT.setTo(r.right, r.bottom);
		var d4 = dist(TMP_POINT, p);
		
		return MLib.fmin(d1, MLib.fmin(d2, MLib.fmin(d3, d4)));
	}
}