package data;

import data.Map;
import algo.Graph;

import Protocol;
using Ex;


/**
 * ...
 * @author de
 */

class Level
{
	public static var map : SpaceShipData;
	public static var mapExt : ComputedMapData;
	
	public static var woundAscGraph = new Graph();
	public static var woundDescGraph = new Graph();
	
	static var d =
	{
		var r : SpaceShipData = Map.s1.logic;

		Debug.ASSERT( r != null);
		finalizeMap( r);
		
		#if !data_lite
		for(t in Protocol.titleList)
		{
			var hl = HeroId.array();
			if( t.priority.length != hl.length )
				t.priority.enqueue( hl.filter( function(h) return !Lambda.has(t.priority, h )) );
				
			Debug.ASSERT(t.priority.length <= EnumEx.length( HeroId ) );
		}
		
		for( wnd in Protocol.woundList )
		{
			woundAscGraph.addNode( wnd.id );
			woundDescGraph.addNode( wnd.id );
		}
		
		for( wnd in Protocol.woundList )
		{
			if(wnd.over_ride!=null)
			{
				woundAscGraph.edge( wnd.id.index(), wnd.over_ride.index(), 1, false);
				woundDescGraph.edge( wnd.over_ride.index(), wnd.id.index(), 1, false);
			}
		}
		
		if( Protocol.objects_bg_list.length < Protocol.itemList.length )
		{
			var diff = Protocol.itemList.filter( function(i)
			{
				var ok = false;
				for(j in Protocol.objects_bg_list)
				{
					if( i.id == j.id )
					{
						ok = true;
						break;
					}
				}
				return !ok;
				}).map(function(i)return i.id);
			throw "Problem :" + diff +" have no bg";			// TODO reinserer le throw ( consomable )
		}
		#end
		
		null;
	}
	
	public static function finalizeMap(r : SpaceShipData)
	{
		var cmd : ComputedMapData =
		{
			maxCrew : 0,
		};
		
		r.rooms.push( { id:	RoomId.LIMBO, 		pos: [ new V2I( 70, 70 ) ], doors:[] } );
		r.rooms.push( { id: RoomId.OUTER_SPACE,	pos: [ new V2I( 70, 70 ) ], doors:[] } );
		r.rooms.push( { id: RoomId.PLANET, 		pos: [ new V2I( 70, 70 )], 	doors:[]} );
		
		//cmd.initialCrew = HeroId.array().excepta([ADMIN,DEREK_HOGAN,ANDIE_GRAHAM]);
		cmd.maxCrew = 16;
		
		for(x in Protocol.roomList)
			if( x.type == PATROL_SHIP )
				r.rooms.push( { id: x.id, 	pos:[ new V2I(70, 70) ], doors:[] } );
				
		r.roomsById = new IntHash();
		for ( rr in r.rooms )
			r.roomsById.set(rr.id.index(), rr );
		
		map = r;
		Debug.ASSERT( r.rooms != null);
		mapExt = cmd;
	}
	
	#if neko
	public static function getCast() :Array<HeroId>{
		var hidl = HeroId.array();
		hidl.remove(ADMIN);
		
		var season = db.Season.current();
		
		if ( season.flags.has( SF_ANDREK )) {
			hidl.remove(FINOLA_KEEGAN);
			hidl.remove(WANG_CHAO);
		}
		else {
			hidl.remove(DEREK_HOGAN);
			hidl.remove(ANDIE_GRAHAM);
		}
		
		return hidl;
	}
	#end
}