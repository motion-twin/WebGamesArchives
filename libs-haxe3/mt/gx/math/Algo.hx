package mt.gx.math;

class Algo
{
	//http://fr.wikipedia.org/wiki/Algorithme_de_trace_de_segment_de_Bresenham
	//draw result points in order 
	public static function bresenham(x1, y1, x2, y2, proc : Int->Int->Void)
	{
		var y, dx, dy = 0;
		var e = 0.0, e10, e01;
		
		dx = x2 - x1;
		dy = y2 - y1;
		y = y1;
		e10 = dy / dx;
		e01 = -1.0;
		
		if ( x1 != x2)
		{
			if( x1 < x2 )
			for ( x in x1...x2)
			{
				proc(x, y);
				if (y2 != y1)
				{
					if ( y2 > y1)
					{
						if ( (e += e10) >= 0.5)
						{
							y++;
							e += e01;
						}
					}
					else
					{
						if ( (e += e10) >= 0.5)
						{
							y--;
							e += e01;
						}
					}
				}
			}
			else
			{
				var vx = x1;
				while ( vx > x2 )
				{
					proc(vx, y);
					if (y2 != y1)
					{
						if ( y2 > y1)
						{
							if ( (e += e10) <=  - 0.5)
							{
								y++;
								e -= e01;
							}
						}
						else
						{
							if ( (e += e10) >= 0.5)
							{
								y--;
								e += e01;
							}
						}
					}
					vx--;
				}
			}
		}
		else
		{
			if ( y1 < y2 )
			{
				for ( y in y1...y2)
					proc(x1, y);
			}
			else
			{
				var y = y1;
				while( y > y2 )
					proc(x1, y--);
			}
		}
		proc(x2, y2);
	}
	
	public static function testBresenham()
	{
		var r = [];
		function tb(x:Int, y:Int)
		{
			trace(x + " " + y); 
			r.push( { x:x, y:y } );
		}
			
		
		for ( xayaxbyb in 
		[ 
		
			//vertical
			[ { x:0, y:0 }, { x:0, y:10 } ],
			
			//vertical swapped
			[ { x:0, y:10 }, { x:0, y:0 } ],
			
			//horiz
			[ { x:0, y:0 }, { x:10, y:0 } ],
			
			//horiz swapped
			[ { x:10, y:0 }, { x:0, y:0 } ],
			
			//regular tlbr case
			[ { x:0, y:0 }, { x:10, y:0 } ],
			[ { x:0, y:0 }, { x:10, y:9 } ],
			[ { x:0, y:0 }, { x:10, y:10 } ],
			[ { x:0, y:0 }, { x:10, y:11 } ],
			
			[ { x:10, y:-1 }, { x:0, y:-1 } ],
			[ { x:10, y:0 }, { x:0, y:0 } ],
			[ { x:10, y:1 }, { x:0, y:1 } ],
			
			[ { x:10, y:1 }, { x:0, y:-1 } ],
			[ { x:10, y:0 }, { x:0, y:0 } ],
			[ { x:10, y:-1 }, { x:0, y:1 } ],
		]
		)
		{
			r = [];
			trace("testing : " + xayaxbyb);
			bresenham( xayaxbyb[0].x, xayaxbyb[0].y,
			 xayaxbyb[1].x, xayaxbyb[1].y, tb);
			mt.gx.Debug.assert(r[0].x == xayaxbyb[0].x && r[0].y == xayaxbyb[0].y);
			mt.gx.Debug.assert( mt.gx.ArrayEx.last(r).x==xayaxbyb[1].x && mt.gx.ArrayEx.last( r ).y==xayaxbyb[1].y);
			trace("*******");
		}
	}
}