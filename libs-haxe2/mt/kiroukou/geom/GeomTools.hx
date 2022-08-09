
package mt.kiroukou.geom;
import mt.kiroukou.math.Vec2;

enum Intersection
{
	COINCIDENT;
	PARALLEL;
	INTERSECTING;
	NOT_INTERSECTING;
}

class GeomTools
{
	inline static public function inpoly( p:Array<Vec2>, pt:Vec2):Bool
    {
		var i, j, c, n;
		n = p.length;
		c = false;
		i = 0;
		j = n - 1;
		while ( i < n )
		{
			if( (((p[i].y <= pt.y) && (pt.y < p[j].y)) ||
				((p[j].y <= pt.y) && (pt.y < p[i].y))) &&
				(pt.x < (p[j].x - p[i].x) * (pt.y - p[i].y) / (p[j].y - p[i].y) + p[i].x))
			{
				c = !c;
			}
			//
			j = i++;
		}
		return c;
    }
	
	inline static public function sideFromLine( p:Vec2, start:Vec2, end:Vec2 )
	{
		return ( (end.x - start.x) * (p.y - start.y) - (end.y - start.y) * (p.x - start.x) );
	}
	
	
	inline static public function intersectionLines( a: Vec2, b: Vec2, c: Vec2, d: Vec2, intersection:Vec2, ?isSegment:Bool=false)
	{
		var denom 	= 	((d.y - c.y)*(b.x - a.x)) -
						((d.x - c.x)*(b.y - a.y));

        var nume_a 	= 	((d.x - c.x)*(a.y - c.y)) -
						((d.y - c.y)*(a.x - c.x));

        var nume_b 	= 	((b.x - a.x)*(a.y - c.y)) -
						((b.y - a.y)*(a.x - c.x));

		var r = false;
        if(denom != 0.0)
        {
			var ua = nume_a / denom;
			var ub = nume_b / denom;

			if( !isSegment || (ua >= 0.0 && ua <= 1.0 && ub >= 0.0 && ub <= 1.0 ) )
			{
				// Get the intersection point.
				intersection.x = a.x + ua*(b.x - a.x);
				intersection.y = a.y + ua*(b.y - a.y);
				r = true;
			}
		}
        return r;
	}
	
	inline static public function areParallel( a:Vec2, b:Vec2, c:Vec2, d:Vec2 )
	{
		var denom 	= 	((d.y - c.y)*(b.x - a.x)) -
						((d.x - c.x)*(b.y - a.y));
        return (denom == 0.0);
	}
	
	inline static public function areCoincident( a:Vec2, b:Vec2, c:Vec2, d:Vec2 )
	{
		var denom 	= 	((d.y - c.y)*(b.x - a.x)) -
						((d.x - c.x)*(b.y - a.y));

        var nume_a 	= 	((d.x - c.x)*(a.y - c.y)) -
						((d.y - c.y)*(a.x - c.x));

        var nume_b 	= 	((b.x - a.x)*(a.y - c.y)) -
						((b.y - a.y)*(a.x - c.x));

		denom = Math.abs(denom);
		nume_a = Math.abs(nume_a);
		nume_b = Math.abs(nume_b);
		return (denom < 0.0001 && nume_a < 0.0001 && nume_b < 0.0001 );
		//  return (denom == 0.0 && nume_a == 0.0 && nume_b == 0.0);
	}
	
	static public function intersectionLinesFull( a: Vec2, b: Vec2, c: Vec2, d: Vec2, intersection: Vec2, ?isSegment:Bool=false)
	{
		var denom 	= 	((d.y - c.y)*(b.x - a.x)) -
						((d.x - c.x)*(b.y - a.y));

        var nume_a 	= 	((d.x - c.x)*(a.y - c.y)) -
						((d.y - c.y)*(a.x - c.x));

        var nume_b 	= 	((b.x - a.x)*(a.y - c.y)) -
						((b.y - a.y)*(a.x - c.x));

        if(denom == 0.0)
        {
            if(nume_a == 0.0 && nume_b == 0.0)
            {
                return Intersection.COINCIDENT;
            }
            return Intersection.PARALLEL;
        }

        var ua = nume_a / denom;
        var ub = nume_b / denom;

        if(!isSegment || (ua >= 0.0 && ua <= 1.0 && ub >= 0.0 && ub <= 1.0) )
        {
            // Get the intersection point.
            intersection.x = a.x + ua*(b.x - a.x);
            intersection.y = a.y + ua*(b.y - a.y);

            return Intersection.INTERSECTING;
        }

        return Intersection.NOT_INTERSECTING;
	}
}