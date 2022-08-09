package ;

import MathEx;
import V2D;

/**
 * ...
 * @author de
 */

 typedef Rect = { x:Int, y:Int, width:Int, height:Int };
 
class Coll 
{
	//////////////////////////////////////////////////
	public static inline function testCircleCircle( 	v0 : V2D, r0 : Float,
														v1 : V2D, r1 : Float
	) : Bool
	{
		var radius2 = r0 + r1;
		radius2 *= radius2;
		var diffx =  v1.x - v0.x;
		var diffy =  v1.y - v0.y;
		var len2 = diffx * diffx +  diffy * diffy;
		return( radius2 >= len2 );
	}
	
	//////////////////////////////////////////////////
	public static inline function testCircleVtx( 	v0 : V2D, r0 : Float,
													v1 : V2D
	) : Bool
	{
		var radius2 = r0*r0;
		var diffx =  v1.x - v0.x;
		var diffy =  v1.y - v0.y;
		var len2  = diffx * diffx +  diffy * diffy;
		return( radius2 >= len2 );
	}
	
	//////////////////////////////////////////////////
	//P0 = TL  P1 = BR
	public static function testCircleRect( 	v0 : V2D, r0 : Float,
											p0 : V2D, p1 : V2D
	) : Bool
	{
		var rectCenter : V2D  = new V2D(0,0);
		
		V2D.add( rectCenter , p0, p1);
		V2D.scale( rectCenter, 0.5, rectCenter);

		var isInBS : Bool = testCircleCircle( rectCenter, V2D.dist( p0, rectCenter) , v0, r0);
		
		if (!isInBS)
		{
			return false;
		}

		var res=( 	v0.x - r0 < p1.x 
		&& 				v0.x + r0 > p0.x 
		&&				v0.y + r0 > p0.y 
		&& 				v0.y - r0 < p1.y );
	
		
		return  res;
	}
	
	public static function testRectRect( 	p00 : V2D, p01 : V2D,
											p10 : V2D, p11 : V2D
	) : Bool
	{
		
		//easy dude
		if ( p00.x > p11.x)
		{
			return false;
		}
		
		if ( p01.x < p10.x)
		{
			return false;
		}
		
		if ( p01.y < p10.y)
		{
			return false;
		}
		
		if ( p00.y > p11.y)
		{
			return false;
		}
		
		return true;
	}
	
	public static function testVtxRect( 	p00 : V2D,
											p10 : V2D, p11 : V2D
	) : Bool
	{
		
		return 	p00.x >= p10.x && p00.x < p11.x
		&&		p00.y >= p10.y && p00.y < p11.y;
	}
	
	public static function testVtxRect_2( 	x : Float,y : Float,
											r : Rect
	) : Bool
	{
		return 	x >= r.x	&& x < r.x + r.width
		&&		y >= r.y 	&& y < r.y + r.height;
	}
	
	/*
	 * 
	 * allows only 
	 * 
	 * D		DD	   D
	 *  D or 		or D
	 */
	public static function testTouchRectRect( 	rectA : Rect,
												rectB : Rect) : Bool
	{
		var isIncl = 
		testRectRect( 	new V2D(rectA.x, rectA.y), new V2D(rectA.x+rectA.width, rectA.y+rectA.height),
						new V2D(rectB.x, rectB.y), new V2D(rectB.x+rectB.width, rectB.y+rectB.height)		);
		
		if (isIncl)
		{
			if (	rectA.x == rectB.x + rectB.width 
			&&		rectA.y == rectB.y + rectB.height
			)
			{
				return false;
			}
			
			if (	rectA.x + rectA.width  == rectB.x
			&&		rectA.y + rectA.height == rectB.y 
			)
			{
				return false;
			}
			
			if (	rectA.x + rectA.width == rectB.x
			&&		rectA.y == rectB.y + rectB.height
			)
			{
				return false;
			}
			
			if (	rectA.x  == rectB.x + rectB.width
			&&		rectA.y + rectA.height== rectB.y
			)
			{
				return false;
			}
			
			return true;
		}
		return false;
	}
	
	public static inline function testRectInRectAI( 	v0 : Array<V2I>,
														v1 : Array<V2I>
	) : Bool
	{
		var p00 = v0[0];
		var p01 = v0[1];
		var p10 = v1[0];
		var p11 = v1[1];
		
		return 	( p00.x >= p10.x && p01.x <= p11.x )
		&&		( p00.y >= p10.y && p01.y <= p11.y );
	}
}