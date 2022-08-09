package algo;

/**
 * ...
 * @author de
 */

typedef CRData
{
	handleIn : V2D;
	pointIn : V2D;
	pointOut : V2D;
	handleOut : V2D;
}

class CatmullRom 
{
	public static function process( segment : CRData, t : Float ) : V2D
	{
		var res = new V2D();
		
		var c0 : V2D = V2D.scale( new V2D(0,0), 2, segment.pointIn);
		var c1 : V2D = V2D.scale( new V2D(0, 0), t, V2D.add( 	new V2D(), 
																V2D.neg( new V2D(), V2D( segment.handleIn, ),
																segment.pointOut)
								);
		
		var t2 = t * t;
		var c2 : V2D =  V2D.scale( 	new V2D(0, 0), t2,
									
									V2D.add( 
										new V2D(),
										V2D.add( 
													new V2D(),
													V2D.scale( 	new V2D(),
																2,
																segment.handleIn)
													
													V2D.scale( 	new V2D(),
																-5,
																segment.pointIn)
												)
										,
										V2D.add(	
											V2D.scale( 	new V2D(),
														4,
														segment.pointOut),
														
											V2D.neg( 	new V2D(),
														segment.handleOut)
												)));
		
		var t3 = t2 * t;
		var c3 : V2D =  V2D.scale( 	new V2D(0, 0), t3,
									V2D.add( 
										new V2D(),
										V2D.add( 
													new V2D(),
													V2D.neg( 	new V2D(),
																segment.handleIn)
													
													V2D.scale( 	new V2D(),
																3,
																segment.pointIn)
												)
										,
										V2D.add(	
												V2D.scale( 	new V2D(),
															3,
															segment.pointOut)
												,
												segment.handleOut)
												));
		
		V2D.incr( res, c0 );
		V2D.incr( res, c1 );
		V2D.incr( res, c2 );
		V2D.incr( res, c3 );
		V2D.scale( res, 0.5, res );
		
		return res;
	}
	
}