package ;

import CrossConsts;
import actor.Drone;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import fx.EmitNotes;
import fx.FxElement;
import IsoProtocol;
import mt.gx.math.Vec2i;
//using mt.bumdum9.MBut;
import mt.bumdum9.Lib;

using Ex;
using As3Tools;

import Tile;
import mt.pix.Element;

import Data;
import Protocol;
import Types;
import Dirs;
/**
 * ...
 * @author de
 */

typedef RoomDesc =
{
	var data : Grid;
}


typedef FxEntry = { grid:Grid, bindPos:V2I,  fx: mt.fx.Fx };

typedef UnlockEntry =
	{
		uid:Int,
		
		debug:Bool,
		cond: CrossCondition,
		rid: List<RoomId>,//null means everywhere
		done : Bool,
		
		?iid:ItemId,//targeting
		?tile_target : String,
		
		//targeting
		?replace:String,
		?replace_mask : String,
		?prepend:String,
	};
	
class Ship
{
	var rooms : EnumHash<RoomId,RoomDesc>;
	public var curRoom(default,null) : RoomId;
	
	public var player : Player;
	public var people : EnumHash<HeroId,HumanNPC>;

	public var fxStore : List<FxEntry>;
	public var fxSmokeStore : List<FxEntry>;
	
	public var root : flash.display.MovieClip;
	public var battle : ui.SpaceBattle;
	public var selectables : List<Select>;
	public var drones : List<actor.Drone>;
	public var planet : ui.Planet;
	
	public function new()
	{
		rooms = new EnumHash(RoomId);
		curRoom = null;
		people = new EnumHash( HeroId );
		fxStore = new List();
		fxSmokeStore = new List();
		root = new MovieClip();
		Main.view.addChild( root );
		selectables = new List < Select >();
		drones = new List();
	}
	
	
	public function nearestFree(grid : Grid, forbidden : List<V2I>,cell:V2I)
	{
		var frees = grid.tiles().filter( function(t)
		{
			if( !t.isSpawnable()) return false;
			
			for(x in forbidden)
			{
				if ( t.getGridPos().x == x.x && t.getGridPos().y == x.y ) return false;
			}
			
			return true;
		}).array();
		
		frees.sort(
		function(t0,t1)
		{
			var gr0 = t0.getGridPos();
			var gr1 = t1.getGridPos();
			
			var score0 = gr0.x - cell.x + gr0.y - cell.y;
			var score1 = gr1.x - cell.x + gr1.y - cell.y;
			
			return Std.int( score1 - score0 );
		});
		return frees;
	}
	
	public function getNpcs( grid:  Grid, pos:V2I ) : List<HumanNPC>
	{
		return people.filter(
		function(npc) return npc.getGrid() == grid && npc.getGridPos().x == pos.x
		&& npc.getGridPos().y == pos.y);
	}
	
	public function clearPos( grid:  Grid, pos:V2I )
	{
		//get all in our grid
		var ours = people.filter( function(npc) return npc.getGrid() == grid );
		//get all on this pos
		var npcs = getNpcs( grid, pos );
		if (npcs.length == 0) return;
		
		//elim others pos
		var elim = ours.filter( function(npc) return !npcs.has(npc));
		var elimPosList = elim.map( function(npc) return npc.getGridPos() );
		elimPosList.push( pos );
		
		//get ordered free tiles
		var tiles = nearestFree( grid, elimPosList, pos );
		
		//reassign
		if ( tiles == null ) return;
		npcs.iter(function(npc)
		{
			var choose = tiles[RandomEx.randFilteredI( tiles.length, RandomEx.SqrtFilter)];
			npc.setPos( choose.getGridPos().x, choose.getGridPos().y);
		}
		);
	}
	
	public function kickBlocker(grid:Grid,
		origPos : V2I,
		toPos : V2I
	)
	{
		origPos = origPos.clone();
		
		for( p in people )
		{
			if ( p.getGrid() == grid)
			{
				var gp = p.getGridPos();
				if ( 	gp.x == toPos.x
				&&		gp.y == toPos.y )
				{
					if ( !grid.isPathable( toPos.x, toPos.y))
					{
						var n = grid.nearestFree( toPos.x, toPos.y);
						if(n!=null)
						{
							var p = n.getGridPos();
							origPos.x = p.x;
							origPos.y = p.y;
						}
					}
					p.setPos( origPos.x, origPos.y);
					p.randDir();
					return;
				}
			}
		}
	}
	
	public function setPlayer( data:ClientChar )
	{
		var grid : Grid = getRoom(data.room).data;
		var pl = new Player( grid, data );
		pl.init( grid, null );
		pl.setChar( data.id  );
		player = pl;
		
		var gr = grid.randomFree();
		
		if ( gr == null)
			gr = grid.tiles().first();
			
		if( gr != null)
			pl.setPos( gr.getGridPos().x, gr.getGridPos().y);
	}
	
	
	public function setPeopleRoom( data : ClientChar, isMain = false ) : HumanNPC
	{
		var heroId = data.id;
		var r = data.room;
		
		var mini = Main.gui.minimap;
		if( mini !=null)
			mini.setPeopleRoom( heroId, r, isMain);
			
		var ngr : Grid = getRoom(r).data;
		for( p in people )
			if ( p.getChar() == heroId)
			{
				var rid = p.getGrid().getRid();
				if ( rid != r )
				{
					p.changeRoom( p.getGrid(), ngr );
					var gr = ngr.randomFree();
					
					if ( gr != null)
					{
						var grp = gr.getGridPos();
						p.setPos( grp.x, grp.y);
						for (x in 0...[2, 3, 4, 5].random() )
							p.turn();
					}
					else p.setPos(0, 0);
						
				if(!isMain)
					Main.dirtMinimap();
				}
				p.refresh( data );
				return p ;
			}
		
		//went missing
		var np = new HumanNPC(ngr,data);
		np.init( ngr, null);
		np.setChar( data.id );
		
		var gr = ngr.randomFree();
		np.te.el.visible = false;
		if( gr != null )
		{
			var grp = gr.getGridPos();
			np.setPos( grp.x, grp.y);
			for (x in 0...[2, 3, 4, 5].random() )
				np.turn();
				
			var op = people.get ( data.id  );
			mt.gx.Debug.assert( op == null);
			people.set( data.id , np );
			np.te.el.visible = true;
			
			if(!isMain)
				Main.dirtMinimap();
		}
		else np.setPos(0, 0);
		#if debug
		//trace(data.id.index() + " was missing");
		#end
		return np;
	}
	
	
	public inline function current() : RoomDesc
		return rooms.get(curRoom);
	
	public function init()
	{
		
	}
	
	public function buildRoomBmp( r, bmp : BMD, bmpSlice : Array<Coll.Rect> ) : Grid
	{
		var grid : Grid = new Grid(r);
		root.addChild( grid);
		
		var dbgMe = false;
		
		var rd = { data : grid, };
		var set = function(te:TileEntry, i : String, f : Int = 0 )
		{
			var setup = Data.mkSetup( i, Data.slices.get(i).sheet, f );
			te.setup = setup;
			
			Data.setup( te.el, te.setup.sheet,te.setup.frame,te.setup.index);
		}
		
		var te : TileEntry =  null;
		var grd = function(x, y) 	return te=grid.tile( x, y ).get(Ground,true);
		var prop = function(x, y) 	return te=grid.tile( x, y ).get(Props, true);
		var wall = function(x, y) 	return te=grid.tile( x, y ).get(Wall,true);
		
		var nbWalls = 0;
		var nbGround = 0;
		var nbProp = 0;
		
		for( layer in 0...bmpSlice.length)
		{
			var slice = bmpSlice[layer];
			for( y in slice.y...slice.y+slice.height )
			{
				for( x in slice.x...slice.x+slice.width )
				{
					var baseX = x - slice.x;
					var baseY = y - slice.y;
					
					var pix = bmp.getPixel( x, y );
					if( pix == 0xFFFFFF) continue; //skip white
					
					var frameInfo = Data.col2Slice.get( pix );
					if( frameInfo == null)
					{
						//Debug.MSG("unknown color:" + StringTools.hex( pix ));
						continue;
					}
					
					var sliceInfo : PixSlice = Data.slices.get( frameInfo.index );
					var index = frameInfo.index;
					if( index == null )
					{
						//Debug.MSG("unknown color:" + StringTools.hex( pix ));
						continue;
					}
					
					
					var tile = grid.tile( baseX, baseY );
					var dl = sliceInfo.deps;
					
					var mkDoor = function()
					{
						var lx = baseX;
						var ly = baseY;
						var sl =  sliceInfo.deps;
						var posList = new Array();
						var first = true;
						for( j in 0...dl.y)
							for( i in 0...dl.x)
							{
								var vx = lx - i;
								var vy = ly - j;
								posList.push( new V2I( vx, vy));
								grid.tile( vx, vy ).set( Wall, te, first);
								first = false;
							}
						te.setup = frameInfo;
						
						//Debug.MSG("adding door "+r);
						grid.addDep( tile,  posList, te, null,null, {pixel:new V2I(x,y) });
					}
					
					var mkDep = function()
					{
						var sl =  sliceInfo.deps;
						if ( dl == null ) return false;
						var lx = baseX;
						var ly = baseY;
						var posList = new Array();
						for( j in 0...dl.y )
							for( i in 0...dl.x)
							{
								var vx = lx - i;
								var vy = ly - j;
								posList.push( new V2I( vx, vy));
							}
						
						var ent = new Entity( grid, PROPS);
						ent.init( grid, frameInfo);
						ent.setPos( lx, ly);
						
						var dep : DepInfos = grid.addDep( tile,  posList, ent.te, null, ent, { pixel:new V2I(x, y) } );
						dep.baseSetup = Reflect.copy(dep.te.setup);
						return true;
					}
					
					switch(layer)
					{
						case 0:
							if( Main.data.testTileFlag( _Pathable, index ) )
							{
								set( grd( baseX, baseY), index, frameInfo.frame  );
								nbGround++;
							}
							else
							{
								set( wall( baseX, baseY), index, frameInfo.frame );
								if ( dl != null)
									mkDoor();
								
								nbWalls++;
							}
						case 1:
							{
								if ( mkDep() == false)
									set( prop( baseX, baseY), index, frameInfo.frame  );
								nbProp++;
								//Debug.MSG("making prop : " + index);
							}
						
						default:
							Debug.ASSERT( dl != null, "this dep "+index+" has no infos col="+ StringTools.hex( pix) );
							mkDep();
					}
					
					te = null;
				}
			}
		}
		
		//if(nbWalls>0||nbGround>0)
		//	Debug.MSG("generated " + nbWalls + " walls &" + nbGround + " grounds");
		
		postProcessRoom( rd );
		rooms.set( r, rd);
		
		return grid;
	}
	
	public function getMoveInfos(from:RoomId, to : RoomId) : { enabled:Bool,txt:String}
	{
		var item = Main.serverDataGetDoorTo( from, to );
		var res = { enabled:true, txt:"" };
		
		if ( item == null )
		{
		//	Debug.MSG("cannot find door");
		}
		
		if ( item != null && Flags.test( item.status, BROKEN ))
		{
			res.enabled = false;
			res.txt = Protocol.txtDb("hs");
		//	Debug.MSG("door is broken");
		}
		else
		{
			//test actions for movability
			var srvAc = Main.serverDataGetActions();
			var found = false;
			
			if ( srvAc != null)
				for(ac in srvAc)
					if ( ac.dest == to.index() )
					{
						found = true;
						if ( ac.fake )
						{
							res.enabled = false;
							res.txt = ac.desc;
						}
					}
			
			if ( !found )
			{
			//	Debug.MSG("cannot find action");
			}
		}
		return res;
	}
	
	
	
	public function forceActiveRoom(rid)
	{
		curRoom = rid;
		Main.gui.roomName.text = Protocol.roomList[ rid.index() ].assert("windy force active room").name;
		
		onRoomActive(curRoom);
	}
	
	public function onRoomActive(rid)
	{
		for( d in getGrid( rid ).dependancies)
			if ( d.locker )
			{
				ServerProcess.hideCloset();
				break;
			}
	}
	
	public function setCurRoom(rid )
	{
		hideAll();
		showRoom( rid);
		forceActiveRoom( rid);
	}
	
	public function getRoom(rid : RoomId)
	{
		return rooms.get( rid );
	}
	
	public function getGrid(rid : RoomId)
	{
		var rt = rooms.get( rid );
		if (rt == null) return null;
		return rt.data;
	}
	
	public function showRoom( rid : RoomId )
	{
		var r = rooms.get( rid );
		if( r == null)
		{
			Debug.MSG("no such room " + rid);
			return;
		}
		
		r.data.visible=true;
		r.data.filters = [];
		
		if ( IsoConst.EDITOR )
		{
			var data = Protocol.roomDb( rid);
			
			if(	data.type  == LASER_TURRET
			||	data.type == PATROL_SHIP )
			{
				Main.view.onEndScroll(
					function()
					{
						battle = new ui.SpaceBattle(true,true);
						Main.guiStage().addChild(  battle );
						Main.gui.tip.spr.toFront();
						}
				);
			}
		}
	}
	
	
	public function hideRoom( rid : RoomId )
	{
		var r = rooms.get( rid );
		if( r == null) return;
		
		r.data.visible = false;
		if (battle != null)
		{
			battle.detach();
			battle = null;
		}
	}
	
	public function hideAll()
	{
		for( x in rooms )
			x.data.visible = false;
	}
	
	public function addModuleAccess( grid:Grid, baseTile : Tile, dep : DepInfos )
	{
		var gpos = baseTile.getGridPos();
		var slice  : PixSlice = Data.slices.get( dep.ent.te.setup.index );
		var dp  = Dirs.LIST[ E_DIRS.RIGHT.index()];
		
		//try another pad pos if defined in xml
		if (slice.modulePad != null)
			dep.pad = [ new V2I(gpos.x + slice.modulePad.x, gpos.y + slice.modulePad.y) ];
	}
	
	public function addDoorExit( grid:Grid, baseTile : Tile, dep : DepInfos)
	{
		var ents = [new Spr3D( grid, FX ), new Spr3D( grid, FX ) ];

		var index = null;
		var poses = grid.getDoorPad( dep );
		var dir = grid.getDoorDir(dep);
		switch(dir)
		{
			case UP: index = "DOOR_ARROW_TR";
			case LEFT: index = "DOOR_ARROW_TL";
			case DOWN:	index = "DOOR_ARROW_BL";
			case RIGHT:index = "DOOR_ARROW_BR";
		}
		
		Debug.ASSERT( index!=null, "there are special code to implements new doors, please contact your favorite programmer");
		
		var i = 0;
		for(ent in ents)
		{
			ent.engine = UseTile;
			ent.init( grid, Data.mkSetup( index ) );
			
			ent.prio = IsoConst.BG_PRIO - 1;
			ent.setPos3( poses[i].x, poses[i].y, 0 );
			
			i++;
		}
	}
	
	public function addFx(grid,grPos,f)
	{
		fxStore.add( { grid:grid, bindPos: grPos, fx:f } );
	}
	
	public function rmFx(grid,grPos)
	{
		var p = fxStore.filter( function(e) return e.bindPos.isEq( grPos ) );
		for( ps in p )
		{
			ps.fx.kill();
			fxStore.remove( ps );
		}
	}
			
	
	function addDoorHandlers( grid:Grid,dep : DepInfos )
	{
		var to = null;
		var from = null;
		
		var te = dep.te;
		var grPos = dep.tile.getGridPos();
		var tile = dep.tile;
		
		switch(dep.gameData)
		{
			case Door( a, b ):
				to = (a == grid.getRid()) ? b : a;
				from = (a == grid.getRid()) ? a : b;
				
			default: Debug.BREAK("unexpected no game data for dep of door " + te.str() );
		}
		
		if ( to == null || from == null)
		{
			Debug.BREAK("unexpected no game data for dep of door " + te.str()  );
			return;
		}
		
		var sel = selectables.pushBack( new Select(grid,dep) );
		sel.isDoor = true;
		
		grid.input.register( ON_ENTER, te.el, sel.Door_onEnter );
		grid.input.register( ON_RELEASE, te.el, sel.Door_onRelease );
		grid.input.register( ON_OUT, te.el, sel.Door_onOut );
	}
	
	public function checkUpgrades()
	{
		//Debug.MSG("checking upgrades...");
		checkUnlock();
		//Debug.MSG("done checking upgrades...");
	}
	
	public var unlocks : List <UnlockEntry> ;
	
	public var spawns : List <
	{
		uid : 	Int,
		iid :  	ItemId,
		tile:	String,
		cond:	CrossCondition,
		dir : 	E_DIRS,
		pos :	Array<Int>,
		rid: List<RoomId>,//null means everywhere
		debug:Bool,
		mask:String,
		
		done : Bool,
	}>;
	
	public var condVis : List <
	{
		uid:Int,
		rid: List<RoomId>,
		tile:String,
		key:String,
		cond:	CrossCondition,
		debug : Bool,
	}>;
	
	public function parseUnlocks()
	{
		unlocks = new List();
		
		var u = Main.data.getUpgades();
		var uid = 0;
		for ( ovr in u.nodes.unlock)
		{
			var v = {
				uid:uid++,
				iid: ovr.has.targetItem				? IsoProtocol.trackbackIid( ovr.att.targetItem ) : null,
				tile_target: ovr.has.targetTile 	? ovr.att.targetTile : null,
				replace:ovr.has.replace				? ovr.att.replace:null,
				replace_mask:ovr.has.replace_mask	? ovr.att.replace_mask:null,
				prepend:ovr.has.prepend				? ovr.att.prepend:null,
				cond:								Data.parseCond( ovr.att.cond ),
				debug:ovr.has.debug					? StdEx.parseBool( ovr.att.debug ): false,
				rid:ovr.att.room == "*"				? null :
					{
						ovr.att.room.split(",")
						.map( StringEx.trimWhiteSpace )
						.map( IsoProtocol.trackbackRid ).list();
					},
				done:false,
			}
			
			#if master
			v.debug = false;
			#end
			
			Debug.ASSERT( v.cond != null , "hey cond is null !");
			Debug.ASSERT( v.prepend != null || v.replace != null, "hey cond is null !");
			//Debug.MSG("read cond : " + v.cond );
			unlocks.pushBack(v);
		}
		
		spawns = new List();
		for ( spwn in u.nodes.spawnEquipment)
		{
			var v =
			{
				uid : 	uid++,
				iid :  	IsoProtocol.trackbackIid( spwn.att.target ),
				tile:	spwn.att.tile,
				cond:	Data.parseCond( spwn.att.cond ),
				dir : 	spwn.has.dir ? Dirs.parse( spwn.att.dir) : throw "no dir attribute on spawned equipment uid="+(uid-1),
				pos :	spwn.att.pos.split(",").map(Std.parseInt).array(),
				rid: spwn.att.room == "*"				? null :
					{
						spwn.att.room.split(",")
						.map( StringEx.trimWhiteSpace )
						.map( IsoProtocol.trackbackRid ).list();
					},
				debug:	spwn.has.debug						? StdEx.parseBool( spwn.att.debug ): false,
				mask:	spwn.has.mask ? spwn.att.mask:null,
				done:false,
			}
			
			#if master
			v.debug = false;
			#end
			
			Debug.ASSERT( v.cond != null , "hey cond is null !");
			Debug.ASSERT( v.rid != null, "no room id !");
			Debug.ASSERT( v.iid != null, "no item id !");
			#if debug 
			Debug.MSG("read spwn:" + v.uid);
			#end
		
			spawns.push( v );
		}
		
		condVis = new List();
		for ( cnd in u.nodes.condVis)
		{
			var cd =
			{
				uid:uid++,
				rid:cnd.att.room == "*"				? null :
					{
						cnd.att.room.split(",")
						.map( StringEx.trimWhiteSpace )
						.map( IsoProtocol.trackbackRid ).list();
					},
				tile:	cnd.att.tile,
				key: 	cnd.has.key?cnd.att.key:null,
				cond:	Data.parseCond( cnd.att.cond ),
				debug:	cnd.has.debug						? StdEx.parseBool( cnd.att.debug ): false,
			};
			
			#if master
			cd.debug = false;
			#end
			
			if ( cnd.att.room != "*" )
				Debug.ASSERT( cd.rid != null, "invalid room name" );
			
			//Debug.MSG("creating cdv of " + cd.tile+" dbg "+Std.string(cd.debug)+" tgts : "+Std.string( cd.rid) );
			Debug.ASSERT( cd.cond != null , "hey cond is null ! "+cnd.att.cond);
			condVis.push(cd);
		}
	}
	
	
	function checkSpawns()
	{
		//Debug.MSG("checking spawns");
		for ( s in spawns)
		{
			var l = igetRooms( s.rid );
			
			if ( s.done ) continue;
			
			if ( !s.debug && !testCond(s.cond) )
			{
				//Debug.MSG("cancelling "+s.iid);
				continue;
			}
			
			for( r in l ) applySpawn( s, r );
				
			s.done = true;
		}
	}
	
	function igetRooms( ridList ) : Iterable<Grid>
	{
		if ( ridList == null)
			return rooms.map( function(r) return r.data );
		else
			return ridList.map( function(rid ) return rooms.get( rid ).data );
	}
	
	public function checkUnlock()
	{
		//build unlocks
		if ( unlocks == null)
			parseUnlocks();
				
		checkSpawns();
		
		//Debug.MSG("checking condviz");
		for ( cd in condVis)
		{
			var l = igetRooms( cd.rid );
			for ( r in l ) applyCondVis( cd, r );
		}
					
		//Debug.MSG("checking unlocks");
		//find tile to update
		for( u in unlocks)
		{
			//test conds
			if ( !u.debug && !testCond(u.cond) ) continue;
			if ( u.done ) continue;
			
			var l = igetRooms( u.rid );
			for( r in l ) applyUpgrade( u, r );
				
			u.done = true;
		}
	
		//Debug.MSG("done check unlocks");
	}
	
	public function testCond(uc : CrossCondition, curRoom : RoomId = null )
	{
		var dataEx 		= Main.actServerDataExt;
		var dataBase	= Main.actServerData;
		
		#if debug
		switch(uc) {
			default:
			case CC_ResearchUnlocked( DRUG_DISPENSER):
				return true;
		}
		#end
		
		if (dataEx == null || dataBase == null)
		{
			//Debug.MSG("no server data");
			return false;
		}
		
		if (uc == null)
		{
			//Debug.MSG("no condition");
			return false;
		}
		
		switch(uc)
		{
			case CC_Or(c1, c2): return testCond( c1,curRoom ) || testCond( c2,curRoom );
			case CC_And(c1, c2): return testCond( c1, curRoom ) && testCond( c2, curRoom);
			case CC_Not( c ): return !testCond(c, curRoom);
			case CC_ProjectUnlocked( p ): return dataEx.projects.has( p );
			case CC_ResearchUnlocked( r ): return dataEx.researches.has( r );
			case CC_True : return true;
			case CC_False : return false;
			case CC_MushBody : return Flags.test( dataBase.flags, CrossFlags.MushBody);
			case CC_PilgredUnlocked : return Flags.test( dataBase.flags, CrossFlags.PilgredUnlocked);
			case CC_IcarusLanded: return Flags.test( dataBase.flags, CrossFlags.IcarusLanded);
			case CC_TestPatrol( k ) : return dataBase.showPatrol.test( function(p) return p._first == k && p._second);
			case CC_RoomItemHas( iid ):
				{
					if ( curRoom == null )
					{
						Debug.MSG("curRoom is null, this cond cannot be applied");
						return false;
					}
					return dataBase.shipMap.get( curRoom.index() ).inventory.test(
						function( it )
							return it.id == iid );
				}
				
		}
	}
	
	public function applySpawn( s, gr:Grid)
	{
		Debug.MSG("spawning " + Std.string(s.iid));
		var sliceInfo = Data.slices.get( s.tile );
		
		if ( sliceInfo == null)
		{
			Debug.MSG("ERROR:spawn has not referee" + s.tile);
			return;
		}
		
		var dl = sliceInfo.deps;
		Debug.ASSERT( dl != null, "slice " + s.tile + " has no deps !");
		var frameInfo = Data.frame( s.tile );
		var lx = s.pos[0];
		var ly = s.pos[1];
		
		var tile = gr.tile( lx, ly );
		var posList = new Array();
		for( j in 0...dl.y )
			for( i in 0...dl.x)
			{
				var vx = lx - i;
				var vy = ly - j;
				posList.push( new V2I( vx, vy));
			}
		
		var ent = new Entity( gr, PROPS);
		ent.init( gr, frameInfo);
		ent.setPos( lx, ly);
		
		var dep : DepInfos = gr.addDep( tile,  posList, ent.te, null, ent, { pixel:new V2I(lx, ly) } );
		dep.baseSetup = Reflect.copy(dep.te.setup);
		
		//link infos
		dep.mask = (s.mask!=null) ? Data.frame(s.mask) : null;
		dep.dir = s.dir;
		dep.iid = s.iid;
		
		var vecdir = Dirs.LIST[s.dir.index()];
		
		dep.pad = [ new V2I( lx - vecdir.x, ly - vecdir.y) ];
		
		gr.dependancies.pushBack(dep);
		
		Debug.ASSERT( dep.iid != null );
		
		decorateDeps( gr );
		cacheDependancies( gr );
		
		trace("done spawning " + Std.string(s.iid));
		
	}
	
	public function applyCondVis( cd , gr:Grid)
	{
		//Debug.MSG("evaluating "+gr.getRid()+" for cdv of " + cd.tile + " dbg " + Std.string(cd.debug) );
		
		if (cd.key != null)
		{
			var r = gr.getDepByKey( cd.key );
			if(r!=null)
				for ( deps in r )
					deps.ent.el.visible = cd.debug || testCond(cd.cond,gr.getRid());
		}
		else
		{
			var r = gr.getDepByTarget( cd.tile);
			if(r!=null)
				for ( deps in r )
					deps.ent.el.visible = cd.debug || testCond(cd.cond,gr.getRid());
		}
	}
	
	public function applyUpgrade( u : UnlockEntry, gr:Grid)
	{
		var target : List<DepInfos> = new List();
		if ( 	u.rid != null
		&&		!u.rid.has( gr.getRid() ) )
			return;
		
		if ( u.iid != null)
			target.append(gr.getDepByItem( u.iid ));

		if ( u.tile_target != null )
		{
			var gs = gr.getDepByTarget(u.tile_target);
			target.append(gs);
			#if !master
			if(gs.length == 0)
				Debug.MSG(u.tile_target+'doest not produce valid targets for' + Std.string(u));
			#end
		}
			
		var frameSelect = function( newSet : PixSetup,oldSet: PixSetup )
		{
			var newSl =  Data.slices.get( newSet.index );
			var oldSl =  Data.slices.get( oldSet.index );
			
			if (	oldSl.frames != null && newSl.frames != null
			&&		newSl.frames.length == oldSl.frames.length )
				newSet.index = oldSet.index;
				
			return newSet;
		}
		
		for ( t in target)
		{
			Data.setup2( t.ent.el, t.baseSetup );
			
			if ( u.replace != null)
			{
				var nSetup = Data.frame( u.replace );
				frameSelect( t.baseSetup, nSetup );
				t.ent.doSetup( nSetup);
			}
			
			if ( u.prepend != null)
			{
				var nte = Data.fromScratch( frameSelect( Data.frame(u.prepend), t.baseSetup) );
				t.ent.getDo().addChild( nte.el );
			}
			
			if ( u.replace_mask != null)
				t.mask = Data.frame( u.replace_mask );
			
			for (i in eq_ingame_activable)
			{
				if ( u.tile_target == i[0] && t.gameData == Blocker )
				{
					t.gameData = DepData.Equipment( i[1] );
					var sel = selectables.pushBack( new Select( gr, t ));
					var te = t.ent.te;
					gr.input.register( ON_ENTER, te.el, sel.Equipment_onEnter );
					gr.input.register( ON_RELEASE, te.el, sel.Equipment_onRelease );
					gr.input.register( ON_OUT, te.el, sel.Equipment_onOut );
					if ( i[2] )
						i[2](gr, t);
					Debug.MSG(i);
				}
			}
			
			t.ent.resetPos();
		}
	}
	
	public static function onBeatBox( gr:Grid,t :DepInfos){
		new EmitNotes(gr, t);
	}
	
	public static var eq_ingame_activable : Array<Array<Dynamic>>= [
	["auxiliary_terminal_neron", NERON_CORE,null],
	["dynarcade", DYNARCADE,null],
	["beat_box", BEAT_BOX, onBeatBox],
	["server",SUPER_CALC,null],
	];
	
	
	public static var disableDoorArrows = true;
	
	//done before decoration,
	public function linkEquipments(grid:Grid)
	{
		var extra = Main.data.getExtra();
		var rooms = extra.nodes.room;
		var rTxt = Protocol.roomIdList[ grid.getRid().index() ].id;
		var myRoomNode = rooms.find( function(r) return r.att.rid == rTxt );
		var doors = ListEx.n();
		var equipments = ListEx.n();
		if( myRoomNode != null)
		{
			equipments = myRoomNode.nodes.bindEquipment;
		}
		
		var count : Hash<Int> = new Hash();
		
		var keyHit  = new Hash();
		
		for( d in grid.dependancies)
		{
			//if there is already some data
			if ( d.gameData != null) continue;
			
			var frameInfo = d.te.setup;
			var sliceInfo : PixSlice = Data.slices.get( frameInfo.index );
			var tile = d.tile;
			var sliceInfo : PixSlice = Data.slices.get( frameInfo.index );
			
			if(  Main.data.testTileFlag(  _Equipment, sliceInfo.index ) )
			{
				var eq = null;
				
				var done = false;
				for ( e in extra.node.autoBind.nodes.eq )
				{
					if ( e.has.id && sliceInfo.index == e.att.tile )
					{
						d.iid = IsoProtocol.trackbackIid( e.att.id );
						d.dir = e.has.dir ? Dirs.parse(e.att.dir) : null;
						d.mask = e.has.mask ? Data.frame( e.att.mask ): null;
					}
				}
				
				if ( done ) continue;
				
				for ( e in equipments){
					if (e.has.tile)
						if ( e.att.tile == sliceInfo.index )
							if ( e.has.key )
							{
								if ( !keyHit.exists( e.att.key) )
								{
									eq = e;
									keyHit.set( e.att.key,true );
									break;
								}
							}
							else
							{
								eq = e;
								break;
							}
				}
				
				if ( eq != null)
				{
					d.iid = IsoProtocol.trackbackIid( eq.att.id );
					
					
					
					d.dir = eq.has.dir ? Dirs.parse(eq.att.dir) : null;
					d.mask = eq.has.mask ? Data.frame( eq.att.mask ): null;
					d.key = eq.has.key ? eq.att.key : null;
					d.xml = eq;
					
					addModuleAccess( grid, tile, d );
					
					if( d.iid != null ){
						var data = Protocol.itemList[d.iid.index()];
						if ( data.disassemble.length > 0 ) {
							//#if !editor
								d.ent.te.el.visible = false;
								//Debug.MSG(d.iid + ' can be dissassembled');
							//#end
						}
					}
					
					//Debug.MSG("linked iid:" + d.iid + " k:" + d.key);
				}
				//else Debug.MSG("ERROR:mislink..."+grid.getRid()+" "+sliceInfo.index);
			}
		}
	}
	
	//can be called multiple times as data is uploaded in grid and need to feed flash
	public function decorateDeps(grid:Grid )
	{
		var extra = Main.data.getExtra();
		var rooms = extra.nodes.room;
		var rTxt = Protocol.roomIdList[ grid.getRid().index() ].id;
		
		var myRoomNode = rooms.find( function(r) return r.att.rid == rTxt );
		var doors = ListEx.n();
		if( myRoomNode != null)
			doors = myRoomNode.nodes.makeDoor;
		
		var curDoor = 0;
		var id = grid.getRid();
		
		for( d in grid.dependancies)
		{
			//if there is already some data
			if ( d.gameData != null && d.gameData != NoData) continue;
			
			//Debug.MSG("decorating " + d.iid);
			var frameInfo  = d.te.setup;
			var sliceInfo : PixSlice = Data.slices.get( frameInfo.index );
			var tile = d.tile;
			var te = d.te;
			var grPos = d.tile.getGridPos();
			
			if(d.pad== null) d.pad = [];
			
			if ( Main.data.testTileFlag( _Target, sliceInfo.index )  )
				d.target = sliceInfo.index;
			
			if ( Main.data.testTileFlag( _Locker, sliceInfo.index ) )
			{
				d.locker = true;
				
				var sel = selectables.pushBack( new Select( grid, d ));
					
				sel.isCloset = true;
				grid.input.register( ON_ENTER, te.el, sel.Closet_onEnter );
				grid.input.register( ON_RELEASE, te.el, sel.Closet_onRelease );
				grid.input.register( ON_OUT, te.el, sel.Closet_onOut );
			}
			
			if( Main.data.testTileFlag(  _Door, sliceInfo.index ) && doors.nth(curDoor) != null)
			{
				var tgt = doors.nth(curDoor).att.tgt;
				var tgtRid = IsoProtocol.trackbackRid(  tgt );
				d.gameData = DepData.Door( grid.getRid(), tgtRid  );
				
				addDoorHandlers( grid,d );
				
				curDoor++;
				
				if( !disableDoorArrows )
					addDoorExit(grid, tile, d);
					
				var pad = grid.getDoorPad(d);
				d.pad = pad;
			}
			else
			if( Main.data.testTileFlag(  _Decal, sliceInfo.index ) )
			{
				d.gameData = Decal;
				d.ent.prioOverride = function() return IsoConst.DECAL_PRIO + sliceInfo.prioOfs;
			}
			else
			if ( Main.data.testTileFlag(  _Chair, sliceInfo.index ) )
			{
				d.gameData = Chair;
				d.pad = [ grPos ];
				d.ent.prioOverride = function() return IsoConst.DECAL_PRIO + sliceInfo.prioOfs;
			}
			else
			if ( !Main.data.hasTileFlag( sliceInfo.index ) || Main.data.testTileFlag(  _Blocker, sliceInfo.index ) )
			{
				d.gameData = Blocker;
			}
			else
			if(  Main.data.testTileFlag(  _Equipment, sliceInfo.index ) )
			{
				if ( d.iid != null)
				{
					makeEquipment(d, te, grid);
					
					d.target = sliceInfo.index;
					//Debug.MSG("registering " + d.iid);
				}
				else
				{
					//Debug.MSG("ERROR:no valid iid " + d.iid +"/"+sliceInfo.index);
				}
				
				if(d.ent!=null)
					d.ent.prioOverride = function() return IsoConst.DECAL_PRIO + sliceInfo.prioOfs;
			}
			
			if ( d.gameData == null)
			{
				Debug.MSG("suspicious: setup= " + sliceInfo.index + "data=" + sliceInfo.data);
				d.gameData = NoData;
			}
			
			//launch startup animations
			if( IsoConst.BG_ANIM)
				if ( sliceInfo.animable && sliceInfo.autoAnim)
					d.te.el.play(d.te.setup.index);
		}
	}
	
	function makeEquipment(d,te,grid)
	{
		d.gameData = DepData.Equipment( d.iid );
		
		//#if editor
		//	trace("making " + Std.string(d) + " " + Std.string(te) + " !");
		//#else
			//trace("making " + Std.string(d) + " " + Std.string(te) + " !");
		//#end
		
		var sel = selectables.pushBack( new Select( grid, d ));
		
		grid.input.register( ON_ENTER, te.el, sel.Equipment_onEnter );
		grid.input.register( ON_RELEASE, te.el, sel.Equipment_onRelease );
		grid.input.register( ON_OUT, te.el, sel.Equipment_onOut );
	}
	
	
	function cacheDependancies(grid : Grid )
	{
		for( d in grid.dependancies)
		{
			if ( d.rectCache != null) continue;
			var minX = d.data.fold( function(v, r) return MathEx.mini(r,v.x) , d.data[0].x );
			var minY = d.data.fold( function(v, r) return MathEx.mini(r,v.y) , d.data[0].y );
			
			var maxX = d.data.fold( function(v, r) return MathEx.maxi(r,v.x) , d.data[0].x );
			var maxY = d.data.fold( function(v, r) return MathEx.maxi(r, v.y) , d.data[0].y );
			
			d.rectCache = [ new V2I(minX, minY), new V2I(maxX, maxY) ];
			
			if( d.ent != null)
				d.ent.getRect = function()
					return d.rectCache;
			
			//Debug.MSG("caching dep : " + d.rectCache+ " "+ d.te.setup.index+" of " + d.data);
		}
	}
	
	public function postProcessRoom( rd : RoomDesc )
	{
		var grid = rd.data;
		linkEquipments(grid);
		decorateDeps(grid);//decorate dependancies here
		cacheDependancies(grid);
		
		#if debug
		for( d in grid.dependancies)
		{
			if( d.gameData == null)
				Debug.MSG( "post : dep not decorated: "+d.te.setup.index+" "+ grid.getRid() + " for tiles : " + d.tile+" pixel:"+Std.string(d.debug ));
		}
		#end
		
		rd.data.visible = false;
		rd.data.dirtSort();
	}
	
	public function check()
	{
		#if debug
		for( g in this.rooms)
		{
			var grid = g.data;
			for(d in grid.dependancies)
			{
				if ( d.gameData == null)
				{
					Debug.MSG( "check : dep not decorated: " + grid.getRid() + " for tiles : " + d.tile);
					continue;
				}
				switch(d.gameData)
				{
					default: //not checked specifically
					case Door( here, there ):
						var ok = false;
						var other = rooms.get( there );
						for(kd in other.data.dependancies)
						{
							if( kd.gameData!=null)
							switch(kd.gameData)
							{
								case Door(here2, there2): if( there2 == here ) ok  = true;
								default:
							}
						}
						Debug.ASSERT( ok,there+" has no link to "+here+" a door might be missing either on the bmp or the xml" );
				}
			}
		}
		#end
	}
	
	public function update()
	{
		if( current() == null ) return;
		
		var gr :Grid = current().data;
		if( gr != null)
			gr.update();
			
		for ( s in selectables)
			s.update();
	}
	
	public inline function getRooms()
	{
		return rooms;
	}
	
}