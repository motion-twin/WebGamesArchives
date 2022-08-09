package ;

import db.Ship;
import Protocol;
import Types;

using Ex;
using ItemUtils;

/**
 * ...
 * @author de
 */
class ItemUtils
{
	
	public static function data(i:ItemId) : ItemData
		return Protocol.itemDb(i);
	
	public static function isBrokable( o : ItemDesc)
		return Protocol.itemDb( o.id).rep > 0 && !o.status.has( DESTRUCTIBLE );
		
	public static function canBreak( o : ItemDesc)
		return isBrokable(o);
	
	public static function isCookable( i :ItemDesc ) : Bool
	{
		if( i.id != CONSUMABLE ) return false;
		
		var sk = getSkin( i );
		if( sk == null ) return false;
		
		return
		switch(sk.t)
		{
			case SK_RATION: Protocol.rations[sk.v].effect.has( COOKABLE );
			default: false;
		}
	}
	
	public static function eatables(d: Iterable<ItemDesc>) : List<ItemDesc>
	{
		return d.filter( function( i)  return ( i.id == CONSUMABLE ) );
	}
	
	public static function getSkin( i :ItemDesc ): {t:SkinType,v:Int}
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case Skin( t , v  ): 
					switch( i.id) {
						default:
						case TREE_POT:
							mt.gx.Debug.assert( t == SK_PLANT );
							if ( v >= Protocol.skinList.length )
								v = Protocol.skinList.length - 1;
						case RATION: 
							switch(t) {
								default:
								case SK_FRUIT: 
									if ( v >= Protocol.skinList.length )
										v = Protocol.skinList.length - 1;
							}
					}
					return { t:t, v:v };
				default:
			}
		
		return null;
	}
	
	public static function getBlueprint( i :ItemDesc ) : ItemId
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case BluePrint(bid):return bid;
				default:
			}
		
		return null;
	}
	
	
	public static function getDoorId( i :ItemDesc) : Int
	{
		for ( x in i.customInfos )
		{
			switch(x)
			{
				case Door( d ):
				return d;
				
				default:
				
			}
		}
		return null;
	}
	
	public static function getCommand( s:db.Ship,r:RoomId ) : ItemDesc
	{
		var rinf = s.getRoom( r );
		return rinf.inventory.find( function( i) return
			!i.status.has(BROKEN )
		&&	(i.id == PATROL_COMMAND || i.id == PASIPHAE_COMMAND ));
	}
	
	public static function getPlantCtrlInfos(  i :ItemDesc ) : {w:Int,t:Int }
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case PlantCtrlInfos( v  ): return v;
				default:
			}
		
		return null;
	}
	
	public static function getReservation(  i :ItemDesc ) : HeroId
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case Reserved( r  ): return r;
				default:
			}
		
		return null;
	}
	
	
	
	public static function cleanFood( i : ItemDesc ) : Void
	{
		if ( i.id == CONSUMABLE )
		{
			i.status.unset( FOOD_UNSTABLE );
			i.status.unset( FOOD_HAZARDOUS );
			i.status.unset( FOOD_DECAYING );
		}
	}
	
	public static function clearSkin( item : ItemDesc ) :Void
	{
		item.customInfos=item.customInfos.filter( function(ci)
		return switch(ci)
		{
			case Skin(_, _): false;
			default: true;
		} );
	}
	
	public static function clearCharges( item : ItemDesc ) :Void
	{
		item.customInfos=item.customInfos.filter( function(ci)
		return switch(ci)
		{
			case Charges(_, _): false;
			default: true;
		} );
	}
	
	public static function setSkin( item : ItemDesc ,t:SkinType, v : Int) : ItemDesc
	{
		var done = false;
		
		switch( item.id) {
			default:
			case TREE_POT:
				mt.gx.Debug.assert( t == SK_PLANT );
				mt.gx.Debug.assert( v < Protocol.skinList.length );
				
				if ( v >= Protocol.skinList.length )
					v = Protocol.skinList.length - 1;
				
			case CONSUMABLE,RATION: 
				switch(t) {
					default:
					case SK_FRUIT: 
						mt.gx.Debug.assert( v < Protocol.skinList.length );
						if ( v >= Protocol.skinList.length )
							v = Protocol.skinList.length - 1;
				}
		}
		
		item.customInfos=item.customInfos.map( function(ci){
			return switch(ci){
				case Skin(_,_): done = true; Skin( t, v );
				default: ci;
			}
		});
		
		if( !done ) item.customInfos.push( Skin( t,v ) ) ;
		
		return item;
	}
	
	public static function setAutonomy( item : ItemDesc, qty:  Int) : Void
	{
		var done = false;
		item.customInfos=item.customInfos.map( function(ci){
			return switch(ci){
				case Autonomy(_):  done = true; Autonomy( qty );
				default: ci;
			}
		});
		
		if( !done ) item.customInfos.push( Autonomy( qty ) ) ;
	}
	
	public static function pack( o:ItemDesc ) : db.ShipLog.ShipLogData
	{
		var p = getSkin(o);
		return ( p != null)
		? db.ShipLog.ShipLogData.ItemSkin( o.id, p.t,p.v)
		: db.ShipLog.ShipLogData.Item( o.id, null);
	}
	
	
	public static function isPackageable( i :ItemDesc ) : Bool
	{
		if ( i.id != CONSUMABLE ) return false;
		if ( i.status.has(FOOD_FROZEN ) ) return false;
		
		var sk = getSkin( i );
		if( sk == null ) return false;
		
		return
		switch(sk.t)
		{
			case SK_FRUIT:  true;
			case SK_RATION: ! (Protocol.rations[sk.v].effect.has( PACKAGED ));
			default: false;
		}
	}
	
	public static function isRation( i :ItemDesc ) : Bool
	{
		if ( i.id != CONSUMABLE ) return false;
		
		var sk = getSkin( i );
		if( sk == null ) return false;
		
		return sk.t == SK_RATION && sk.v == Const.RATION;
	}
	
	public static function isDrug( i :ItemDesc ) : Bool
	{
		if ( i.id != CONSUMABLE ) return false;
		
		var sk = getSkin( i );
		if( sk == null ) return false;
		
		return sk.t == SK_DRUG;
	}
	
	public static inline function isWorking( i :ItemDesc ) : Bool{
		return !i.status.has( BROKEN );
	}
	
	
	
	public static function iterable<E>( i : Void->Iterator<E>) : Iterable<E>
	{
		return {iterator: i };
	}
	
	public static function getBodyParam( i : ItemDesc ) : { hid: HeroId, isMush:Bool}
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				default:
				case BodyOf( h , i): return {hid:h,isMush:i};
			}
		return null;
	}
	
	public static function removeBody( i:ItemDesc, hid )
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				default:
				case BodyOf( h , _):
					if ( h == hid )
					{
						i.customInfos.remove(x);
						return;
					}
			}
	}
	
	public static function getChargeParam( i : ItemDesc ) : Int
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case Charges( l,m ): return l;
				default:
			}
		return null;
	}
	
	public static function getChargeParamM( i : ItemDesc ) : Int
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case Charges( _,m ): return m;
				default:
			}
		return null;
	}
	
	public static function getCustomInfos( i : ItemDesc, c : ItemInfos)
	{
		var ct = Type.enumConstructor(c);
		return i.customInfos.find( function(cs) return Type.enumConstructor(cs) == ct );
	}
	
	public static function removeCustomInfos( i : ItemDesc, c : ItemInfos)
	{
		var ct = Type.enumConstructor(c);
		i.customInfos = i.customInfos.filter( function(cs) return Type.enumConstructor(cs) != ct );
	}
	
	
	public static function removeCharges( i : ItemDesc)
	{
		i.customInfos = i.customInfos.filter( function(cs) 
		return switch(cs)
		{
			case Charges(_, _): false;
			default: true;
		});
	}
	
	
	public static function reserver(i : ItemDesc)
	{
		return i.customInfos.locate( function(cs)
		return switch(cs)
		{
			case Reserved(h): return h;
			default: return null;
		});
	}
	
	
	public static function cancelReserve(i : ItemDesc)
	{
		return i.customInfos.filter( function(cs)
		return switch(cs)
		{
			case Reserved(_): return false;
			default: return true;
		});
	}
	
	public static function getDroneInfos( i : ItemDesc ) : DroneInfos
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case Drone( t ): return t;
				default:
			}
		return null;
	}
	
	
	
	public static function getBpParam( i : ItemDesc ) : ItemId
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case BluePrint( bp ): return bp;
				default:
			}
		return null;
	}
	
	
	public static function setChargeParam( i : ItemDesc,l,m ) : Void
	{
		var ok = false;
		i.customInfos  = i.customInfos.map(
			function(x)
			{
				switch(x)
				{
					case Charges( il, im ):
						{
							ok = true;
							return Charges( MathEx.clampi( l,0,m),m);
						}
					default: return x;
				}
			}
		);
		
		if (!ok)
			i.customInfos.push( Charges(l, m ) );
	}
	
	public static function topChargeParam( i : ItemDesc ) : Void
	{
		i.customInfos  = i.customInfos.map(
			function(x)
			{
				switch(x)
				{
					case Charges( il, im ):
						{
							return Charges(im,im);
						}
					default: return x;
				}
			}
		);
		
	}
	
	public static function incrChargeParam( i : ItemDesc ) : Void
	{
		
		i.customInfos  = i.customInfos.map(
			function(x)
			{
				switch(x)
				{
					case Charges( l, m ):
						{
							return Charges( MathEx.clampi( l+1,0,m),m);
						}
					default: return x;
				}
			}
		);
	}
	
	public static function decrChargeParam( i : ItemDesc ) : Void
	{
		i.customInfos  = i.customInfos.map(
			function(x)
			{
				switch(x)
				{
					case Charges( l, m ):
							if ( l <= 0 )
								throw "item is out of charges ! " + i;
							return Charges( MathEx.clampi( l-1,0,m),m);
					default: return x;
				}
			}
		);
	}
	
	public static function testProjectPower( i : ItemDesc, pr : ProjectId )
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case ProjectPower( pr ): return true;
				default:
			}
		return false;
	}
	
	public static function getBookParam( i : ItemDesc ) : BookId
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case Book( b ): return b;
				default:
			}
		return null;
	}
	
	public static function getSkillParam( i : ItemDesc ) : SkillId
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case Skilled( b ): return b;
				default:
			}
		return null;
	}
	
	public static function isSpored( i : ItemDesc ) : Bool
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case Spored( _ ): return true;
				default:
			}
		return false;
	}
	
	
	
	public static function getMessage( i : ItemDesc ) : String
	{
		for ( x in i.customInfos  )
			switch(x)
			{
				case Message( t ): return t;
				default:
			}
		return null;
	}
	
	public static function getHidderParam( i :ItemDesc ) : HeroId
	{
		for ( x in i.customInfos  )
		{
			switch(x)
			{
				case Hidder( d ): return d;
				default:
			}
		}
		
		return null;
	}
	
	public static inline function getData(  r : RoomInfos ) : RoomData 				return Protocol.roomDb( r.id );
	public static inline function getTypeData(  r : RoomInfos ) : RoomTypeData		return Protocol.roomTypeDb( getData(r).type );
	
	public static inline function getItemDesc( a : ActionTarget ) : ItemDesc
	{
		return
		switch(a )
		{
			case TgtItem( id ): return id.it;
			default : throw "Invalid type for action param, item expected"; null;
		}
	}
	
	public static inline function getItemId( a : ActionTarget ) : ItemId
	{
		return switch(a )
		{
			case TgtItemId( id ): id;
			default : throw "Invalid type for action param, item expected"; null;
		}
	}
	
	public static inline function getProject( a : ActionTarget ) : ProjectId
	{
		return switch(a )
		{
			case TgtProject( id ):  id;
			default : throw "Invalid type for action param, item expected"; null;
		}
	}
	
	public static function getHeroId( a : ActionTarget ) : HeroId
	{
		switch(a )
		{
			case TgtHero( id ): return id;
			default :
		}
		
		return null;
	}
	
	public static function getPnjPublicId( a : ActionTarget ) : Int
	{
		switch(a )
		{
			case TgtPnj( id ): return id;
			default :
		}
		
		return null;
	}
	
	public static inline function isPasiphaeCrap ( it : ItemDesc )
	{
		return !it.status.has(EQUIPMENT);
	}
	
	public static function getRoomId( a : ActionTarget ) : RoomId
	{
		switch(a )
		{
			case TgtRoom( id ): return id;
			default :
		}
		throw "Invalid type for action param, room expected";
	}
	
	public static function getPlanetSeed( a : ActionTarget ) : Int
	{
		switch(a )
		{
			case TgtPlanet( id ): return id;
			default :
		}
		throw "Invalid type for action param, planet expected";
	}
	
	
	public static function cookables(d : Iterable<ItemDesc> ) : List<ItemDesc>
	{
		return d.filter( isCookable );
	}
	
	//are item equivalents for stacking pairing
	public static function itemEq( i0 : Protocol.ItemDesc, i1 : Protocol.ItemDesc, pairing=true,hero:db.Hero=null ) : Bool
	{
		if ( i0 == null && i1 != null) return false;
		if ( i0 != null && i1 == null) return false;
		
		switch(i0.id)
		{
			case TREE_POT: if ( i0.uid != i1.uid ) return false;
			default:
		}
		
		var prelem = i0.id == i1.id
		&&	i0.status.toInt() == i1.status.toInt();
		
		if(!prelem) return false;
		
		if ( i0.customInfos == null && i1.customInfos == null)  return true;
		
		var countProc = function( cs)
		{
			return
			switch(cs)
			{
				case DelayedEffect(_,_),Spored(_):
					if( hero!=null&&hero.isMush() )
						true;
					else
						false;
						
				default: true;
			}
		}
		
		var l0 = i0.customInfos.count( countProc );
		var l1 = i1.customInfos.count( countProc );
		
		if ( l0 != l1 )  return false;
		
		if ( !pairing )
		{
			if ( i0.uid != i1.uid )
				return false;
		}
		
		for(x in i0.customInfos)
		{
			switch(x)
			{
				default:
				case Spored( _ ):
					if (hero!=null&&!hero.isMush())
						continue;
						
				case DelayedEffect( _,_ ):
					if (hero!=null&&!hero.isMush())
						continue;
			}
			
			var found = false;
			for(y in i1.customInfos){
				switch(y) {
					
					case DelayedEffect( fx, d ):
						//let delayed effects merges;
						switch(x)
						{
							case DelayedEffect(ffx,dd):
								if ( ffx == fx && d == dd ) found = true;
							default:
						}
					
					case PNJVal( v ):
						switch(x)
						{
							case PNJVal(vv):
								if ( v == vv ) found = true;
							default:
						}
						
					case Song(s):
						switch(x)
						{
							default:
							case Song(ss): if ( s == s ) found = true;
						}
						
						
					case Spored(h):
						switch(x)
						{
							case Spored(hh):
								if ( h == hh ) found = true;
							default:
						}
						
					case Hacked(s):
					{
						switch(x)
						{
							case Hacked( ss ):  if ( s == ss ) found = true;
							default:
						}
					}
					
					case _Key(s):
					{
						switch(x)
						{
							case _Key( ss ):  if ( s == ss ) found = true;
							default:
						}
					}
					
					case RoomLink(r):
						switch(x)
						{
							case RoomLink( rr ):  if ( r == rr ) found = true;
							default:
						}
						
					case BluePrint( n ):
						switch(x)
						{
							case BluePrint( nn ):  if ( n == nn ) found = true;
							default:
						}
						
					case Drone( t ):
						switch(x)
						{
							case Drone( tt ):  if ( TypeEx.isPhysEq( t, tt ) ) found = true;
							default:
						}
					case Name( n ):
						switch(x)
						{
							case Name( nn ):  if ( n == nn ) found = true;
							default:
						}
						
					case Reserved( sid ):
						switch(x)
						{
							case Reserved( ssid ):  if ( sid == ssid ) found = true;
							default:
						}
						
					case ProjectPower( k ):
						switch(x)
						{
							case ProjectPower( kk ):  if ( k == kk ) found = true;
							default:
						}
						
					case Skilled( sk0 ):
						switch(x)
							{
								case Skilled( sk1 ): if( sk0 == sk1) found = true;
								default:
							}
					case Signaled( s1 ):
						switch(x)
							{
								case Signaled(s2): if( s1==s2) found = true;
								default:
							}
					case Charges( l,m ):
							switch(x)
							{
								case Charges(l1,m1): if( l == l1 && m == m1) found = true;
								default:
							}
					case Hidder( b  ):
						switch(x)
						{
							case Hidder(p): if( p == b ) found = true;
							default:
						}
						
					case Door( b  ):
						switch(x)
						{
							case Door(p): if( p == b ) found = true;
							default:
						}
					
					case PlantCtrlInfos( v ):
						switch(x)
						{
							case PlantCtrlInfos(p): if( p.w == v.w && p.t == v.t ) found = true;
							default:
						}
					case Skin( b , id1 ):
						switch(x)
						{
							case Skin(p, id2 ): if( p == b && id1 == id2 ) found = true;
							default:
						}
						
					case Autonomy( b  ):
						switch(x)
						{
							case Autonomy(p): if( p == b ) found = true;
							default:
						}
					
					case BodyOf( b,m  ):
						switch(x)
						{
							case BodyOf(p,mm): if( p == b && mm==m) found = true;
							default:
						}
					case Message( b  ):
						switch(x)
						{
							case Message(p): if( p == b ) found = true;
							default:
						}
					
					case Book( b  ):
						switch(x)
						{
							case Book(p): if( p == b ) found = true;
							default:
						}
				}
			}
			if(!found)
			{
				return false;
			}
		}
		return true;
	}
	
	public static function genOdsItem( s:Ship,od : OdsItem, fake = false ) : ItemDesc
	{
		var ship = s;
		return
		switch(od)
		{
			case OI_Item(i): 			Utils.itemDesc( ship, i , fake);
			case OI_Ration( cid ): 		Utils.itemDesc( ship, CONSUMABLE , fake).setSkin( SK_RATION , cid.index() );
			case OI_Fruit( id ): 		Utils.itemDesc( ship, CONSUMABLE , fake).setSkin( SK_FRUIT , id );
			
			case OI_MageBook( s ):
				var bk = Utils.itemDesc( ship, BOOK , fake);
				bk.customInfos.push(  Skilled(s) );
				bk.customInfos.push(  Book(LEARN_BOOK) );
				bk;
				
			case OI_RandomMageBook:
				var skillIdx = RandomEx.normalizedRandom( s.data.skillTab );
				var data = s.data.skillTab[skillIdx];
				s.data.skillTab.splice( skillIdx, 1);
		
				var bk = Utils.itemDesc( ship, BOOK , fake);
				bk.customInfos.push(  Skilled(data.id) );
				bk.customInfos.push(  Book(LEARN_BOOK) );
			
				bk;
			case OI_RandomBluePrint:
			
				var it = Utils.itemDesc( ship, BLUEPRINT , fake);
				
				var a = [];
				var i = 0;
				
				for ( bp in Protocol.bluePrints)
				{
					if ( !s.data.bpEmitted.get( bp.object_id ) )
						a.pushBack(bp);
					i++;
				}
				
				var index = RandomEx.normalizedRandom( a );
				
				if ( index == null)
					throw "no more blueprints available";
					
				it.customInfos.push( BluePrint( a[index].object_id ) );
				s.data.bpEmitted.set( a[index].object_id );
				it;
			
			case OI_BluePrint( i ):
				var it = Utils.itemDesc( ship, BLUEPRINT , fake);
				it.customInfos.push( BluePrint(i) );
				it;
				
			case OI_RandomDrugs:
				Utils.itemDesc( ship, CONSUMABLE , fake).setSkin( SK_DRUG , Std.random( s.data.drugs.length ) );
				
			case OI_Plant(i):
				Utils.itemDesc( ship, TREE_POT , fake).setSkin( SK_PLANT , i );
				
			case OI_RandomWeapon:
				var weapons = Protocol.itemList.filter(function(f) return f.starting_status.has(FIRE_WEAPON));
				weapons.pushBack( Protocol.itemDb(KNIFE) );
				var r = weapons.map(function(w) 
					return {id:w.id,weight:Protocol.toolDb( w.id).weight}
				);
				
				return Utils.itemDesc( ship, RandomEx.normRdEnum(r) , fake);
		}
	}
	
	public static function matches( it :ItemDesc , od : OdsItem ) : Bool
	{
		return
		switch(od)
		{
			case OI_Item(i): 			( it.id == i );
			case OI_Ration( cid ):
				if (it.id != CONSUMABLE)
					false;
				else
				{
					var sk = it.getSkin();
					sk.t == SK_RATION && sk.v == cid.index();
				}
				
			case OI_Plant( i ):
				var sk = it.getSkin();
				sk.t == SK_PLANT && sk.v == i;
				
			case OI_Fruit( i ):
				var sk = it.getSkin();
				sk.t == SK_FRUIT && sk.v == i;

			case OI_RandomBluePrint:throw "not meant for matching";
			case OI_RandomMageBook:	throw "not meant for matching";
			case OI_RandomDrugs:	throw "not meant for matching";
			case OI_MageBook(b):	throw "not meant for matching";
			case OI_RandomWeapon: 	throw "not meant for matching";
			
			case OI_BluePrint( i ):
				if ( it.id != BLUEPRINT)
					false;
				else
				{
					var bp = it.getBlueprint();
					bp == i;
				}
		}
	}
	
	public static function getRoomLink( tgtItem:ItemDesc) : RoomId
	{
		return tgtItem.customInfos.locate( function(ci) switch(ci) { default:return null; case RoomLink(r):return r; } );
	}
	
	
	public static function isEmptyPot(tgtItem:ItemDesc):Bool
	{
		return tgtItem.id==TREE_POT && tgtItem.customInfos.test( function(ci) switch(ci) { default:return false; case Skin(_,_): return true; } );
	}

	public static function pnjOf( s:Ship,t : ItemDesc )
	{
		var pnjVal = t.customInfos.locate( function(cs)
		switch(cs)
		{
			case PNJVal( p ): return p;
			default : return null;
		});
		
		return db.PNJ.manager.select( $ship == s && $publicId == pnjVal, true );
	}
	
}

