 import haxe.EnumFlags;

#if neko
import db.Hero;
import neko.Random;
import db.Ship;
import db.ShipLog;
import Protocol;
import handler.Handler.HandlerAction;
import Types;
import haxe.crypto.Md5;
#end

#if flash
import Protocol;
#end

using Ex;


class Utils
{

	#if neko
	public static function error( url, msg ) {
		return HandlerAction.ActError(url, msg);
	}
	#end
	
	public static inline function Bit_set( _v : Int , _i : Int) : Int
	{
		return _v | _i;
	}
	
	public static inline function Bit_is( _v : Int , _i : Int)
	{
		return  (_v & _i) == _i;
	}
	
	public static inline function Bit_clear( _v : Int, _i : Int)
	{
		return _v & ~_i;
	}
	
	public static inline function Bit_neg(  _i : Int)
	{
		return ~_i;
	}
	
	
	//end is inclusive
	public static inline function Bit_write(  input : Int, value : Int , startIndex :  Int, len : Int ) : Int
	{
		var svIn =  input;
		
		var premask = (1 << len) - 1;
		var mask = premask << startIndex;
		
		svIn = svIn & ~mask;
		svIn = svIn | ( (value&premask) << startIndex);
		
		return svIn;
	}
	
	public static inline function Bit_read(  input : Int, startIndex :  Int, len : Int ) : Int
	{
		var premask = (1 << len) - 1;
		
		return (input >> startIndex) & premask;
	}
	
	public static inline function Bit_toggle( _v : Int , _onoff : Bool, _i : Int) : Int
	{
		return 	_onoff
				? Bit_set(_v,  _i)
				: Bit_clear(_v, _i);
	}
	
	
	
	#if neko
	public static function itemDesc( s:Ship, i : ItemId ,fake = false ) : ItemDesc
	{
		if ( !fake) {
			if ( !s.isLocked() && !s.flags.has( INSERTING) )
				s.lock();
		}
		
		var it = {
					uid: s.guidGen++,
					id : i,
					status: Utils.bitListToFlags(Protocol.itemList[Type.enumIndex(i)].starting_status),
					customInfos:ListEx.empty() };
					
		switch(i)
		{
			default:
				
			case ANTIGRAV_SCOOTER:
				it.customInfos.push( Charges(1,8) );
		
			case TURRET_COMMAND:
				var data = Protocol.shipStatsDb( TURRET );
				it.customInfos.push( Charges( data.charge, data.charge ) );
				
			case PATROL_COMMAND:
				var b = Protocol.shipStatsDb(PATROLSHIP).charge;
				it.customInfos.push( Charges(b, b) );
				
				
			//default to inter stellar ration
			case CONSUMABLE:
			ItemUtils.setSkin( it, SK_RATION, Const.RATION );
			
			case BANANA_TREE:
			it.id = TREE_POT;
			ItemUtils.setSkin( it,  SK_PLANT, Const.BANANA );
			
			case RATION:
			it.id = CONSUMABLE;
			ItemUtils.setSkin( it,  SK_RATION, Const.RATION );
			
			case COOKED_RATION:
			it.id = CONSUMABLE;
			ItemUtils.setSkin( it, SK_RATION, Const.COOKED_RATION );
			
			case ANABOLYSANT:
			it.id = CONSUMABLE;
			ItemUtils.setSkin( it, SK_RATION, Const.ANABOLYSANT );
			
			case HELP_DRONE:
			
			var seed = Std.random(1024*1024) + Std.random(1024*1024) + Std.random(1024*1024);
			var v = new neko.Random();
			v.setSeed( seed );
			
			var l = ListEx.from( DPU_REPAIR_EQUIPMENT );
			var df : DroneInfos = { 
				seed : seed, 
				pawa : l, 
				touch:null,
				name:"Robo " + Text.dflt_drone_names.split(",").random( v ) + " #" + v.int(100),
				predict:null
			};
			
			it.customInfos.push( Drone(df) );
			
			case LUNCHBOX: 			it.customInfos.push( Charges(3, 3) );
			case PILL_BOX: 			it.customInfos.push( Charges(4, 4) );
			case COFFEE_THERMOS : 	it.customInfos.push( Charges(4, 4) );
			case MICROWAVE :		it.customInfos.push( Charges(2, 4) );
		}
		
		var status = Protocol.itemDb( it.id ).starting_status;
		
		if ( status.has( AUTO_KEY ))
			it.customInfos.push( _Key(Std.string( it.uid) ) );
		
		var tls = Protocol.toolDb( it.id );
		if ( tls != null && tls.charge > 0)
			it.customInfos.pushBack( Charges( tls.charge, tls.charge ) );
			
		if ( !fake && !s.flags.has( INSERTING)) {
			s.dirty = true;
		}
		
		return it;
	}
	#elseif flash
	public static function itemDesc( i : ItemId ) : _ItemDesc
	{
		return {
					uid:0,
					id : i,
					status: Utils.bitListToFlags(Protocol.itemList[Type.enumIndex(i)].starting_status).toInt(),
					customInfos:ListEx.empty() };
	}
	#end
	
	#if neko
	public static function rdFruit( alien:  Bool, s:Ship ,?r:neko.Random ) : ItemDesc
	{
		var fr  = 1 + r.int( Protocol.skinList.length - 1 );
		if (fr >= Protocol.skinList.length)
			fr = Protocol.skinList.length - 1;
			
		var it = ItemUtils.setSkin( itemDesc( s, CONSUMABLE ), SK_FRUIT, fr );
		return it;
	}
	#end
	
	@:allowConstraint
	public static function bitListToFlags<A:EnumValue>( a : Iterable<A> ) : EnumFlags<A>
	{
		var res : EnumFlags<A> = EnumFlags.ofInt(0);
		for ( x in a )
			res.set( x );
		return res;
	}
	
	#if (flash && iso)
	public static function getDoorTgt( i : _ItemDesc ,rid : RoomId ) : RoomId
	{
		Debug.ASSERT( data.Level.map != null ,"no map");
		Debug.ASSERT( i != null ,"no item");
		
		var map = data.Level.map;
		Debug.ASSERT( map != null, "no such room");
		
		for ( x in i.customInfos  )
		{
			switch(x)
			{
				case Door( d ):
				var dr = map.doors[d];
				
				if ( dr == null ) return null;
				
				Debug.ASSERT( dr != null , "no such door " + d);
				
				return
				(  dr.link[0].id == rid )
				? return  dr.link[1].id
				: return  dr.link[0].id;
				
				default:
			}
		}
		
		return null;
	}
	#end
	
	
	#if neko
	
	public static function formatCycle( c : Int )
	{
		return Text.chatDate( { day:Std.int(c / Const.CYCLE_PER_DAY) + 1, cycle:Std.int(c % Const.CYCLE_PER_DAY)+ 1 } );
	}
	
	public static function formatCycle2( c : Int )
	{
		return Text.mushDate( { day:Std.int(c / Const.CYCLE_PER_DAY) + 1, cycle:Std.int(c % Const.CYCLE_PER_DAY)+ 1 } );
	}
	
	public static function now( c : Int )
	{
		return{ day:Std.int(c / Const.CYCLE_PER_DAY) + 1, cycle:Std.int(c % Const.CYCLE_PER_DAY)+1 };
	}

	public static function sortInv( arr : Array<ItemDesc> )
	{
		arr.sort(
		function(x:ItemDesc,y:ItemDesc)
		{
			return Type.enumIndex(x.id) - Type.enumIndex(y.id);
		});
	}
	
	
	@:allowConstraint
	public static function flagsToEnumList<A:EnumValue>( e : Enum<A>, a : EnumFlags<A> ) :  List<A>
	{
		var res = new List<A>();
		for ( i in 0...EnumEx.length(e) )
		{
			var enumElem = Type.createEnumIndex( e , i );
			if( a.has( enumElem ))
				res.push( enumElem );
		}
		return res;
	}
	
	public static inline function randList<A>( arr : List<A> ) : A
	{
		return LambdaEx.nth(arr, Std.random(arr.length) );
	}
	
	public static inline function randArrayNeko<A>( arr : Array<A> , rd : Random) : A
	{
		return arr[ rd.int(arr.length) ];
	}
	
	#end
	
	public static function compareTo( s1 : String , s2 : String ): Bool
	{
		var ls1 = s1.toLowerCase();
		var ls2 = s2.toLowerCase();
		
		for( i in 0...Std.int(Math.min( s1.length,s2.length ) ))
		{
			if ( ls1.charCodeAt(i) == ls2.charCodeAt(i) ) continue;
			
			if( ls1.charCodeAt(i) < ls2.charCodeAt(i) )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		return s1.length < s2.length;
	}
	
	
	
	#if neko
	
	public static function canCrunchItem( h : db.Hero , i : ItemId)
	{
		for ( item in h.loc().inventory  )
			if( (item.id == i) && !item.status.has( BROKEN ) )
				return true;
		
		for ( item in h.inventory  )
			if( (item.id == i) && !item.status.has( BROKEN ) )
				return true;

		return false;
	}
	
	public static function crunchRoomItem( r:RoomInfos , i : ItemId) : Void
	{
		for ( item in r.inventory  )
			if( (item.id == i) && !item.status.has( BROKEN ) )
			{
				r.inventory.remove( item );
				return;
			}
		HandlerEx.dbgError("/", "error : invalid crunch");
	}
	
	
	public static function crunchItem( h : db.Hero , i : ItemId) : Void
	{
		for ( item in h.loc().inventory  )
			if( (item.id == i) && !item.status.has( BROKEN ) )
			{
				h.loc().inventory.remove( item );
				h.ship.update();
				return;
			}
		
		for ( item in h.inventory  )
			if( (item.id == i) && !item.status.has( BROKEN ) )
			{
				h.inventory.remove( item );
				h.update();
				return;
			}

		HandlerEx.dbgError("/", "error : invalid crunch");
	}
	
	
	public static inline function isRoomDamaged( r ) : Bool
	{
		return r.damage >= 100;
	}
	
	
	
	
	public static function escapeJS(str)
	{
		return str
		.split("\\").join("\\\\")
		.split("'").join("\\'")
		.split("\r").join("\\r")
		.split("\n").join("\\n")
		.split('\"').join("\\'")
		;
	}

	public static inline function buildFirstName(id:HeroId) : String
	{
		return Protocol.heroesDb(id).surname;
	}
	
	public static function repairObject( hero : Hero, item : ItemDesc, ?itemRoom:RoomId )
	{
		var ship : db.Ship = hero.ship;
		
		item.status.unset( BROKEN );
		item.status.unset( BROKEN_SIGNALED );
		item.customInfos = item.customInfos.filter( function(cs) return switch(cs) { case Signaled(_): false; default:true; } );
					
		var pd = null;
		
		switch(item.id)
		{
			default:
			case DOOR:
				pd = ShipLogic.getDualDoor(ship, hero.location, item);
				
				if(pd != null)
				{
					pd.first.item.status.unset( BROKEN );
					pd.second.item.status.unset( BROKEN );
				}
				
				hero.goal( com.Goal.id.door_repaired );
				
			case PRINTER:
			
				for ( i in ship.data.printerQueue)
					hero.locInv().push( i );
					
				ship.data.printerQueue.clear();
				ShipLog.createHeroLog( PRINTER_PRINTING, hero ).insert();
				
			case PATROL_INTERFACE:
			{
				var pi = ActionLogic.getPatrol(ship, item);
				mt.gx.Debug.assert( pi != null, 'no patrol for patrol interface');
				
				var com = pi.getRoom().inventory.find( function( i ) return i.id == PATROL_COMMAND || i.id == PASIPHAE_COMMAND );
				
				if( com.status.has(BROKEN))
					repairObject(hero, com );
			}
			
			case PATROL_COMMAND,PASIPHAE_COMMAND:
			{
				var pi = ActionLogic.getPatrolInterface(ship, (itemRoom!=null)?itemRoom:hero.location);
				mt.gx.Debug.assert( pi != null, 'no interface for patrol');
				
				if ( pi.item.status.has(BROKEN) )
					repairObject(hero, pi.item );
			}
		}
		
		ShipLog.createHeroLog( OBJECT_REPAIRED, hero, Item( item.id, null ) ).insert();
		mt.gx.Debug.assert( ship.isLocked());
		ship.dirty = true;
	}
	
	public static function repairObjectSys( loc:RoomInfos, ship:Ship, item : ItemDesc )
	{
		item.status.unset( BROKEN );
		item.status.unset( BROKEN_SIGNALED );
		item.customInfos = item.customInfos.filter( function(cs) return switch(cs) { case Signaled(_): false; default:true; } );
					
		var pd = null;
		switch(item.id)
		{
			default:
			case DOOR:
				pd = ShipLogic.getDualDoor(ship,loc.id, item);
				
				if(pd != null)
				{
					pd.first.item.status.unset( BROKEN );
					pd.second.item.status.unset( BROKEN );
				}
				
			case PRINTER:
			
				for ( i in ship.data.printerQueue)
					loc.inventory.push( i );
					
				ship.data.printerQueue.clear();
				
			case PATROL_INTERFACE:
			{
				var pi = ActionLogic.getPatrol(ship, item);
				//mt.gx.Debug.assert( pi != null, 'no patrol for patrol interface');
				if ( pi == null) return;
				
				var com = pi.getRoom().inventory.find( function( i ) return i.id == PATROL_COMMAND || i.id == PASIPHAE_COMMAND );
				
				if( com.status.has(BROKEN))
					repairObjectSys( loc, ship, com );
			}
			
			case PATROL_COMMAND,PASIPHAE_COMMAND:
			{
				var pi = ActionLogic.getPatrolInterface(ship, loc.id );
				//mt.gx.Debug.assert( pi != null, 'no interface for patrol');
				if ( pi == null) return;
				
				if ( pi.item.status.has(BROKEN) )
					repairObjectSys( loc, ship, pi.item );
			}
		}
	}
	
	#end
	
	
	public static function genCostTag( d : Array<Int> ):String
	{
		var t = "";
		for ( i in 0...d.length )
		{
			var k = d[i];
			if(k>0)
			{
				var src =
				switch(i)
				{
					case 0: "/img/icons/ui/pa_slot" + 1 + ".png";
					case 1: "/img/icons/ui/pa_slot" + 2 + ".png";
					case 2: "/img/icons/ui/pa_eng.png";
					case 3: "/img/icons/ui/pa_exp.png";
					case 4: "/img/icons/ui/pa_comp.png";
					case 5: "/img/icons/ui/pa_garden.png";
					case 6: "/img/icons/ui/pa_core.png";
					case 7: "/img/icons/ui/pa_shoot.png";
					case 8: "/img/icons/ui/pa_cook.png";
					case 9: "/img/icons/ui/pa_heal.png";
					case 10: "/img/icons/ui/pa_pilgred.png";
					default: "";
				};
				
				t += new Tag("span")
							.content(Std.string(k)+" ")
							.append(
								new Tag("img")
								.attr("class", "paslot")
								.attr("src", src ));
				t += " ";
			}
		}
		return t;
	}
	
	#if neko
	public static function  stanceData( s : PatrolStance)
	{
		var base=
						{
							hit: Protocol.actionDb( PATROL_SHIP_ATTACK ).proba,
							evade:50,
							attract : 15,
							lock: true,
						};
		if( s != null)
		{
			switch(s)
			{
				case Attack:  	base.hit *= 2;
				case Flee: 		base.lock = false;
				case Bait: 		base.evade = Std.int( base.evade * 1.5 ); base.attract *= 2;
			}
		}
		return base;
	}
	
	
	public static function getConsumableEffectDesc(e:ConsumableEffectType) : String
	{
		
		var a = "";
		var b = "";
		var c = "";
		switch(e) {
			case INC_LIFE(k), INC_MORAL(k), INC_ACTION(k), INC_MOVE(k), INC_NUTRITION(k) :
					a += ((k < 0)?"":"+") + k;
					
			case CURE(k) : a += Protocol.diseaseDb( k ).name;
			case SET_DISEASE_R(pc,id) :
				a += pc;
				b += Protocol.diseaseDb( id ).name;
			case SET_DISEASE(id, inc, ext) :
				a += Protocol.diseaseDb( id ).name;
				b += inc;
				c += inc+ext;
			case UNSTABLE( e, prc ) :
				a += prc;
				b += getConsumableEffectDesc(e);
				
			case IF_SEXE(g,e) :
				a += (g==Male) ? Text.male : Text.female;
				b += getConsumableEffectDesc(e);
				
			default :
		}
		
		var str = Protocol.consumables[Type.enumIndex(e)].desc;
		str = str.split("$a").join(a).split("$b").join(b).split("$c").join(c);
		
		var res  = TextEx.formatWithBoundsAndCbk(str, ":", Gen.USER_TXT.generate);
		return res;
	}
	
	
	
	public static function flattenConsFx( a : Array<ConsumableEffectType> ) : Array<ConsumableEffectType>
	{
		var  l = new List();
		
		//reinterpret some value to filter multiple loggings
		var dpa = 0;
		var dpm = 0;
		var dppm = 0;
		var dpv = 0;
		
		for ( x in a )
		{
			switch(x)
			{
				case INC_LIFE(v): 				dpv	+=v;
				case INC_ACTION(v): 			dpa	+=v;
				case INC_MOVE(v): 				dppm+=v;
				case INC_MORAL(v): 				dpm	+=v;
				
				case INC_NUTRITION(_): 			l.push( x );
				case CURE( _ ): 				l.push( x );
				case PACKAGED:					l.push( x );
				case SET_DISEASE( _, _, _):		l.push( x );
				case SET_DISEASE_R( _, _): 		l.push( x );
				case BLOCK_DOOR			:		l.push( x );
				case IF_SEXE( _, _)		: 		l.push( x );
				case UNSTABLE( _, _ )	: 		l.push( x );
				case COOKABLE:					l.push( x );
				case IMM_DISEASE( _ ): 			l.push( x );
			}
			
		}
		
		if(dpv>0) 			l.push( INC_LIFE(dpv) );
		if(dpm!=0) l.push( INC_MORAL(dpm) );
		if(dppm>0) 			l.push( INC_MOVE(dppm) );
		if(dpa>0) 			l.push( INC_ACTION(dpa) );
		
		return l.array();
	}
	
	public static function mkSig( hero:Hero,str : String )
	{
		return Md5.encode( str + "key" + "user" + hero.getOwner( false ).key + "ship" + hero.ship.id );
	}
	
	#end
	
	public static function toFlash( i : ItemDesc ) : _ItemDesc
	{
		if (i == null) return null;
		
		var ci = i.customInfos.filter(function(cs)
		{
			return switch(cs) {
				case _Key(_): true;
				case Door(_):true;
				case BodyOf(_, _):true;
				case RoomLink(_):true;
				default:false;
			}
		})
		.map(function(cs)
		{
			return switch(cs) { 
				default:cs;
				case BodyOf( b, _):BodyOf( b, null);
			};
		});
		
		return { uid: i.uid,id:i.id, status: i.status.toInt(), customInfos:ci};
	}
	
	
		
}
