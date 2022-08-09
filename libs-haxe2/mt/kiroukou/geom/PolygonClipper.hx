/**
 * ...
 * @author Thomas
 */

package mt.kiroukou.geom;
import mt.kiroukou.math.Vec2;

class PolygonClipper 
{
	inline static public function clipEdge( polygon:Array<Vec2>, start:Vec2, end:Vec2 )
	{
		var clippedPolygon = [];
		var intersection = new Vec2();
		var e0 = start;
		var e1 = end;
		var n = polygon.length - 1;
		var s, p, ds, dp;
		//
		if(  n > 0 )
		{
			s = polygon[n];
			ds = geom.GeomTools.sideFromLine( s, e0, e1 );
			for (i in 0...n+1)
			{
				p = polygon[i];
				dp = geom.GeomTools.sideFromLine( p, e0, e1 );
				//inside
				if( dp >= 0 )
				{
					//inside
					if( ds >= 0 )
					{
						clippedPolygon.push( p );
					}
					else
					{
						geom.GeomTools.intersectionLines(s, p, e0, e1, intersection);
						clippedPolygon.push(intersection.clone());
						clippedPolygon.push(p);
					}
				}
				else
				{
					if( ds >= 0 )
					{
						geom.GeomTools.intersectionLines(s, p, e0, e1, intersection);
						clippedPolygon.push(intersection.clone());
					}
				}
				s = p;
				ds = dp;
			}
		}
		return clippedPolygon;
	}

	inline static public function clip( polygon:Array<Vec2>, region:Array<Vec2> )
	{
		var inside = 0;
		for (i in 0...polygon.length)
		{
			var p = polygon[i];
			if(  GeomTools.inpoly( region, p ) )
				inside++;
		}
		if(  inside != polygon.length )
		{
			var n = region.length - 1;
			var e0 = region[n];
			// for all clipping edges
			for ( i in 0...n+1 )
			{
				var e1 = region[i];
				polygon = clipEdge( polygon, e0, e1 );
				e0 = e1;
			}
		}
		return polygon;
	}
	
}