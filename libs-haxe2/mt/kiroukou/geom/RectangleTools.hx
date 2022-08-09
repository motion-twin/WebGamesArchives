package mt.kiroukou.geom;

import flash.geom.Rectangle;

class RectangleTools
{

	inline public static function intersect(r1:Rectangle, r2:Rectangle):Bool
	{
		return !(r1.left > r2.right || r1.right < r2.left || r1.top > r2.bottom || r1.bottom < r2.top);
	}

	inline public static function intersectionRect(r1:Rectangle, r2:Rectangle, dest:Rectangle):Bool
	{
		var i = false;
		if(intersect(r1, r2))
		{
			dest.left 	= Math.max(r1.left, r2.left);
			dest.top 	= Math.max(r1.top, r2.top);
			dest.right 	= Math.min(r1.right, r2.right);
			dest.bottom = Math.min(r1.bottom, r2.bottom);
			i = true;
		}
		return i;
	}

	inline public static function area(r:Rectangle)
	{
		return r.height * r.width;
	}
	
	inline public static function init(r:Rectangle, x, y, w, h):Rectangle
	{
		r.x = x;
		r.y = y;
		r.width = w;
		r.height = h;
		return r;
	}
	
	public static function scale(r:Rectangle, factor:Float):Rectangle
	{
		var ox = r.width * (factor - 1);
		var oy = r.height * (factor - 1);
		r.x -= ox/2;
		r.y -= oy/2;
		r.width += ox;
		r.height += oy;
		return r;
	}
	
	inline public static function merge( a:Rectangle, b:Rectangle, ?dest:Rectangle ):Rectangle
	{
		if( dest == null ) dest = a;
		var top = Math.min(a.top, b.top);
		var bottom = Math.max(a.bottom, b.bottom);
		var right = Math.max(a.right, b.right);
		var left = Math.min(a.left, b.left);
		init(dest, left, top, right - left, bottom - top);
		return dest;
	}
	
	inline public static function addPoint( r : Rectangle, point : { x:Float, y:Float } ):Rectangle
	{
		if( r.top > point.y ) r.top = point.y;
		if( r.bottom < point.y ) r.bottom = point.y;
		if( r.left > point.x ) r.left = point.x;
		if( r.right < point.x ) r.right = point.x;
		return r;
	}
	
	inline public static function cpy(rDest:Rectangle, rSrc:Rectangle) : Rectangle
	{
		rDest.x = rSrc.x;
		rDest.y = rSrc.y;
		rDest.width = rSrc.width;
		rDest.height = rSrc.height;
		return rDest;
	}
	
	inline public static function createBounds( r:Rectangle, pts:Array<{x:Float, y:Float}> ) : Rectangle
	{
		var minX = pts[0].x;
		var maxX = minX;
		var minY = pts[0].y;
		var maxY = minY;
		for( p in pts )
		{
			if( p.x < minX ) minX = p.x;
			if( p.x > maxX ) maxX = p.x;
			if( p.y < minY ) minY = p.y;
			if( p.y > maxY ) maxY = p.y;
		}
		init( r, minX, minY, (maxX - minX), (maxY - minY) );
		return r;
	}
}