package algo;

using Ex;

import Data;
import haxe.ds.GenericStack;
import Types;

class SweepRenderer
{
	public static inline function MSG(x, ?y)
	{
		#if false
			Debug.MSG(x, y);
		#else
			
		#end
	}

	static inline function sortFunc( e0:SweepEntry,e1:SweepEntry)
	{
		if( e0.rect[0].y <  e1.rect[0].y )
		{
			return -1;
		}
		else if ( e0.rect[0].y >  e1.rect[0].y )
		{
			return 1;
		}
		else
		{
			return e0.rect[0].x - e1.rect[0].x;
		}
	}
		
	public static function doSweep( inList : Array<SweepEntry>) : Iterable<SweepEntry>
	{
		//MSG("*_* SWEEPIN *_*");
		var l = inList;
		
		l.sort( sortFunc );
		
		var activeList = [];
		var renderList = new List();
		var currentYLap = new V2I();
		
		for( elem in l )
		{
			//var i = elem.ent.setup.index;
			
			//anyone here?
			if( activeList.length == 0) // no one
			{
				//set as current
				activeList.push( elem );
				currentYLap.set(elem.rect[0].y, elem.rect[1].y);
				continue;
			}
			
			//y overlaps?
			if( currentYLap.x > elem.rect[1].y
			||	currentYLap.y < elem.rect[0].y
			)
			{ 	//no overlap
				//flush current to render
				for( x in activeList )
					renderList.pushBack( x );
				
				activeList = [];
				
				//setup current elem as active
				activeList.push( elem );
				currentYLap.set(elem.rect[0].y, elem.rect[1].y);
				continue;
			}
			else // there is an overlap, add it to the grape
			{
				addToGrape( activeList, elem );
				currentYLap.set( 	MathEx.mini( currentYLap.x, elem.rect[0].y),
									MathEx.maxi( currentYLap.y, elem.rect[1].y));
			}
		}
		
		//finish it!
		//activeList.reverse();
		for( x in activeList )
			renderList.pushBack( x );
		
		//MSG( "sweep:" + renderList.map(function(s) return s.ent.te.setup.index).join(",") );
		return renderList;
	}
	
	//e0 is beyond e1 that is nearer to the vie
	static inline function isBeyond(e0 : SweepEntry, e1 : SweepEntry) : Bool
	{
		if ( Coll.testRectInRectAI( e1.rect, e0.rect) )
			return e0.ent.getPrio() > e1.ent.getPrio();
		else
		if ( Coll.testRectInRectAI( e0.rect, e1.rect) )
			return e1.ent.getPrio() < e0.ent.getPrio();
		else 
		return( e0.rect[1].y <=  e1.rect[1].y
			&&	 e0.rect[1].x <= e1.rect[1].x);
	}
	
	static inline function addToGrape( grape : Array<SweepEntry>, elem : SweepEntry)
	{
		var ok = false;
		for( x in 0...grape.length)
			if( isBeyond( elem, grape[x] ) )
			{
				grape.insert( x , elem );
				ok = true;
				break;
			}
		
		if( !ok )
			grape.push( elem );
	}
}