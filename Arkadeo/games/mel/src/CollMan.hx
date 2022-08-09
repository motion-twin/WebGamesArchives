import mt.gx.math.Vec2;

class CollMan
{
	//////////////////////////////////////////////////
	public static inline function testCircleCircle( 	v0 : Vec2, r0 : Float,
														v1 : Vec2, r1 : Float
	) : Bool
	{
		var r  = r0 + r1;
		r *= r;
		var dx =  v1.x - v0.x;
		var dy =  v1.y - v0.y;
		return( r >= (dx*dx + dy*dy) );
	}
	
	//////////////////////////////////////////////////
	public static inline function testCircleVtx( 	v0 : CV2D, r : Float,
													v1 : CV2D
	) : Bool
	{
		var r2 = r*r;
		var dx = v1.x - v0.x;
		var dy = v1.y - v0.y;
		return( r2 >= (dx*dx+ dy*dy) );
	}
	
	//////////////////////////////////////////////////
	//P0 = TL  P1 = BR
	public static inline function testCircleRect( 	v0 : Vec2, r0 : Float,
													p0 : Vec2, p1 : Vec2
	) : Bool
	{
		var rc : Vec2  = new Vec2()
		
		rc.add( rc , p0, p1);
		rc.scale( rc, 0.5 )

		var inBs : Bool = testCircleCircle(rc, Vec2.dist( _P0, l_RectCenter) , v0, r0);
		if (!inBs)
			return false;
		else
		{
			var r=( 		v0.x - r0 < p1.x
			&& 				v0.x + r0 > p0.x
			&&				v0.y + r0 > p0.y
			&& 				v0.y - r0 < p1.y );
			
			return r;
		}
	}
	
	//////////////////////////////////////////////////
	public static function testRectRect( 	p00 : Vec2, p01 : Vec2,
											p10 : Vec2, p11 : Vec2
	) : Bool
	{
		if ( p00.x > p11.x)
			return false;
		if ( p01.x < p10.x)
			return false;
		if ( p01.y < p10.y)
			return false;
		if ( p00.y > p11.y)
			return false;
		
		return true;
	}
	
}